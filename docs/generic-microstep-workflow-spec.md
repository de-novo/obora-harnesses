# Generic Micro-Step Workflow Spec

## 목표

이 spec은 특정 Todo/React 전용이 아니라,
어떤 요구사항이 들어와도 재사용 가능한 Obora workflow 구조를 정의한다.

사람의 인터페이스는 단순해야 한다.
- 입력: 요구사항
- 실행: workflow 하나
- 출력: 실행 결과 + artifacts

그리고 이 workflow는 **신규 생성뿐 아니라 기존 프로젝트의 수정/삭제/개선/재구성**도 다뤄야 한다.

---

## Workflow Contract

## Input
workflow는 최소 아래 입력을 받아야 한다.

```json
{
  "goal": "what to build or change",
  "context": "optional repo/module context",
  "constraints": ["..."],
  "successCriteria": ["..."]
}
```

## Output
workflow는 최소 아래를 생성해야 한다.
- goal interpretation
- phase plan
- micro unit plan
- result artifacts
- execution summary

---

## Change Engine Model

이 workflow는 단순 builder가 아니라 **change engine** 이어야 한다.

즉 아래 change mode를 지원해야 한다.
- create
- modify
- delete
- refactor
- restructure
- audit
- migrate
- prune

---

## Required Stages Inside the Workflow

### 0. Discover Current State
기존 프로젝트를 다루는 경우 현재 상태를 읽는다.

Outputs:
- `artifacts/current-state.md`
- 필요 시 `artifacts/impact-notes.md`

### 1. Interpret Goal
- goal/context/constraints/successCriteria 해석
- 작업 유형 분류
- change mode 분류

Output:
- `artifacts/goal-interpretation.md`

### 2. Read Phase Policy
- `docs/microstep-phase-policy.md` 를 읽는다

### 3. Build Phase Plan
- selected phases
- skipped phases
- expansion/reduction decisions
- destructive action notes

Output:
- `artifacts/phase-plan.md`

### 4. Build Micro Unit Plan
- phase별 micro execution units 생성
- 각 unit은 scope가 매우 작아야 한다

Output:
- `artifacts/micro-units.json`

### 5. Execute Units Sequentially
- create/modify/delete/refactor/restructure 를 unit 단위로 실행
- 실패 시 broad retry 금지
- SDK_8002면 더 작은 unit으로 재분해 가능해야 함
- 429면 backoff 가능해야 함

### 6. Validate Impact
특히 modify/delete/refactor/restructure 에서 중요하다.

Check examples:
- 참조가 깨지지 않았는가
- 삭제 대상이 truly obsolete 인가
- 기존 의미가 유지되는가
- expected files/content가 맞는가

### 7. Evaluate Result
- success criteria 충족 여부
- required outputs 존재 여부
- policy 위반 여부

### 8. Summarize Delivery
Output:
- `artifacts/execution-summary.md`

필수 포함:
- selected phases
- change mode
- executed units
- failed units
- skipped units
- next actions

---

## Micro Unit Schema

```json
{
  "id": "u1",
  "phase": "setup",
  "mode": "modify",
  "goal": "update package metadata",
  "targetFiles": ["package.json"],
  "constraints": ["max 2 files"],
  "validation": ["file updated correctly"]
}
```

추가 규칙:
- `mode` 필드는 필수
- delete/restructure unit은 impact note 필요 가능

---

## Runtime Rules

### Unit Scope
- 한 unit당 책임 1개
- 파일 1~2개 권장
- 많아도 3개 이내
- destructive unit은 가능한 1파일 단위

### Failure Handling
- 429 → backoff
- SDK_8002 → unit 축소
- repeated failure → phase 재분해 필요 표시
- delete failure → 즉시 중단 후 summary 기록

### Evaluation Rule
- 구현 step과 평가 step은 분리
- 평가 output은 작고 엄격하게

---

## Existing Project Support Requirements

이 workflow는 반드시 아래를 지원해야 한다.

### 문서 수정
- section 단위 수정
- obsolete block 제거
- 문서 구조 개선

### 문서 삭제
- 참조 확인
- 삭제 근거 기록
- 대체 문서 확인 가능하면 수행

### 코드 리팩터링
- 기존 동작 유지
- 구조 분리
- impact 확인

### 구조 개편
- move/rename/split/merge
- 참조 무결성 확인

---

## Anti-Patterns

- broad "implement whole feature" unit
- 조사 + 구현 + 평가를 한 unit에 혼합
- phase를 고정 pipeline처럼 강제
- domain-specific file names를 workflow 구조에 고정
- delete를 modify처럼 가볍게 취급
- 수동 성공을 workflow 성공처럼 취급

---

## Desired End State

이 spec을 만족하는 workflow는:
1. 단일 진입점이다
2. phase는 동적으로 선택된다
3. 내부는 micro-step으로 동작한다
4. create/modify/delete/refactor/restructure 를 지원한다
5. 다양한 작업에 재사용 가능하다
6. SDK_8002/429 같은 문제에 대해 운영적으로 강하다
