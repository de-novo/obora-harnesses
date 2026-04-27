#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/denovo/workspace/github/obora-harnesses"
CONFIG="$ROOT/harnesses/long-running-apps/configs/obora/config.yaml"
WORKDIR="$ROOT/generated/debug/todo-react-upgrade-phases"
REPORT_DIR="$WORKDIR/reports"
mkdir -p "$WORKDIR" "$REPORT_DIR"

run_phase() {
  local phase="$1"
  local workflow="$2"
  local report="$REPORT_DIR/${phase}.log"

  echo "=== RUN $phase ===" | tee "$report"
  (
    cd "$WORKDIR"
    "$OBORA_BIN" run "$workflow" \
      --config "$CONFIG" \
      --model glm-4.7 \
      --timeout 300000 \
      --debug
  ) >>"$report" 2>&1 || true

  echo >>"$report"
  echo "--- artifacts snapshot ---" >>"$report"
  find "$WORKDIR/artifacts" -maxdepth 3 -type f 2>/dev/null | sort >>"$report" || true
  echo "--- packages snapshot ---" >>"$report"
  find "$WORKDIR/packages" -maxdepth 6 -type f 2>/dev/null | sort >>"$report" || true
  echo >>"$report"
}

mkdir -p "$WORKDIR/artifacts" "$WORKDIR/packages/web/src/components" "$WORKDIR/packages/web/src/services" "$WORKDIR/packages/web/src/types"

run_phase phase1 "$ROOT/harnesses/long-running-apps/workflows/todo-react-upgrade-phase1.yaml"
sleep 15
run_phase phase2 "$ROOT/harnesses/long-running-apps/workflows/todo-react-upgrade-phase2.yaml"
sleep 15
run_phase phase3 "$ROOT/harnesses/long-running-apps/workflows/todo-react-upgrade-phase3.yaml"
sleep 15
run_phase phase4 "$ROOT/harnesses/long-running-apps/workflows/todo-react-upgrade-phase4.yaml"

echo "Reports written to $REPORT_DIR"
