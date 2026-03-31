#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TARGET_DIR="$REPO_ROOT/generated/cli/validated/todo-cli-enhanced"
WORKFLOW="$REPO_ROOT/harnesses/long-running-apps/workflows/todo-cli-enhanced.yaml"
SMOKE_SCRIPT="$REPO_ROOT/harnesses/long-running-apps/scripts/smoke_todo_cli.py"
RUN_ROOT="$TARGET_DIR/.overnight/$(date +%Y%m%d-%H%M%S)"
MAX_CYCLES="${MAX_CYCLES:-6}"
PASS_STREAK=0
REQUIRED_PASS_STREAK="${REQUIRED_PASS_STREAK:-2}"
OBORA_BIN="${OBORA_BIN:-obora}"

mkdir -p "$RUN_ROOT"
mkdir -p "$TARGET_DIR/artifacts"

echo "RUN_ROOT=$RUN_ROOT"
echo "MAX_CYCLES=$MAX_CYCLES"

action_summary() {
  local cycle="$1"
  local smoke_json="$2"
  python3 - <<'PY' "$cycle" "$smoke_json"
import json, sys
cycle = sys.argv[1]
path = sys.argv[2]
obj = json.load(open(path))
status = 'PASS' if obj.get('passed') else 'FAIL'
print(f'cycle={cycle} smoke={status} signature={obj.get("signature","")}')
PY
}

for cycle in $(seq 1 "$MAX_CYCLES"); do
  echo "=== cycle $cycle/$MAX_CYCLES ===" | tee -a "$RUN_ROOT/overnight.log"
  CYCLE_DIR="$RUN_ROOT/cycle-$cycle"
  mkdir -p "$CYCLE_DIR"

  (cd "$TARGET_DIR" && "$OBORA_BIN" run "$WORKFLOW" --output-dir "$CYCLE_DIR" --timeout "${OBORA_RUN_TIMEOUT_MS:-300000}") \
    > "$CYCLE_DIR/obora.stdout.log" 2>&1 || true

  python3 "$SMOKE_SCRIPT" "$TARGET_DIR" "$CYCLE_DIR/smoke-report.json" > "$CYCLE_DIR/smoke.stdout.log" 2>&1 || true
  cp "$CYCLE_DIR/smoke-report.json" "$TARGET_DIR/artifacts/qa-report.json"
  action_summary "$cycle" "$CYCLE_DIR/smoke-report.json" | tee -a "$RUN_ROOT/overnight.log"

  if python3 - <<'PY' "$CYCLE_DIR/smoke-report.json"
import json, sys
obj = json.load(open(sys.argv[1]))
raise SystemExit(0 if obj.get('passed') else 1)
PY
  then
    PASS_STREAK=$((PASS_STREAK + 1))
  else
    PASS_STREAK=0
  fi

  echo "pass_streak=$PASS_STREAK" | tee -a "$RUN_ROOT/overnight.log"

  if [ "$PASS_STREAK" -ge "$REQUIRED_PASS_STREAK" ]; then
    echo "Stopping after reaching pass streak ${PASS_STREAK}." | tee -a "$RUN_ROOT/overnight.log"
    break
  fi

done

echo "Overnight run complete." | tee -a "$RUN_ROOT/overnight.log"
