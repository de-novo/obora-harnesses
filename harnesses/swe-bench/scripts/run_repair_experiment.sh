#!/bin/bash
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
cd "$REPO_ROOT" || exit 1

if [ -z "${ZAI_API_KEY:-}" ]; then
  export ZAI_API_KEY=$(jq -r '.providers.zai.apiKey // empty' ~/.obora/auth.json)
  echo "Loaded ZAI_API_KEY from auth.json"
fi

SAMPLES_DIR="${SAMPLES_DIR:-$REPO_ROOT/harnesses/swe-bench/samples-no-answer}"
RESULTS_DIR="${RESULTS_DIR:-$REPO_ROOT/harnesses/swe-bench/results-repair}"
SAMPLE_ARG=${1:-5}
HELPER="$SCRIPT_DIR/structured_repair_helper.py"
WORKFLOW="${WORKFLOW:-$REPO_ROOT/harnesses/swe-bench/workflows/obora-os-workflow.yaml}"
CONFIG="${CONFIG:-$REPO_ROOT/harnesses/swe-bench/configs/obora/config.yaml}"
OBORA_BIN="${OBORA_BIN:-obora}"
OBORA_PROVIDER="${OBORA_PROVIDER:-}"
OBORA_MODEL="${OBORA_MODEL:-}"

# Build provider/model flags if env vars are set
OBORA_PROVIDER_FLAG=""
OBORA_MODEL_FLAG=""
if [ -n "$OBORA_PROVIDER" ]; then
  OBORA_PROVIDER_FLAG="--provider $OBORA_PROVIDER"
fi
if [ -n "$OBORA_MODEL" ]; then
  OBORA_MODEL_FLAG="--model $OBORA_MODEL"
fi

PASS=0
FAIL=0
TOTAL=0

