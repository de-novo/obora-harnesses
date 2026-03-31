#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TARGET_DIR="$REPO_ROOT/generated/cli/validated/todo-cli-enhanced"
WORKFLOW="$REPO_ROOT/harnesses/long-running-apps/workflows/todo-cli-enhanced.yaml"
CONFIG="$REPO_ROOT/harnesses/long-running-apps/configs/obora/config.yaml"
SMOKE_SCRIPT="$REPO_ROOT/harnesses/long-running-apps/scripts/smoke_todo_cli.py"
ARTIFACTS_DIR="$TARGET_DIR/artifacts"
RUN_TIMEOUT="${OBORA_RUN_TIMEOUT_MS:-300000}"

rm -rf "$ARTIFACTS_DIR"
mkdir -p "$ARTIFACTS_DIR"

obora run "$WORKFLOW" --config "$CONFIG" --output-dir "$ARTIFACTS_DIR" --timeout "$RUN_TIMEOUT"
python3 "$SMOKE_SCRIPT" "$TARGET_DIR" "$ARTIFACTS_DIR/smoke-report.json"

python3 - <<'PY' "$ARTIFACTS_DIR/qa-report.json" "$ARTIFACTS_DIR/smoke-report.json"
import json, sys, pathlib
qa_path = pathlib.Path(sys.argv[1])
smoke_path = pathlib.Path(sys.argv[2])
qa = json.loads(qa_path.read_text()) if qa_path.exists() else {}
smoke = json.loads(smoke_path.read_text())
qa['deterministicSmoke'] = smoke
qa['summary'] = (qa.get('summary','') + ' | ' if qa.get('summary') else '') + ('Deterministic smoke passed' if smoke.get('passed') else 'Deterministic smoke failed')
qa_path.write_text(json.dumps(qa, indent=2))
print(json.dumps(qa, indent=2))
PY

echo "Artifacts written to: $ARTIFACTS_DIR"
