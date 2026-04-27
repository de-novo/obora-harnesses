#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TARGET_DIR="$REPO_ROOT/generated/cli/validated/todo-cli-fresh"
WORKFLOW="$REPO_ROOT/harnesses/long-running-apps/workflows/todo-cli-enhanced.yaml"
CONFIG="$REPO_ROOT/harnesses/long-running-apps/configs/obora/config.yaml"
SMOKE_SCRIPT="$REPO_ROOT/harnesses/long-running-apps/scripts/smoke_todo_cli_slice1.py"
MATERIALIZE_SCRIPT="$REPO_ROOT/harnesses/long-running-apps/scripts/materialize_todo_cli_artifacts.py"
ARTIFACTS_DIR="$TARGET_DIR/artifacts"
RUN_TIMEOUT="${OBORA_RUN_TIMEOUT_MS:-300000}"
OBORA_BIN="${OBORA_BIN:-obora}"
MAX_ATTEMPTS=3
RUN_JSON=""
ATTEMPT=1
LAST_CODE=0

rm -rf "$ARTIFACTS_DIR"
mkdir -p "$ARTIFACTS_DIR"

# Seed artifacts directory so agents read/write only under artifacts/
cp "$TARGET_DIR/spec.md" "$ARTIFACTS_DIR/spec.md" 2>/dev/null || true
cp "$TARGET_DIR/task-contract.json" "$ARTIFACTS_DIR/task-contract.json" 2>/dev/null || true
cp "$TARGET_DIR/qa-report.json" "$ARTIFACTS_DIR/qa-report.json" 2>/dev/null || true

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
  find "$ARTIFACTS_DIR" -maxdepth 1 -name 'todo-cli-enhanced-*.json' -delete
  set +e
  "$OBORA_BIN" run "$WORKFLOW" --config "$CONFIG" --output-dir "$ARTIFACTS_DIR" --timeout "$RUN_TIMEOUT" >"$ARTIFACTS_DIR/run.out" 2>"$ARTIFACTS_DIR/run.err"
  LAST_CODE=$?
  set -e
  if [ $LAST_CODE -eq 0 ]; then
    break
  fi
  RUN_JSON=$(find "$ARTIFACTS_DIR" -maxdepth 1 -name 'todo-cli-enhanced-*.json' | head -n 1 || true)
  if grep -q 'SDK_8002' "$ARTIFACTS_DIR/run.err" 2>/dev/null || { [ -n "$RUN_JSON" ] && grep -q 'SDK_8002' "$RUN_JSON"; }; then
    echo "⚠️ SDK_8002 during todo-cli workflow run, retrying (attempt $ATTEMPT/$MAX_ATTEMPTS)..."
    sleep $((ATTEMPT * 10))
    ATTEMPT=$((ATTEMPT + 1))
    continue
  fi
  break
done

RUN_JSON=$(find "$ARTIFACTS_DIR" -maxdepth 1 -name 'todo-cli-enhanced-*.json' | head -n 1 || true)
if [ -z "$RUN_JSON" ]; then
  echo "Missing workflow run json bundle in $ARTIFACTS_DIR" >&2
  exit 1
fi

python3 "$MATERIALIZE_SCRIPT" "$RUN_JSON" "$ARTIFACTS_DIR"

for f in spec.md task-contract.json qa-report.json; do
  if [ ! -f "$ARTIFACTS_DIR/$f" ]; then
    echo "Missing required artifact: $ARTIFACTS_DIR/$f" >&2
    exit 1
  fi
done

python3 "$SMOKE_SCRIPT" "$TARGET_DIR" "$ARTIFACTS_DIR/smoke-report.json"

echo "Artifacts written to: $ARTIFACTS_DIR"
