# Generic Micro-Step Executor Spec

## 목표

이 spec은 `generic-microstep-builder`가 생성한 `micro-units.json`을 실제로 적용하는 범용 실행 엔진을 정의한다.

핵심 목표:
- 사람은 요구사항과 workflow만 실행한다.
- planner는 phase/units를 만든다.
- executor는 units를 순차 적용한다.
- create / modify / delete / refactor / restructure / prune 를 안전하게 처리한다.

---

## 입력

executor는 최소 아래를 입력으로 사용한다.

- `artifacts/micro-units.json`
- `artifacts/phase-plan.md`
- `artifacts/goal-interpretation.md`
- `docs/microstep-phase-policy.md`

선택 입력:
- `artifacts/current-state.md`
- `artifacts/impact-notes.md`

---

## 실행 원칙

### 1. unit-by-unit execution
- 한 번에 전체를 실행하지 않는다.
- unit 하나씩 순차 적용한다.
- 실패하면 해당 unit에서 중단하고 기록한다.

### 2. mode-aware execution
각 unit은 `mode`에 따라 다른 적용 규칙을 가진다.

#### create
- 새 파일 생성 중심
- broad scope 금지

#### modify
- 기존 파일 일부 수정 중심
- 가능한 surgical edit 우선

#### delete / prune
- destructive action
- impact note와 validation이 있어야 함
- 참조 안전성 없으면 중단

#### refactor / restructure
- 구조 변경과 내용 변경을 가능하면 분리
- rename/move는 영향 확인 후 적용

#### audit
- 읽기 전용
- 적용 단계가 아니라 검증/기록 단계

#### migrate
- source→target 전이
- 단계별 보존 검증 필요

---

## 필수 실행 단계

### 1. Load Plan
- micro-units.json 읽기
- 실행 가능한 unit 목록 확인

### 2. Preflight Check
- destructive unit 존재 여부 확인
- impactNotes 누락 여부 확인
- broad unit 존재 여부 확인

### 3. Execute Units
각 unit마다:
- unit 시작 기록
- 적용
- unit validation 수행
- 성공/실패 기록

### 4. Failure Handling
- 429 → backoff 후 해당 unit 재시도 가능
- SDK_8002 → 해당 unit scope 축소 필요로 기록
- validation 실패 → 다음 unit 진행 금지

### 5. Final Summary
- executed units
- failed units
- skipped units
- destructive actions performed
- next actions

---

## 출력

필수 산출물:
- `artifacts/execution-log.md`
- `artifacts/unit-results.json`
- `artifacts/execution-summary.md`

---

## Anti-Patterns

- 전체 unit을 한 step에 실행
- destructive action을 preflight 없이 실행
- modify와 refactor를 한 unit에 과도하게 혼합
- validation 없이 다음 unit으로 진행

---

## 현실적 제약

현재 Obora 특성상,
실제 executor도 broad execution을 피해야 한다.
따라서 executor는 처음부터 “모든 unit 실제 적용”까지 한 번에 하기보다,
다음 둘 중 하나로 설계할 수 있다.

1. **planner-executor hybrid**
   - unit 적용 지시까지 포함하되 매우 작은 scope만 처리

2. **executor-assisted mode**
   - unit을 한 개 또는 몇 개씩 순차 실행하도록 반복 호출되는 구조

초기 버전은 2번이 더 현실적일 수 있다.
