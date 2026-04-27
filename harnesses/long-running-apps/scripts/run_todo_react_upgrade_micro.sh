#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/denovo/workspace/github/obora-harnesses"
CONFIG="$ROOT/harnesses/long-running-apps/configs/obora/config.yaml"
WORKDIR="$ROOT/generated/debug/todo-react-upgrade-micro"
REPORT_DIR="$WORKDIR/reports"
mkdir -p "$WORKDIR" "$REPORT_DIR" "$WORKDIR/artifacts" "$WORKDIR/packages/web/src/components" "$WORKDIR/packages/web/src/services" "$WORKDIR/packages/web/src/types"

REPORT="$REPORT_DIR/run.log"

rm -rf "$WORKDIR/artifacts" "$WORKDIR/packages"
mkdir -p "$WORKDIR/artifacts" "$WORKDIR/packages/web/src/components" "$WORKDIR/packages/web/src/services" "$WORKDIR/packages/web/src/types"

echo "=== RUN todo-react-upgrade-micro ===" | tee "$REPORT"
(
  cd "$WORKDIR"
  "$OBORA_BIN" run "$ROOT/harnesses/long-running-apps/workflows/todo-react-upgrade-micro.yaml" \
    --config "$CONFIG" \
    --model glm-4.7 \
    --timeout 300000 \
    --debug
) >>"$REPORT" 2>&1 || true

echo >>"$REPORT"
echo "--- artifacts snapshot ---" >>"$REPORT"
find "$WORKDIR/artifacts" -maxdepth 3 -type f 2>/dev/null | sort >>"$REPORT" || true
echo "--- packages snapshot ---" >>"$REPORT"
find "$WORKDIR/packages" -maxdepth 6 -type f 2>/dev/null | sort >>"$REPORT" || true

echo "Report written to $REPORT"
