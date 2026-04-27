#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/denovo/workspace/github/obora-harnesses"
CONFIG="$ROOT/harnesses/long-running-apps/configs/obora/config.yaml"
WORKDIR="$ROOT/generated/debug/sdk-8002-near-original-frontend"
REPORT_DIR="$WORKDIR/reports"
mkdir -p "$WORKDIR" "$REPORT_DIR" "$WORKDIR/artifacts" "$WORKDIR/packages/web"

run_one() {
  local name="$1"
  local workflow="$2"
  local report="$REPORT_DIR/${name}.log"

  rm -rf "$WORKDIR/artifacts" "$WORKDIR/packages/web"
  mkdir -p "$WORKDIR/artifacts" "$WORKDIR/packages/web"

  echo "=== RUN $name ===" | tee "$report"
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
  echo "--- packages/web snapshot ---" >>"$report"
  find "$WORKDIR/packages/web" -maxdepth 5 -type f 2>/dev/null | sort >>"$report" || true
  echo >>"$report"
}

run_one near-original-with-control-flow "$ROOT/harnesses/long-running-apps/workflows/sdk-8002-near-original-frontend.yaml"
run_one near-original-no-control-flow "$ROOT/harnesses/long-running-apps/workflows/sdk-8002-near-original-frontend-no-control-flow.yaml"

echo "Reports written to $REPORT_DIR"
