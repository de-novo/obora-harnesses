# Obora Harnesses 고도화 설계

## 1. 현재 상태

### 1.1 실행 가능한 하네스

| 카테고리 | 상태 | 실행 확인 | 샘플 수 | 워크플로우 수 |
|----------|------|-----------|---------|---------------|
| swe-bench | ✅ 운영 | ✅ 1개 PASS | 300+ | 2 |
| long-running-apps | ✅ 운영 | ❌ 미확인 | - | 45 |
| pr-review | 📝 Skeleton | - | - | - |
| issue-triage | 📝 Skeleton | - | - | - |

### 1.2 발견된 문제점

1. **인증 하드코딩**: `run_repair_experiment.sh`에 ZAI_API_KEY 로직 하드코딩
2. **Provider/Model 전달**: workflow의 env var 표현식이 CLI에서 해석되지 않음
3. **Config 의존**: `config.yaml`의 defaults가 workflow agent 설정보다 우선하지 않음
4. **결과물 분산**: `results-repair`, `results-lite` 등 여러 디렉토리

---

## 2. 고도화 설계

### 2.1 아키텍처 개선

```
┌─────────────────────────────────────────┐
│           Harness Controller            │
│  (공통: 환경 설정, 인증, 결과 집계)      │
└─────────────────────────────────────────┘
                   │
    ┌──────────────┼──────────────┐
    ▼              ▼              ▼
┌────────┐   ┌──────────┐   ┌──────────┐
│swe-bench│   │long-run  │   │pr-review │
│        │   │   apps   │   │          │
└────────┘   └──────────┘   └──────────┘
```

### 2.2 공통 인터페이스 정의

모든 하네스는 다음 인터페이스를 구현:

```bash
# 환경 변수
export OBORA_PROVIDER="zai"          # 기본 provider
export OBORA_MODEL="glm-4.7"         # 기본 model
export OBORA_TIMEOUT_MS="240000"     # 기본 timeout
export HARNESS_OUTPUT_ROOT="./results" # 결과 출력 루트

# 실행
./harnesses/<category>/run.sh [options]

# 결과
./results/<category>/<timestamp>/
  ├── summary.json       # 전체 요약
  ├── runs/              # 개별 실행 결과
  └── logs/              # 실행 로그
```

### 2.3 공통 모듈 분리

```
harnesses/
  ├── _common/                    # 공통 모듈 (NEW)
  │   ├── env.sh                  # 환경 변수 로드
  │   ├── auth.sh                 # 인증 처리
  │   ├── run.sh                  # 공통 실행 래퍼
  │   └── report.sh               # 결과 집계
  ├── swe-bench/
  ├── long-running-apps/
  ├── pr-review/
  └── issue-triage/
```

### 2.4 실행 흐름 표준화

```bash
#!/bin/bash
# 모든 run.sh의 표준 구조

set -euo pipefail

# 1. 공통 환경 로드
source "$(dirname "$0")/../_common/env.sh"

# 2. 인증 설정
source "$(dirname "$0")/../_common/auth.sh"

# 3. 파라미터 파싱
SAMPLE_ARG=${1:-5}
PROVIDER=${OBORA_PROVIDER:-zai}
MODEL=${OBORA_MODEL:-glm-4.7}

# 4. 실행
run_harness() {
  local sample=$1
  local output_dir="$HARNESS_OUTPUT_ROOT/$TIMESTAMP/$sample"
  
  obora run "$WORKFLOW" \
    --provider "$PROVIDER" \
    --model "$MODEL" \
    --config "$CONFIG" \
    --output-dir "$output_dir"
}

# 5. 결과 집계
source "$(dirname "$0")/../_common/report.sh"
generate_report "$HARNESS_OUTPUT_ROOT/$TIMESTAMP"
```

---

## 3. 구현 계획

### Phase 1: 공통 모듈 생성
- [ ] `_common/env.sh`: 환경 변수 표준화
- [ ] `_common/auth.sh`: 인증 처리 통일
- [ ] `_common/run.sh`: 공통 실행 래퍼
- [ ] `_common/report.sh`: 결과 집계 포맷 표준화

