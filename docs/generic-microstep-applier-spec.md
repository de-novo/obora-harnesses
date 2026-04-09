# Generic Micro-Step Applier Spec

## 목표

이 spec은 `generic-microstep-change-engine` 이 생성한 `execution-batches.json` 과 `micro-units.json` 을 읽어,
실제 변경을 안전하게 적용하는 범용 applier를 정의한다.

핵심 목표:
- batch 단위로 매우 작게 적용한다.
- mode(create/modify/delete/refactor/restructure/prune)에 따라 안전 규칙을 다르게 적용한다.
- destructive action은 더 강한 보호 규칙을 갖는다.
- 적용 결과를 unit 단위로 기록한다.

---

## 입력

필수 입력:
- `artifacts/execution-batches.json`
- `artifacts/micro-units.json`
- `artifacts/phase-plan.md`
- `artifacts/goal-interpretation.md`
- `docs/microstep-phase-policy.md`

선택 입력:
- `artifacts/current-state.md`
- `artifacts/executor-preflight.json`
- `artifacts/impact-notes.md`

---

## 핵심 실행 원칙

### 1. Single-batch-first
- 한 번에 많은 batch를 적용하지 않는다.
- destructive batch는 반드시 단독 처리한다.
- broad batch는 허용하지 않는다.

### 2. Mode-aware apply

#### create
- 새 파일 생성
- 기존 파일 덮어쓰기 금지 unless explicit

#### modify
- surgical edit 우선
- 기존 의미 보존

#### delete / prune
- destructive
- impact note 필수
- 사전 안전성 확인 없으면 적용 금지

#### refactor / restructure
- 구조 변경과 내용 변경 분리
- 참조 무결성 확인 필수

#### audit
- 읽기 전용, apply 불가

#### migrate
- source/target 보존 검증 필요

---

## 필수 단계

### 1. Load Execution Inputs
- batches 로드
- units 로드
- 적용 순서 확인

### 2. Pre-Apply Safety Check
- destructive batches 식별
- impact note 누락 확인
- broad scope batch 차단

### 3. Apply Batches
각 batch마다:
- batch 시작 기록
- unit 적용
- batch validation 수행
- 성공/실패 기록

### 4. Failure Handling
- 429 → backoff 가능
- SDK_8002 → batch 더 축소 필요 기록
- validation 실패 → 다음 batch 진행 금지
- destructive failure → 즉시 중단

### 5. Final Summary
출력:
- applied batches
- failed batches
- skipped batches
- destructive actions performed
- next actions

---

## 출력

필수 산출물:
- `artifacts/apply-preflight.md`
- `artifacts/unit-results.json`
- `artifacts/apply-summary.md`

---

## 초기 현실적 제약

초기 버전 applier는 “모든 mode를 완전 자동 적용”보다,
우선 다음 수준으로 시작하는 것이 현실적이다.

### 초기 지원 범위
- create-ready batch 판정
- modify-ready batch 판정
- destructive batch 경고 및 보류
- apply order 정리
- 실제 적용 전 safety summary 생성

즉 초기 applier는 **full auto executor** 라기보다
**safe apply orchestrator** 에 가깝다.

이후 단계적으로 실제 create/modify/delete 적용 능력을 붙인다.
