#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../_common/env.sh"
source "$SCRIPT_DIR/../_common/auth.sh"
source "$SCRIPT_DIR/../_common/run.sh"
source "$SCRIPT_DIR/../_common/report.sh"

# 인증 로드
load_auth

# 파라미터
TASK_DESCRIPTION="${1:-Implement a simple REST API with user management}"
MAX_ITERATIONS="${MAX_ITERATIONS:-20}"
WORKFLOW="${WORKFLOW:-$SCRIPT_DIR/workflows/ralph-loop.yaml}"
CONFIG="${CONFIG:-$SCRIPT_DIR/configs/obora/config.yaml}"

# 실행 디렉토리 설정
RUN_DIR=$(ensure_run_dir "ralph-loop")
write_meta "$RUN_DIR" "ralph-loop"

log_info "Ralph Loop Harness"
log_info "Task: $TASK_DESCRIPTION"
log_info "Max Iterations: $MAX_ITERATIONS"
log_info "Provider: $OBORA_PROVIDER"
log_info "Model: $OBORA_MODEL"
log_info "Output: $RUN_DIR"

# 작업 공간 준비
WORK_DIR="$RUN_DIR/workspace"
mkdir -p "$WORK_DIR"
mkdir -p "$WORK_DIR/artifacts/.ralph"

# 초기 가드레일 생성
cat > "$WORK_DIR/artifacts/.ralph/guardrails.md" <<'EOF'
# Ralph Loop Guardrails

## Core Rules
1. ALWAYS read progress.md before taking any action
2. ALWAYS update progress.md after completing an action
3. NEVER reference previous conversation turns - they don't exist in context
4. Keep file operations atomic - write to temp then rename

## Failure Patterns
- If "file not found" after creation: check relative path from workspace root
- If "permission denied": use fs.chmod or check directory permissions
- If "module not found": check package.json and run npm install
EOF

# 초기 진행 상황 생성
cat > "$WORK_DIR/artifacts/.ralph/progress.md" <<EOF
# Ralph Loop Progress
## Task: $TASK_DESCRIPTION
## Status: IN_PROGRESS
## Attempt: 0
## Last Action: Setup complete, ready to start
EOF

# 랄프 루프 실행 (10회 목표)
ITERATION=0
PASSED=false
COMPLETION_RATE=0

while [ $ITERATION -lt 10 ] && [ "$PASSED" = false ]; do
  ITERATION=$((ITERATION + 1))
  log_info "=== Iteration $ITERATION/10 ==="

  # 토큰 사용량 체크 (60% 이상이면 컨텍스트 교체)
  TOKEN_USAGE=$(cat "$WORK_DIR/artifacts/.ralph/token_usage.json" 2>/dev/null | jq -r '.usage // 0' || echo "0")
  if [ "$TOKEN_USAGE" -gt 60 ]; then
    log_info "🔄 Context rotation at ${TOKEN_USAGE}%"
    # 컨텍스트 교체 표시
    echo '{"rotated": true, "at_iteration": '$ITERATION'}' > "$WORK_DIR/artifacts/.ralph/context_rotation.json"
  fi

  # 환경 변수 설정
  export TASK_DESCRIPTION
  export ATTEMPT_COUNT=$ITERATION

  # Obora 실행
  ITERATION_DIR="$RUN_DIR/iteration-$ITERATION"
  mkdir -p "$ITERATION_DIR"

  if run_obora "$WORKFLOW" "$CONFIG" "$ITERATION_DIR" "$OBORA_TIMEOUT_MS"; then
    # 결과 검증
    if [ -f "$ITERATION_DIR/validation.json" ]; then
      if jq -e '.passed == true' "$ITERATION_DIR/validation.json" >/dev/null 2>&1; then
        PASSED=true
        log_info "✅ Task completed at iteration $ITERATION"
      else
        # 가드레일 업데이트
        GUARDRAIL=$(jq -r '.guardrail_suggestion // empty' "$ITERATION_DIR/validation.json" 2>/dev/null || true)
        if [ -n "$GUARDRAIL" ]; then
          echo "" >> "$WORK_DIR/artifacts/.ralph/guardrails.md"
          echo "## Iteration $ITERATION" >> "$WORK_DIR/artifacts/.ralph/guardrails.md"
          echo "$GUARDRAIL" >> "$WORK_DIR/artifacts/.ralph/guardrails.md"
          log_info "📝 Guardrail updated"
        fi
      fi
    fi
  else
    log_warn "❌ Iteration $ITERATION failed"
  fi

  # 진행 상황 업데이트
  cat > "$WORK_DIR/artifacts/.ralph/progress.md" <<EOF
# Ralph Loop Progress
## Task: $TASK_DESCRIPTION
## Status: $([ "$PASSED" = true ] && echo "COMPLETED" || echo "IN_PROGRESS")
## Attempt: $ITERATION
## Last Action: $([ "$PASSED" = true ] && echo "Task completed" || echo "Iteration $ITERATION executed")
EOF

  sleep 2
done

# 결과 집계 (10회 기준)
if [ "$PASSED" = true ]; then
  echo "PASS" > "$RUN_DIR/status.txt"
  log_info "✅ 10회 내 완료 (실제 반복: $ITERATION)"
else
  echo "FAIL_10_ITERATIONS" > "$RUN_DIR/status.txt"
  log_info "❌ 10회 내 미완료"
fi

# 메트릭 저장
cat > "$RUN_DIR/metrics.json" <<EOF
{
  "task": "$TASK_DESCRIPTION",
  "iterations_used": $ITERATION,
  "iterations_target": 10,
  "passed": $PASSED,
  "completion_rate": $COMPLETION_RATE,
  "context_rotations": $(ls "$WORK_DIR/artifacts/.ralph/context_rotation.json" 2>/dev/null | wc -l | tr -d ' '),
  "guardrail_count": $(grep -c "^##" "$WORK_DIR/artifacts/.ralph/guardrails.md" 2>/dev/null || echo 0)
}
EOF

generate_report "$RUN_DIR" "ralph-loop"

# 심볼릭 링크
ln -sfn "$RUN_DIR" "$HARNESS_OUTPUT_ROOT/ralph-loop/latest"

log_info "Done. Results: $RUN_DIR"