### Phase 2: 기존 하네스 마이그레이션
- [ ] swe-bench: 공통 모듈 적용
- [ ] long-running-apps: 공통 모듈 적용
- [ ] pr-review: skeleton → 실제 구현
- [ ] issue-triage: skeleton → 실제 구현

### Phase 3: 고급 기능
- [ ] 병렬 실행 지원
- [ ] 중간 결과 캐싱
- [ ] 실패 시 자동 재시도 (백오프)
- [ ] 실시간 모니터링/대시보드

---

## 4. 결과물 포맷 표준화

### 4.1 디렉토리 구조

```
results/
  └── 2026-04-28-013015/
      ├── meta.json              # 실행 메타데이터
      ├── summary.json           # 전체 요약
      ├── summary.tsv            # TSV 형식 요약
      ├── runs/
      │   ├── astropy__astropy-12907/
      │   │   ├── status.txt     # PASS/FAIL
      │   │   ├── obora.log      # 전체 로그
      │   │   ├── edit.json      # 생성된 수정
      │   │   ├── patch.diff     # 최종 패치
      │   │   └── validation.json # 검증 결과
      │   └── ...
      └── logs/
          └── run.log            # 전체 실행 로그
```

### 4.2 summary.json 스키마

```json
{
  "harness": "swe-bench",
  "timestamp": "2026-04-28T01:30:15+09:00",
  "provider": "zai",
  "model": "glm-4.7",
  "total": 30,
  "pass": 28,
  "fail": 2,
  "pass_rate": "93.3%",
  "failures": {
    "runtime": 0,
    "quality": 2,
    "infra": 0
  },
  "duration_ms": 3600000,
  "samples": [
    {
      "id": "astropy__astropy-12907",
      "status": "PASS",
      "duration_ms": 77000,
      "repair_count": 0
    }
  ]
}
```

---

## 5. 테스트 전략

### 5.1 CI/CD 통합

```yaml
# .github/workflows/harness.yml
name: Harness Tests
on:
  schedule:
    - cron: '0 2 * * *'  # 매일 새벽 2시
  workflow_dispatch:

jobs:
  swe-bench-smoke:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run SWE-bench Smoke (5 samples)
        run: |
          export OBORA_PROVIDER=zai
          export OBORA_MODEL=glm-4.7
          ./harnesses/swe-bench/run.sh 5
      - name: Upload Results
        uses: actions/upload-artifact@v4
        with:
          name: swe-bench-results
          path: results/swe-bench/latest/
```

### 5.2 Smoke Test

```bash
#!/bin/bash
# smoke-test.sh - 빠른 검증

set -e

echo "=== Harness Smoke Test ==="

# 1. swe-bench: 1개 샘플
./harnesses/swe-bench/run.sh 1
assert_pass_rate 100

# 2. long-running-apps: todo-cli
./harnesses/long-running-apps/run.sh todo-cli-minimal
assert_artifact_exists "artifacts/output.js"

echo "=== All Smoke Tests Passed ==="
```

---

## 6. 모니터링 및 메트릭

### 6.1 수집 메트릭

| 메트릭 | 설명 | 단위 |
|--------|------|------|
| pass_rate | 통과율 | % |
| avg_duration | 평균 소요 시간 | ms |
| avg_repair_count | 평균 수정 횟수 | count |
| token_usage | 토큰 사용량 | tokens |
| cost_per_sample | 샘플당 비용 | USD |
| failure_distribution | 실패 유형 분포 | count |

### 6.2 알림 조건

- pass_rate < 80%: 경고
- pass_rate < 50%: 심각
- infra_fail > 5%: 인프라 문제 의심
- avg_duration > 5분: 타임아웃 조정 필요

---

## 7. 다음 액션

1. **공통 모듈 구현**: `_common/` 디렉토리 생성 및 기본 모듈 구현
2. **swe-bench 마이그레이션**: 공통 모듈 적용 및 검증
3. **long-running-apps 실행 테스트**: 실제 실행 확인
4. **pr-review/issue-triage 구현**: skeleton → 실제 하네스
5. **CI/CD 통합**: GitHub Actions workflow 작성

---

*작성일: 2026-04-28*
*작성자: obora-cto*
*버전: v1.0*
