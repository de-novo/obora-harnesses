#!/bin/bash
# Obora Harness 공통 환경 설정
# 모든 하네스 스크립트에서 source하여 사용

set -euo pipefail

# 스크립트 위치 기준 경로 계산
_COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_ROOT="$(cd "$_COMMON_DIR/.." && pwd)"
REPO_ROOT="$(cd "$_COMMON_DIR/../.." && pwd)"

# 기본 환경 변수
export OBORA_PROVIDER="${OBORA_PROVIDER:-zai}"
export OBORA_MODEL="${OBORA_MODEL:-glm-4.7}"
export OBORA_TIMEOUT_MS="${OBORA_TIMEOUT_MS:-240000}"
export OBORA_MAX_RETRIES="${OBORA_MAX_RETRIES:-3}"

# 출력 디렉토리
HARNESS_OUTPUT_ROOT="${HARNESS_OUTPUT_ROOT:-$REPO_ROOT/results}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
RUN_DIR="$HARNESS_OUTPUT_ROOT/$TIMESTAMP"

# Obora CLI
OBORA_BIN="${OBORA_BIN:-obora}"

# 유틸리티 함수
log_info() {
  echo "[INFO] $*" >&2
}

log_warn() {
  echo "[WARN] $*" >&2
}

log_error() {
  echo "[ERROR] $*" >&2
}

# 결과 디렉토리 생성
ensure_run_dir() {
  local harness_name="${1:-unknown}"
  local dir="$RUN_DIR/$harness_name"
  mkdir -p "$dir"
  echo "$dir"
}

# 메타데이터 작성
write_meta() {
  local output_dir="$1"
  local harness_name="${2:-unknown}"
  
  cat > "$output_dir/meta.json" <<EOF
{
  "harness": "$harness_name",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "provider": "$OBORA_PROVIDER",
  "model": "$OBORA_MODEL",
  "timeout_ms": $OBORA_TIMEOUT_MS,
  "max_retries": $OBORA_MAX_RETRIES,
  "obora_bin": "$OBORA_BIN"
}
EOF
}

export HARNESS_ROOT
export REPO_ROOT
export HARNESS_OUTPUT_ROOT
export TIMESTAMP
export RUN_DIR
export OBORA_BIN