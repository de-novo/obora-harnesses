#!/bin/bash
# Obora Harness 공통 인증 처리
# auth.json 또는 환경 변수에서 인증 정보 로드

set -euo pipefail

# auth.json 경로
AUTH_JSON="${AUTH_JSON:-$HOME/.obora/auth.json}"

# Provider별 인증 로드
load_auth() {
  local provider="${1:-$OBORA_PROVIDER}"
  
  case "$provider" in
    zai)
      if [ -z "${ZAI_API_KEY:-}" ] && [ -f "$AUTH_JSON" ]; then
        ZAI_API_KEY=$(jq -r '.providers.zai.apiKey // empty' "$AUTH_JSON" 2>/dev/null || true)
        if [ -n "$ZAI_API_KEY" ]; then
          export ZAI_API_KEY
          echo "Loaded ZAI_API_KEY from auth.json"
        fi
      fi
      ;;
    anthropic)
      if [ -z "${ANTHROPIC_API_KEY:-}" ] && [ -f "$AUTH_JSON" ]; then
        ANTHROPIC_API_KEY=$(jq -r '.providers.anthropic.apiKey // empty' "$AUTH_JSON" 2>/dev/null || true)
        if [ -n "$ANTHROPIC_API_KEY" ]; then
          export ANTHROPIC_API_KEY
          echo "Loaded ANTHROPIC_API_KEY from auth.json"
        fi
      fi
      ;;
    openai|openai-codex)
      if [ -z "${OPENAI_API_KEY:-}" ] && [ -f "$AUTH_JSON" ]; then
        OPENAI_API_KEY=$(jq -r '.providers.openai.apiKey // empty' "$AUTH_JSON" 2>/dev/null || true)
        if [ -n "$OPENAI_API_KEY" ]; then
          export OPENAI_API_KEY
          echo "Loaded OPENAI_API_KEY from auth.json"
        fi
      fi
      ;;
    openrouter)
      if [ -z "${OPENROUTER_API_KEY:-}" ] && [ -f "$AUTH_JSON" ]; then
        OPENROUTER_API_KEY=$(jq -r '.providers.openrouter.apiKey // empty' "$AUTH_JSON" 2>/dev/null || true)
        if [ -n "$OPENROUTER_API_KEY" ]; then
          export OPENROUTER_API_KEY
          echo "Loaded OPENROUTER_API_KEY from auth.json"
        fi
      fi
      ;;
    *)
      echo "Unknown provider: $provider"
      ;;
  esac
}

# 인증 검증
check_auth() {
  local provider="${1:-$OBORA_PROVIDER}"
  
  case "$provider" in
    zai)
      [ -n "${ZAI_API_KEY:-}" ] || { echo "ZAI_API_KEY not set"; return 1; }
      ;;
    anthropic)
      [ -n "${ANTHROPIC_API_KEY:-}" ] || { echo "ANTHROPIC_API_KEY not set"; return 1; }
      ;;
    openai|openai-codex)
      [ -n "${OPENAI_API_KEY:-}" ] || { echo "OPENAI_API_KEY not set"; return 1; }
      ;;
    openrouter)
      [ -n "${OPENROUTER_API_KEY:-}" ] || { echo "OPENROUTER_API_KEY not set"; return 1; }
      ;;
    *)
      echo "Unknown provider: $provider"
      return 1
      ;;
  esac
  
  return 0
}
