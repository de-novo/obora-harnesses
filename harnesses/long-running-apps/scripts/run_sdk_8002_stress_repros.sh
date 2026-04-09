#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/denovo/workspace/github/obora-harnesses"
CONFIG="$ROOT/harnesses/long-running-apps/configs/obora/config.yaml"
WORKDIR="$ROOT/generated/debug/sdk-8002-stress-repros"
REPORT_DIR="$WORKDIR/reports"
mkdir -p "$WORKDIR" "$REPORT_DIR" "$WORKDIR/artifacts"

run_one() {
  local name="$1"
  local workflow="$2"
  local report="$REPORT_DIR/${name}.log"

  rm -rf "$WORKDIR/artifacts"
  mkdir -p "$WORKDIR/artifacts"

  echo "=== RUN $name ===" | tee "$report"
  (
    cd "$WORKDIR"
    obora run "$workflow" \
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

run_one large-prompt-small-output "$ROOT/harnesses/long-running-apps/workflows/sdk-8002-repro-large-prompt-small-output.yaml"
run_one medium-prompt-structured-output "$ROOT/harnesses/long-running-apps/workflows/sdk-8002-repro-medium-prompt-structured-output.yaml"
run_one long-chain-short-prompts "$ROOT/harnesses/long-running-apps/workflows/sdk-8002-repro-long-chain-short-prompts.yaml"

echo "Reports written to $REPORT_DIR"
