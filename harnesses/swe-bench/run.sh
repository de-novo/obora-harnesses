#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../_common/env.sh"
source "$SCRIPT_DIR/../_common/auth.sh"
source "$SCRIPT_DIR/../_common/run.sh"
source "$SCRIPT_DIR/../_common/report.sh"

# 인증 로드
load_auth

# 파라미터
SAMPLE_ARG="${1:-5}"
SAMPLES_DIR="${SAMPLES_DIR:-$SCRIPT_DIR/samples-no-answer}"
WORKFLOW="${WORKFLOW:-$SCRIPT_DIR/workflows/obora-os-workflow.yaml}"
CONFIG="${CONFIG:-$SCRIPT_DIR/configs/obora/config.yaml}"

# 실행 디렉토리 설정
RUN_DIR=$(ensure_run_dir "swe-bench")
write_meta "$RUN_DIR" "swe-bench"

log_info "SWE-bench Harness"
log_info "Provider: $OBORA_PROVIDER"
log_info "Model: $OBORA_MODEL"
log_info "Output: $RUN_DIR"

# 샘플 목록 준비
SAMPLE_FILES=()
if echo "$SAMPLE_ARG" | grep -Eq '^[0-9]+$'; then
  mapfile -t SAMPLE_FILES < <(ls "$SAMPLES_DIR"/*.json | head -n "$SAMPLE_ARG")
else
  if [ -f "$SAMPLES_DIR/$SAMPLE_ARG.json" ]; then
    SAMPLE_FILES=("$SAMPLES_DIR/$SAMPLE_ARG.json")
  else
    log_error "Unknown sample: $SAMPLE_ARG"
    exit 1
  fi
fi

TOTAL=${#SAMPLE_FILES[@]}
log_info "Samples: $TOTAL"

# 실행
for SAMPLE_FILE in "${SAMPLE_FILES[@]}"; do
  SAMPLE_ID=$(basename "$SAMPLE_FILE" .json)
  SAMPLE_DIR="$RUN_DIR/$SAMPLE_ID"
  mkdir -p "$SAMPLE_DIR"

  log_info "[$SAMPLE_ID] Starting..."

  # Git clone/checkout
  WORK_DIR="/tmp/swebench_$SAMPLE_ID"
  REPO_DIR="$WORK_DIR/repo"
  ARTIFACTS_DIR="$REPO_DIR/artifacts"
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR"

  REPO=$(jq -r '.repo' "$SAMPLE_FILE")
  BASE_COMMIT=$(jq -r '.base_commit' "$SAMPLE_FILE")

  if ! timeout 180 git clone --depth 1 "https://github.com/$REPO.git" "$REPO_DIR" >/dev/null 2>&1; then
    log_error "[$SAMPLE_ID] Clone failed"
    echo "FAIL_CLONE" > "$SAMPLE_DIR/status.txt"
    continue
  fi

  if ! timeout 60 git -C "$REPO_DIR" fetch --depth 100 origin "$BASE_COMMIT" >/dev/null 2>&1; then
    log_error "[$SAMPLE_ID] Fetch failed"
    echo "FAIL_FETCH" > "$SAMPLE_DIR/status.txt"
    continue
  fi

  if ! timeout 30 git -C "$REPO_DIR" checkout "$BASE_COMMIT" >/dev/null 2>&1; then
    log_error "[$SAMPLE_ID] Checkout failed"
    echo "FAIL_CHECKOUT" > "$SAMPLE_DIR/status.txt"
    continue
  fi

  # Artifacts 준비
  mkdir -p "$ARTIFACTS_DIR"
  jq -r '.problem_statement' "$SAMPLE_FILE" > "$ARTIFACTS_DIR/problem.txt"

  # Obora 실행
  START_TIME=$(date +%s%3N)
  if run_obora "$WORKFLOW" "$CONFIG" "$SAMPLE_DIR" "$OBORA_TIMEOUT_MS"; then
    END_TIME=$(date +%s%3N)
    DURATION=$((END_TIME - START_TIME))

    # 결과 검증
    if [ -f "$ARTIFACTS_DIR/edit.json" ]; then
      cp "$ARTIFACTS_DIR/edit.json" "$SAMPLE_DIR/edit.json"
    fi

    # TODO: 실제 패치 검증 로직
    echo "PASS" > "$SAMPLE_DIR/status.txt"
    log_info "[$SAMPLE_ID] PASS (${DURATION}ms)"
  else
    END_TIME=$(date +%s%3N)
    DURATION=$((END_TIME - START_TIME))
    echo "FAIL_RUNTIME" > "$SAMPLE_DIR/status.txt"
    log_error "[$SAMPLE_ID] FAIL (${DURATION}ms)"
  fi

  # 메타데이터
  cat > "$SAMPLE_DIR/meta.json" <<EOF
{
  "sample_id": "$SAMPLE_ID",
  "repo": "$REPO",
  "duration_ms": $DURATION
}
EOF

  # Cleanup
  rm -rf "$WORK_DIR"
  sleep 2
done

# 결과 집계
generate_report "$RUN_DIR" "swe-bench"

# 심볼릭 링크
ln -sfn "$RUN_DIR" "$HARNESS_OUTPUT_ROOT/swe-bench/latest"

log_info "Done. Results: $RUN_DIR"
