#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/denovo/workspace/github/obora-harnesses"
CONFIG="$ROOT/harnesses/long-running-apps/configs/obora/config.yaml"
WORKDIR="$ROOT/generated/debug/sdk-8002-bisect-frontend"
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
OBORA_BIN="${OBORA_BIN:-obora}"

# Run the workflow
"$OBORA_BIN" run "$workflow" \
      --config "$CONFIG" \
      --model glm-4.7 \
      --timeout 300000 \
      --debug
  ) >>"$report" 2>&1 || true

  echo >>"$report"
  echo "--- artifacts snapshot ---" >>"$report"
  find "$WORKDIR/artifacts" -maxdepth 2 -type f 2>/dev/null | sort >>"$report" || true
  echo "--- packages/web snapshot ---" >>"$report"
  find "$WORKDIR/packages/web" -maxdepth 4 -type f 2>/dev/null | sort >>"$report" || true
  echo >>"$report"
}

run_one bisect-frontend-first-half "$ROOT/harnesses/long-running-apps/workflows/sdk-8002-bisect-frontend-first-half.yaml"
run_one bisect-frontend-second-half "$ROOT/harnesses/long-running-apps/workflows/sdk-8002-bisect-frontend-second-half.yaml"

echo "Reports written to $REPORT_DIR"
