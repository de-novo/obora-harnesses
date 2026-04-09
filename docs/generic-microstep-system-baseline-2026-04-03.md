# Generic Micro-Step System Baseline — 2026-04-03

## 한줄 결론

현재 Generic Micro-Step System은 다음까지 **실제 검증 완료** 상태다.

- 정책 기반 phase planning
- change mode 분류
- impact-aware micro-unit planning
- execution batch planning
- safe apply orchestration
- **safe create (new-file-only) 실제 write**

즉, 이 시스템은 더 이상 개념 설계가 아니라,
**제한된 범위에서 실제 변경을 적용할 수 있는 baseline** 에 도달했다.

---

## 목표

이 문서는 2026-04-03 시점의 Generic Micro-Step System capability baseline을 고정한다.

목적:
1. 지금까지 검증된 범위를 명확히 남긴다.
2. 무엇이 실제 가능하고 무엇이 아직 불가한지 구분한다.
3. 이후 확장(modify-safe, prune-safe 등)의 기준선을 제공한다.

---

## 구성 요소

### 정책 문서
- `docs/microstep-phase-policy.md`
- `docs/generic-microstep-workflow-spec.md`
- `docs/generic-microstep-executor-spec.md`
- `docs/generic-microstep-applier-spec.md`
- `docs/safe-create-auto-apply-policy.md`
- `docs/real-safe-create-v1-policy.md`
- `docs/real-safe-create-v1_1-policy.md`

### workflow
- `harnesses/long-running-apps/workflows/generic-microstep-builder.yaml`
- `harnesses/long-running-apps/workflows/generic-microstep-change-engine.yaml`
- `harnesses/long-running-apps/workflows/generic-microstep-applier.yaml`
- `harnesses/long-running-apps/workflows/generic-microstep-applier-safe-create.yaml`
- `harnesses/long-running-apps/workflows/generic-microstep-applier-real-safe-create-v1.yaml`
- `harnesses/long-running-apps/workflows/generic-microstep-applier-real-safe-create-v1_1.yaml`

---

## 검증된 capability

## 1. Dynamic Phase Planning
시스템은 요구사항과 정책 문서를 읽고,
고정 phase가 아니라 **동적으로 선택된 phase plan** 을 생성할 수 있다.

검증된 내용:
- discovery 포함 여부 판단
- research 포함 여부 판단
- targeted modification / prune / refactor phase 선택
- skipped phase 기록
- expansion / reduction decisions 기록

상태: **검증 완료**

---

## 2. Change Mode Classification
시스템은 기존 프로젝트 작업을 다음과 같이 해석할 수 있다.

- create
- modify
- delete
- refactor
- restructure
- audit
- migrate
- prune

검증된 내용:
- 기존 repo 개선 요청을 mixed mode (modify/refactor/prune) 로 분류
- 위험도 HIGH 판정
- destructive risk 인식

상태: **검증 완료**

---

## 3. Impact-Aware Micro-Unit Planning
시스템은 broad task를 매우 작은 work unit으로 분해할 수 있다.

검증된 내용:
- unit당 작은 목표 유지
- `mode` 포함
- `impactNotes` 포함
- destructive change에 high-risk annotation 부여
- execution rules 생성

상태: **검증 완료**

---

## 4. Safe Evaluation by Micro-Steps
broad evaluator는 실패했지만,
검증을 분해하자 안정적으로 성공했다.

검증된 패턴:
- `validate_phase_selection`
- `validate_unit_scope`
- `validate_impact_annotations`
- `summarize_plan`

상태: **검증 완료**

핵심 원칙:
> evaluator/applier도 broad step이면 안 된다.
> 검증 역시 micro-step이어야 한다.

---

## 5. Safe Apply Orchestration
시스템은 micro-units와 execution batches를 읽고,
다음 분류를 만들 수 있다.

- apply
- prepare
- hold

또한 아래 검증을 병렬로 수행할 수 있다.
- destructive batch 탐지
- impact note 검증
- mode safety 검증
- batch scope 검증

상태: **검증 완료**

---

## 6. Real Safe Create v1.1
현재 시점에서 실제 auto-apply는 가장 제한된 형태로만 허용된다.

허용 조건:
1. mode = create
2. target file = exactly one
3. target file does not exist
4. overwrite = false
5. destructive/high-risk 아님
6. applyStrategy = apply

실제 검증 결과:
- 새 파일 10개 실제 생성 성공
- overwrite 0건
- skipped 0건

상태: **실제 검증 완료**

---

## 아직 불가 / 미검증 범위

다음은 아직 baseline에 포함하지 않는다.

### 1. modify-safe 실제 적용
- 기존 파일 수정
- section-level patch
- exact replacement

상태: **미구현 / 미검증**

### 2. delete / prune 실제 적용
- 실제 삭제 수행
- 참조 끊김 검증 포함

상태: **미구현 / 미검증**

### 3. refactor / restructure 실제 적용
- rename
- move
- split / merge
- reference rewrite

상태: **미구현 / 미검증**

### 4. migrate 실제 적용
- source/target 동시 보존 검증
- 점진 전환 적용

상태: **미구현 / 미검증**

### 5. rollback-aware real apply
- write 이후 rollback
- partial failure recovery

상태: **미구현 / 미검증**

---

## 운영 원칙 baseline

지금 시점에서 반드시 지켜야 하는 운영 원칙은 아래와 같다.

1. broad workflow 금지
2. broad evaluator 금지
3. broad safety step 금지
4. micro-unit 우선
5. 독립 검증은 병렬 가능
6. destructive action은 hold 기본값
7. real auto-apply는 safe create new-file-only 부터 시작
8. overwrite 금지
9. 실패를 수동 성공으로 덮지 않음

---

## 아키텍처 결론

현재 가장 안정적인 구조는 다음이다.

### Layer 1: Policy
- phase selection rules
- expansion/reduction rules
- destructive safeguards

### Layer 2: Change Engine
- goal interpretation
- discovery
- phase planning
- micro-unit derivation
- execution batch derivation

### Layer 3: Applier
- apply safety checks
- apply/prepare/hold 분류
- limited real auto-apply

즉 single giant workflow가 아니라,
**policy-driven layered system** 이 baseline 아키텍처다.

---

## 다음 확장 우선순위

### Priority 1
- modify-safe v1
- existing file exact replace / section-level safe patch

### Priority 2
- prune-safe planning 강화
- destructive verification 심화

### Priority 3
- refactor/restructure apply support

### Priority 4
- rollback-aware execution

---

## 최종 결론

2026-04-03 기준 Generic Micro-Step System은 다음을 달성했다.

> **정책 기반으로 작업을 동적으로 분해하고,
> 안전한 create(new-file-only)에 대해서는 실제로 적용 가능한 수준의 baseline**

이 baseline은 이후 modify/delete/refactor/migrate 확장의 기준점으로 사용한다.
