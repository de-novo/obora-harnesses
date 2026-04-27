#!/bin/bash
# Obora Harness 공통 실행 래퍼
# 표준화된 실행 흐름 제공

set -euo pipefail

source "$(dirname "$0")/env.sh"
source "$(dirname "$0")/auth.sh"

# Obora 실행 (재시도 로직 포함)
run_obora() {
  local workflow="$1"
  local config="${2:-}"
  local output_dir="${3:-}"
  local timeout="${4:-$OBORA_TIMEOUT_MS}"
  
  local cmd=("$OBORA_BIN" run "$workflow")
  
  # Provider/Model 플래그
  if [ -n "$OBORA_PROVIDER" ]; then
    cmd+=(--provider "$OBORA_PROVIDER")
  fi
  if [ -n "$OBORA_MODEL" ]; then
    cmd+=(--model "$OBORA_MODEL")
  fi
  
  # Config
  if [ -n "$config" ]; then
    cmd+=(--config "$config")
  fi
  
  # Output
  if [ -n "$output_dir" ]; then
    cmd+=(--output-dir "$output_dir")
  fi
  
  # Timeout
  if [ -n "$timeout" ]; then
    cmd+=(--timeout "$timeout")
  fi
  
  # 실행
  local attempt=1
  local max_attempts="${OBORA_MAX_RETRIES:-3}"
  
  while [ $attempt -le $max_attempts ]; do
    log_info "Obora run attempt $attempt/$max_attempts"
    
    if "${cmd[@]}"; then
      return 0
    fi
    
    local exit_code=$?
    log_warn "Obora run failed (exit: $exit_code), attempt $attempt/$max_attempts"
    
    # 특정 오류는 재시도
    if [ $attempt -lt $max_attempts ]; then
      local sleep_secs=$((attempt * 10))
      log_info "Retrying in ${sleep_secs}s..."
      sleep $sleep_secs
    fi
    
    attempt=$((attempt + 1))
  done
  
  return 1
}

# Workflow 검증 (dry-run)
validate_workflow() {
  local workflow="$1"
  local config="${2:-}"
  
  local cmd=("$OBORA_BIN" run "$workflow" --dry-run)
  
  if [ -n "$config" ]; then
    cmd+=(--config "$config")
  fi
  
  if [ -n "$OBORA_PROVIDER" ]; then
    cmd+=(--provider "$OBORA_PROVIDER")
  fi
  if [ -n "$OBORA_MODEL" ]; then
    cmd+=(--model "$OBORA_MODEL")
  fi
  
  log_info "Validating workflow: $workflow"
  "${cmd[@]}"
}