SAMPLE_FILES=()
if echo "$SAMPLE_ARG" | grep -Eq '^[0-9]+$'; then
  SAMPLE_COUNT="$SAMPLE_ARG"
  while IFS= read -r f; do
    SAMPLE_FILES+=("$f")
  done < <(ls "$SAMPLES_DIR"/*.json | head -n "$SAMPLE_COUNT")
else
  SAMPLE_COUNT=1
  if [ -f "$SAMPLES_DIR/$SAMPLE_ARG.json" ]; then
    SAMPLE_FILES+=("$SAMPLES_DIR/$SAMPLE_ARG.json")
  else
    echo "Unknown sample: $SAMPLE_ARG"
    exit 1
  fi
fi

echo "=== SWE-bench Evaluation with CLI Validation Repair ==="
echo "Start: $(date)"
echo "Samples: $SAMPLE_COUNT"
echo ""

mkdir -p "$RESULTS_DIR"

for SAMPLE_FILE in "${SAMPLE_FILES[@]}"; do
  [ -f "$SAMPLE_FILE" ] || continue
  TOTAL=$((TOTAL + 1))
  SAMPLE_ID=$(basename "$SAMPLE_FILE" .json)
  RESULT_DIR="$RESULTS_DIR/$SAMPLE_ID"
  WORK_DIR="/tmp/swebench_repair_$SAMPLE_ID"
  REPO_DIR="$WORK_DIR/repo"
  ARTIFACTS_DIR="$REPO_DIR/artifacts"

  echo ""
  echo "=== [$TOTAL/$SAMPLE_COUNT] $SAMPLE_ID ==="

  rm -rf "$RESULT_DIR" "$WORK_DIR"
  mkdir -p "$RESULT_DIR" "$WORK_DIR"

  REPO=$(jq -r '.repo' "$SAMPLE_FILE")
  BASE_COMMIT=$(jq -r '.base_commit' "$SAMPLE_FILE")

  echo "Cloning $REPO..."
  if ! timeout 180 git clone --depth 1 "https://github.com/$REPO.git" "$REPO_DIR" >/dev/null 2>&1; then
    echo "❌ FAIL: Clone failed"
    echo "FAIL_CLONE" > "$RESULT_DIR/status.txt"
    FAIL=$((FAIL + 1))
    continue
  fi

  if ! timeout 60 git -C "$REPO_DIR" fetch --depth 100 origin "$BASE_COMMIT" >/dev/null 2>&1; then
    echo "❌ FAIL: Fetch failed"
    echo "FAIL_FETCH" > "$RESULT_DIR/status.txt"
    FAIL=$((FAIL + 1))
    continue
  fi

  if ! timeout 30 git -C "$REPO_DIR" checkout "$BASE_COMMIT" >/dev/null 2>&1; then
    echo "❌ FAIL: Checkout failed"
    echo "FAIL_CHECKOUT" > "$RESULT_DIR/status.txt"
    FAIL=$((FAIL + 1))
    continue
  fi

  mkdir -p "$ARTIFACTS_DIR"
  jq -r '.problem_statement' "$SAMPLE_FILE" > "$ARTIFACTS_DIR/problem.txt"

  TARGET_FILE=$(python3 "$HELPER" extract-target "$ARTIFACTS_DIR/problem.txt")
  printf '%s\n' "$TARGET_FILE" > "$ARTIFACTS_DIR/target_file.txt"

  if [ -n "$TARGET_FILE" ] && [ -f "$REPO_DIR/$TARGET_FILE" ]; then
    python3 "$HELPER" make-snippet "$REPO_DIR" "$TARGET_FILE" "$ARTIFACTS_DIR/target_snippet.txt"
  else
    : > "$ARTIFACTS_DIR/target_snippet.txt"
  fi

  echo "Running Obora CLI validation-repair loop..."
  ATTEMPT=1
  MAX_ATTEMPTS=3
  RUN_OK=false
  FAILURE_TYPE=""
  FAILURE_SIGNATURE=""
  FAILED_STEP=""
  RETRY_COUNT=0
  POST_VALIDATE_RETRY_COUNT=0
  MAX_POST_VALIDATE_RETRIES=1
  while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    : > "$RESULT_DIR/obora.log"
    if (cd "$REPO_DIR" && "$OBORA_BIN" run "$WORKFLOW" --config "$CONFIG" --output-dir "$RESULT_DIR" --timeout ${OBORA_RUN_TIMEOUT_MS:-240000} $OBORA_PROVIDER_FLAG $OBORA_MODEL_FLAG) 2>&1 | tee "$RESULT_DIR/obora.log"; then
      RUN_OK=true
      break
    fi

    FAILED_STEP=$(python3 - <<'PY' "$RESULT_DIR/obora.log"
from pathlib import Path
import re, sys
text = Path(sys.argv[1]).read_text(errors='ignore')
steps = re.findall(r'→\s*([^\x1b\[]+)', text)
print(steps[-1].strip() if steps else '')
PY
)

    if grep -q '429 Rate limit reached for requests' "$RESULT_DIR/obora.log"; then
      FAILURE_TYPE="RATE_LIMIT"
      FAILURE_SIGNATURE="429-rate-limit"
      SLEEP_SECS=$((ATTEMPT * 20))
      echo "⚠️ 429 rate limit, retrying in ${SLEEP_SECS}s..."
      RETRY_COUNT=$((RETRY_COUNT + 1))
      sleep "$SLEEP_SECS"
      ATTEMPT=$((ATTEMPT + 1))
      continue
    fi

    if grep -q '\[SDK_8002\] Execution cancelled' "$RESULT_DIR/obora.log"; then
      FAILURE_TYPE="SDK_8002"
      FAILURE_SIGNATURE="sdk-8002-execution-cancelled"
      if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
        if [ "$FAILED_STEP" = "discover_target" ]; then
          SLEEP_SECS=$((ATTEMPT * 15))
          echo "⚠️ SDK_8002 during discover_target, retrying in ${SLEEP_SECS}s with reduced step pressure..."
        else
          SLEEP_SECS=5
          echo "⚠️ SDK_8002 execution cancelled, retrying in ${SLEEP_SECS}s..."
        fi
        RETRY_COUNT=$((RETRY_COUNT + 1))
        sleep "$SLEEP_SECS"
        ATTEMPT=$((ATTEMPT + 1))
        continue
      fi
    fi

    if [ -z "$FAILURE_TYPE" ]; then
      FAILURE_TYPE="UNKNOWN_RUNTIME"
      FAILURE_SIGNATURE="unknown-runtime-failure"
    fi
    break
  done

  python3 - <<'PY' "$RESULT_DIR/runtime-failure.json" "$SAMPLE_ID" "$REPO" "$WORKFLOW" "$OBORA_BIN" "$FAILED_STEP" "$FAILURE_TYPE" "$FAILURE_SIGNATURE" "$ATTEMPT" "$RETRY_COUNT" "$RUN_OK"
import json, sys
out, sample_id, repo, workflow, obora_bin, failed_step, failure_type, failure_signature, attempt, retry_count, run_ok = sys.argv[1:]
payload = {
  "sample_id": sample_id,
  "repo": repo,
  "workflow": workflow,
  "obora_bin": obora_bin,
  "failed_step": failed_step,
  "failure_type": failure_type,
  "failure_signature": failure_signature,
  "attempt_count": int(attempt),
  "retry_count": int(retry_count),
  "run_ok": run_ok.lower() == 'true',
}
with open(out, 'w') as f:
    json.dump(payload, f, indent=2)
PY

  if [ "$RUN_OK" = true ]; then
    if [ -f "$ARTIFACTS_DIR/edit.json" ]; then
      cp "$ARTIFACTS_DIR/edit.json" "$RESULT_DIR/edit.json"
    fi

    FINAL_TARGET_FILE=$(cat "$ARTIFACTS_DIR/target_file.txt" 2>/dev/null || true)
    if [ -z "$FINAL_TARGET_FILE" ] && [ -f "$ARTIFACTS_DIR/edit.json" ]; then
      FINAL_TARGET_FILE=$(jq -r '.target_file // empty' "$ARTIFACTS_DIR/edit.json" 2>/dev/null || true)
    fi
    if [ -z "$FINAL_TARGET_FILE" ]; then
      echo "❌ FAIL: Missing final target file"
      echo "FAIL_NO_TARGET" > "$RESULT_DIR/status.txt"
      FAIL=$((FAIL + 1))
      sleep 3
      continue
    fi

    if [ ! -f "$REPO_DIR/$FINAL_TARGET_FILE" ]; then
      echo "❌ FAIL: Target file missing: $FINAL_TARGET_FILE"
      echo "FAIL_WRONG_TARGET" > "$RESULT_DIR/status.txt"
      FAIL=$((FAIL + 1))
      sleep 3
      continue
    fi

    python3 "$HELPER" validate-edit "$ARTIFACTS_DIR" "$REPO_DIR" "$FINAL_TARGET_FILE" > "$RESULT_DIR/final-validation.json"
    if jq -e '.passed == true' "$RESULT_DIR/final-validation.json" >/dev/null 2>&1; then
      cp "$ARTIFACTS_DIR/patch.diff" "$RESULT_DIR/patch.diff"
      echo "✅ PASS"
      echo "PASS" > "$RESULT_DIR/status.txt"
      PASS=$((PASS + 1))
    else
      FINAL_SIGNATURE=$(jq -r '.signature // empty' "$RESULT_DIR/final-validation.json" 2>/dev/null || true)
      if [ $POST_VALIDATE_RETRY_COUNT -lt $MAX_POST_VALIDATE_RETRIES ] && [ -n "$FINAL_SIGNATURE" ]; then
        echo "⚠️ Deterministic final validation failed (${FINAL_SIGNATURE}); feeding back once more into repair loop..."
        cp "$RESULT_DIR/final-validation.json" "$ARTIFACTS_DIR/validation-report.json"
        POST_VALIDATE_RETRY_COUNT=$((POST_VALIDATE_RETRY_COUNT + 1))
        RUN_OK=false
        FAILURE_TYPE="FINAL_VALIDATION_RETRY"
        FAILURE_SIGNATURE="$FINAL_SIGNATURE"
        ATTEMPT=1
        RETRY_COUNT=$((RETRY_COUNT + 1))
        while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
          : > "$RESULT_DIR/obora.log"
          if (cd "$REPO_DIR" && "$OBORA_BIN" run "$WORKFLOW" --config "$CONFIG" --output-dir "$RESULT_DIR" --timeout ${OBORA_RUN_TIMEOUT_MS:-240000} $OBORA_PROVIDER_FLAG $OBORA_MODEL_FLAG) 2>&1 | tee "$RESULT_DIR/obora.log"; then
            RUN_OK=true
            break
          fi
          FAILED_STEP=$(python3 - <<'PY' "$RESULT_DIR/obora.log"
from pathlib import Path
import re, sys
text = Path(sys.argv[1]).read_text(errors='ignore')
steps = re.findall(r'→\s*([^\x1b\[]+)', text)
print(steps[-1].strip() if steps else '')
PY
)
          if grep -q '\[SDK_8002\] Execution cancelled' "$RESULT_DIR/obora.log"; then
            FAILURE_TYPE="SDK_8002"
            FAILURE_SIGNATURE="sdk-8002-execution-cancelled"
            if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
              echo "⚠️ SDK_8002 execution cancelled during post-validation retry, retrying..."
              RETRY_COUNT=$((RETRY_COUNT + 1))
              sleep 5
              ATTEMPT=$((ATTEMPT + 1))
              continue
            fi
          fi
          break
        done
        if [ "$RUN_OK" = true ]; then
          if [ -f "$ARTIFACTS_DIR/edit.json" ]; then
            cp "$ARTIFACTS_DIR/edit.json" "$RESULT_DIR/edit.json"
          fi
          python3 "$HELPER" validate-edit "$ARTIFACTS_DIR" "$REPO_DIR" "$FINAL_TARGET_FILE" > "$RESULT_DIR/final-validation.json"
          if jq -e '.passed == true' "$RESULT_DIR/final-validation.json" >/dev/null 2>&1; then
            cp "$ARTIFACTS_DIR/patch.diff" "$RESULT_DIR/patch.diff"
            echo "✅ PASS"
            echo "PASS" > "$RESULT_DIR/status.txt"
            PASS=$((PASS + 1))
          else
            echo "❌ FAIL: Final validation failed"
            echo "FAIL_PATCH" > "$RESULT_DIR/status.txt"
            FAIL=$((FAIL + 1))
          fi
        else
          echo "❌ FAIL: CLI repair loop execution failed"
          echo "FAIL_RUNTIME" > "$RESULT_DIR/status.txt"
          FAIL=$((FAIL + 1))
        fi
      else
        echo "❌ FAIL: Final validation failed"
        echo "FAIL_PATCH" > "$RESULT_DIR/status.txt"
        FAIL=$((FAIL + 1))
      fi
    fi
  else
    echo "❌ FAIL: CLI repair loop execution failed"
    echo "FAIL_RUNTIME" > "$RESULT_DIR/status.txt"
    FAIL=$((FAIL + 1))
  fi

  sleep 3
done

echo ""
echo "=== Final Results ==="
echo "End: $(date)"
echo "Total: $TOTAL"
echo "PASS: $PASS"
echo "FAIL: $FAIL"
if [ "$TOTAL" -gt 0 ]; then
  echo "Pass Rate: $((PASS * 100 / TOTAL))%"
fi

RUNTIME_FAIL_COUNT=$(find "$RESULTS_DIR" -maxdepth 2 -name status.txt -exec grep -l '^FAIL_RUNTIME$' {} \; 2>/dev/null | wc -l | tr -d ' ')
QUALITY_FAIL_COUNT=$(find "$RESULTS_DIR" -maxdepth 2 -name status.txt -exec grep -El '^(FAIL_PATCH|FAIL_WRONG_TARGET|FAIL_NO_TARGET)$' {} \; 2>/dev/null | wc -l | tr -d ' ')
INFRA_FAIL_COUNT=$(find "$RESULTS_DIR" -maxdepth 2 -name status.txt -exec grep -El '^(FAIL_CLONE|FAIL_FETCH|FAIL_CHECKOUT|FAIL_UNKNOWN)$' {} \; 2>/dev/null | wc -l | tr -d ' ')

echo "total: $TOTAL" > "$RESULTS_DIR/summary.txt"
echo "pass: $PASS" >> "$RESULTS_DIR/summary.txt"
echo "fail: $FAIL" >> "$RESULTS_DIR/summary.txt"
echo "runtime_fail: $RUNTIME_FAIL_COUNT" >> "$RESULTS_DIR/summary.txt"
echo "quality_fail: $QUALITY_FAIL_COUNT" >> "$RESULTS_DIR/summary.txt"
echo "infra_fail: $INFRA_FAIL_COUNT" >> "$RESULTS_DIR/summary.txt"
if [ "$TOTAL" -gt 0 ]; then
  echo "pass_rate: $((PASS * 100 / TOTAL))%" >> "$RESULTS_DIR/summary.txt"
fi
