#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/denovo/workspace/github/obora-harnesses"
CONFIG="$ROOT/harnesses/long-running-apps/configs/obora/config.yaml"
WORKDIR="$ROOT/generated/debug/sdk-8002-repros"
REPORT_DIR="$WORKDIR/reports"
mkdir -p "$WORKDIR" "$REPORT_DIR"

run_one() {
  local name="$1"
  local workflow="$2"
  local report="$REPORT_DIR/${name}.log"

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
  find "$WORKDIR/artifacts" -maxdepth 1 -type f 2>/dev/null | sort >>"$report" || true
  echo >>"$report"
}

run_one write-only "$ROOT/harnesses/long-running-apps/workflows/sdk-8002-repro-write-only.yaml"
rm -rf "$WORKDIR/artifacts"
mkdir -p "$WORKDIR/artifacts"

run_one read-then-write "$ROOT/harnesses/long-running-apps/workflows/sdk-8002-repro-read-then-write.yaml"
rm -rf "$WORKDIR/artifacts"
mkdir -p "$WORKDIR/artifacts"

run_one multistep-chain "$ROOT/harnesses/long-running-apps/workflows/sdk-8002-repro-multistep-chain.yaml"
rm -rf "$WORKDIR/artifacts"
mkdir -p "$WORKDIR/artifacts"

run_one research-prompt "$ROOT/harnesses/long-running-apps/workflows/sdk-8002-repro-research-prompt.yaml"

echo "Reports written to $REPORT_DIR"
