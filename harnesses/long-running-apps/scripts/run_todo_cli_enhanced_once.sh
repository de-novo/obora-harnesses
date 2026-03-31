#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TARGET_DIR="$REPO_ROOT/generated/cli/validated/todo-cli-enhanced"
WORKFLOW="$REPO_ROOT/harnesses/long-running-apps/workflows/todo-cli-enhanced.yaml"
CONFIG="$REPO_ROOT/harnesses/long-running-apps/configs/obora/config.yaml"
SMOKE_SCRIPT="${SMOKE_SCRIPT:-$REPO_ROOT/harnesses/long-running-apps/scripts/smoke_todo_cli_slice1.py}"
MATERIALIZE_SCRIPT="$REPO_ROOT/harnesses/long-running-apps/scripts/materialize_todo_cli_artifacts.py"
ARTIFACTS_DIR="$TARGET_DIR/artifacts"
RUN_TIMEOUT="${OBORA_RUN_TIMEOUT_MS:-300000}"
MAX_ATTEMPTS=3
ATTEMPT=1
RUN_JSON=""
LAST_CODE=0

rm -rf "$ARTIFACTS_DIR"
mkdir -p "$ARTIFACTS_DIR"

# Seed artifacts directory so agents read/write only under artifacts/
cp "$TARGET_DIR/spec.md" "$ARTIFACTS_DIR/spec.md" 2>/dev/null || true
cp "$TARGET_DIR/task-contract.json" "$ARTIFACTS_DIR/task-contract.json" 2>/dev/null || true
cp "$TARGET_DIR/implementation-notes.md" "$ARTIFACTS_DIR/implementation-notes.md" 2>/dev/null || true
cp "$TARGET_DIR/qa-report.json" "$ARTIFACTS_DIR/qa-report.json" 2>/dev/null || true
cp "$TARGET_DIR/README.md" "$ARTIFACTS_DIR/README.seed.md" 2>/dev/null || true

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
  find "$ARTIFACTS_DIR" -maxdepth 1 -name 'todo-cli-enhanced-*.json' -delete
  set +e
  obora run "$WORKFLOW" --config "$CONFIG" --output-dir "$ARTIFACTS_DIR" --timeout "$RUN_TIMEOUT" >"$ARTIFACTS_DIR/run.out" 2>"$ARTIFACTS_DIR/run.err"
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
  python3 - <<'PY' "$ARTIFACTS_DIR/runtime-failure.json" "$LAST_CODE" "$ATTEMPT" "$ARTIFACTS_DIR/run.err" "$ARTIFACTS_DIR/run.out"
import json, sys, pathlib
out, code, attempts, err_path, out_path = sys.argv[1:]
err = pathlib.Path(err_path).read_text(errors='ignore') if pathlib.Path(err_path).exists() else ''
stdout = pathlib.Path(out_path).read_text(errors='ignore') if pathlib.Path(out_path).exists() else ''
payload = {
  'passed': False,
  'failureType': 'MISSING_RUN_BUNDLE',
  'exitCode': int(code),
  'attempts': int(attempts),
  'sdk8002Detected': 'SDK_8002' in err or 'SDK_8002' in stdout,
  'stderrTail': err[-4000:],
  'stdoutTail': stdout[-4000:],
}
pathlib.Path(out).write_text(json.dumps(payload, indent=2) + '\n')
print(json.dumps(payload, indent=2))
PY
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

python3 - <<'PY' "$ARTIFACTS_DIR/qa-report.json" "$ARTIFACTS_DIR/smoke-report.json" "$ARTIFACTS_DIR/comparison-summary.md"
import json, sys, pathlib
qa_path = pathlib.Path(sys.argv[1])
smoke_path = pathlib.Path(sys.argv[2])
summary_path = pathlib.Path(sys.argv[3])
qa = json.loads(qa_path.read_text()) if qa_path.exists() else {}
smoke = json.loads(smoke_path.read_text())
qa['deterministicSmoke'] = smoke
qa['summary'] = (qa.get('summary','') + ' | ' if qa.get('summary') else '') + ('Deterministic smoke passed' if smoke.get('passed') else 'Deterministic smoke failed')
qa_path.write_text(json.dumps(qa, indent=2))

lines = []
lines.append('# Comparison summary')
lines.append('')
lines.append('## Enhanced artifact result')
lines.append('')
lines.append(f"- LLM QA summary: {qa.get('summary','')}")
lines.append(f"- Deterministic smoke: {'PASS' if smoke.get('passed') else 'FAIL'}")
lines.append(f"- Smoke signature: {smoke.get('signature','')}")
lines.append('')
lines.append('## Notes')
lines.append('')
lines.append('- This summary is generated deterministically by the runner to avoid making the final reporting step a workflow bottleneck.')
lines.append('- Use baseline comparison docs for side-by-side evaluation against the single-agent artifact.')
summary_path.write_text('\n'.join(lines) + '\n')
print(json.dumps(qa, indent=2))
PY

echo "Artifacts written to: $ARTIFACTS_DIR"
