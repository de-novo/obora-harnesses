# Modify-Safe v1 Spec

## 목표

safe create baseline 다음 단계로,
기존 파일에 대한 가장 보수적인 실제 자동 수정 경로를 연다.

초기 범위:
- single file only
- exact replace only (우선)
- no full rewrite
- no destructive behavior

---

## 입력

필수 입력:
- `artifacts/micro-units.json`
- `artifacts/apply-order.json`
- `docs/modify-safe-v1-policy.md`

선택 입력:
- `artifacts/current-state.md`
- `artifacts/execution-summary.md`

---

## 흐름

### 1. candidate filtering
- modify mode만 추출
- single-file unit만 유지
- applyStrategy = apply 만 유지
- 나머지 skip

### 2. patch intent derivation
- exact replace 가능한지 평가
- 불가능하면 hold/skip

### 3. patch validation
- replace target 명확성 확인
- broad rewrite 아님을 확인

### 4. real apply
- exact replace만 적용
- 실패 시 stop

### 5. summary
- modified/skipped/failed 기록

---

## 초기 제한

이 spec의 v1에서는 실제 변경 payload를 보수적으로 다룬다.
실제 system integration 전에는 다음 중 하나로 운영할 수 있다.

- modify-safe planner/orchestrator only
- 또는
- known-safe fixture 대상 exact replace only
