#!/bin/bash
# Obora Harness 공통 결과 집계
# 표준화된 결과 포맷 생성

set -euo pipefail

source "$(dirname "$0")/env.sh"

# 결과 집계
generate_report() {
  local run_dir="$1"
  local harness_name="${2:-unknown}"
  
  local total=0
  local pass=0
  local fail=0
  local runtime_fail=0
  local quality_fail=0
  local infra_fail=0
  
  # 각 샘플 결과 수집
  local samples=()
  
  for status_file in "$run_dir"/*/status.txt; do
    [ -f "$status_file" ] || continue
    
    local sample_id=$(basename "$(dirname "$status_file")")
    local status=$(cat "$status_file" 2>/dev/null || echo "FAIL_UNKNOWN")
    
    total=$((total + 1))
    
    case "$status" in
      PASS)
        pass=$((pass + 1))
        ;;
      FAIL_RUNTIME|FAIL_*RUNTIME*)
        fail=$((fail + 1))
        runtime_fail=$((runtime_fail + 1))
        ;;
      FAIL_PATCH|FAIL_WRONG_TARGET|FAIL_NO_TARGET)
        fail=$((fail + 1))
        quality_fail=$((quality_fail + 1))
        ;;
      FAIL_CLONE|FAIL_FETCH|FAIL_CHECKOUT|FAIL_UNKNOWN)
        fail=$((fail + 1))
        infra_fail=$((infra_fail + 1))
        ;;
      *)
        fail=$((fail + 1))
        ;;
    esac
    
    # 샘플 메타데이터 수집
    local duration_ms=0
    local repair_count=0
    if [ -f "$run_dir/$sample_id/meta.json" ]; then
      duration_ms=$(jq -r '.duration_ms // 0' "$run_dir/$sample_id/meta.json" 2>/dev/null || echo 0)
      repair_count=$(jq -r '.repair_count // 0' "$run_dir/$sample_id/meta.json" 2>/dev/null || echo 0)
    fi
    
    samples+=("$(jq -n \
      --arg id "$sample_id" \
      --arg status "$status" \
      --argjson duration "$duration_ms" \
      --argjson repairs "$repair_count" \
      '{id: $id, status: $status, duration_ms: $duration, repair_count: $repairs}')")
  done
  
  # summary.json 생성
  local pass_rate="0%"
  if [ "$total" -gt 0 ]; then
    pass_rate="$((pass * 100 / total))%"
  fi
  
  local samples_json="[]"
  if [ ${#samples[@]} -gt 0 ]; then
    samples_json=$(printf '%s\n' "${samples[@]}" | jq -s '.')
  fi
  
  cat > "$run_dir/summary.json" <<EOF
{
  "harness": "$harness_name",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "provider": "$OBORA_PROVIDER",
  "model": "$OBORA_MODEL",
  "total": $total,
  "pass": $pass,
  "fail": $fail,
  "pass_rate": "$pass_rate",
  "failures": {
    "runtime": $runtime_fail,
    "quality": $quality_fail,
    "infra": $infra_fail
  },
  "samples": $samples_json
}
EOF

  # summary.tsv 생성
  cat > "$run_dir/summary.tsv" <<EOF
idx\tsample\tstatus\tduration_ms\trepair_count
EOF
  
  local idx=0
  for sample_json in "${samples[@]}"; do
    idx=$((idx + 1))
    local id=$(echo "$sample_json" | jq -r '.id')
    local status=$(echo "$sample_json" | jq -r '.status')
    local duration=$(echo "$sample_json" | jq -r '.duration_ms')
    local repairs=$(echo "$sample_json" | jq -r '.repair_count')
    printf '%d\t%s\t%s\t%s\t%s\n' "$idx" "$id" "$status" "$duration" "$repairs" >> "$run_dir/summary.tsv"
  done
  
  # 콘솔 출력
  echo ""
  echo "=== Final Results ==="
  echo "Harness: $harness_name"
  echo "Total: $total"
  echo "PASS: $pass"
  echo "FAIL: $fail"
  echo "Pass Rate: $pass_rate"
  echo ""
  echo "Failure Breakdown:"
  echo "  Runtime: $runtime_fail"
  echo "  Quality: $quality_fail"
  echo "  Infra: $infra_fail"
  echo ""
  echo "Results saved to: $run_dir"
}

# 간단한 요약 출력
print_summary() {
  local run_dir="$1"
  
  if [ -f "$run_dir/summary.json" ]; then
    echo "$(jq -r '[.total, .pass, .fail, .pass_rate] | @tsv' "$run_dir/summary.json")"
  fi
}
