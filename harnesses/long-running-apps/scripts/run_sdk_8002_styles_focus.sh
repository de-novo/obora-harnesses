#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/denovo/workspace/github/obora-harnesses"
CONFIG="$ROOT/harnesses/long-running-apps/configs/obora/config.yaml"
WORKDIR="$ROOT/generated/debug/sdk-8002-styles-focus"
REPORT_DIR="$WORKDIR/reports"
mkdir -p "$WORKDIR" "$REPORT_DIR" "$WORKDIR/artifacts" "$WORKDIR/packages/web/src/components"

run_one() {
  local name="$1"
  local workflow="$2"
  local report="$REPORT_DIR/${name}.log"

  rm -rf "$WORKDIR/artifacts" "$WORKDIR/packages"
  mkdir -p "$WORKDIR/artifacts" "$WORKDIR/packages/web/src/components"

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
  echo "--- packages snapshot ---" >>"$report"
  find "$WORKDIR/packages" -maxdepth 6 -type f 2>/dev/null | sort >>"$report" || true
  echo >>"$report"
}

run_one styles-only-heavy "$ROOT/harnesses/long-running-apps/workflows/sdk-8002-styles-only-heavy.yaml"
run_one components-plus-styles "$ROOT/harnesses/long-running-apps/workflows/sdk-8002-components-plus-styles.yaml"
run_one styles-ladder-small "$ROOT/harnesses/long-running-apps/workflows/sdk-8002-styles-ladder-small.yaml"
run_one styles-ladder-medium "$ROOT/harnesses/long-running-apps/workflows/sdk-8002-styles-ladder-medium.yaml"
run_one styles-ladder-heavy "$ROOT/harnesses/long-running-apps/workflows/sdk-8002-styles-ladder-heavy.yaml"

echo "Reports written to $REPORT_DIR"
