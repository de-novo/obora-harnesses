# Baseline v1.2

## 한줄 결론

Baseline v1.2 is now **cross-repo established**.

검증 대상:
- `polysona`
- `obora-todoapp`
- `plant-companion`

v1.2의 핵심은:
- docs-first low-risk lane 안에서
- **2-file docs batching** 을 실제 repo에 적용하고
- 각 파일별 re-read verification까지 마치는 것이다.

즉 Baseline v1.2는 이제 draft가 아니라,
**3개 실제 repo에서 재현된 다음 단계 baseline** 이다.

---

## Relationship to prior baselines

### Baseline v1
- safe-create support docs
- exact-replace
- small block replace
- paragraph-bounded replace

### Baseline v1.1
- all of v1
- multi-paragraph bounded replace

### Baseline v1.2
- all of v1.1
- **2-file docs batching**

즉 v1.2는 single-file bounded modify를 넘어,
같은 low-risk documentation lane 안에서 두 파일을 함께 다루는 첫 established 단계다.

---

## Repo Proofs

## 1. polysona
### proof
- `README.md` + `README.ko.md` 2-file wording batch

### meaning
bilingual user-facing doc pair도 같은 low-risk posture로 묶어 적용 가능함을 증명.

---

## 2. plant-companion
### proof
- `docs/architecture.md` + `docs/stack.md` 2-file docs batch

### meaning
architecture/stack note pair처럼 역할이 다른 문서도 docs-first lane 안에서 batching 가능함을 증명.

---

## 3. obora-todoapp
### proof
- `docs/prd/PRD-v1.md` + `docs/plan/SPRINT-PLAN-v1.md` 2-file docs batch

### meaning
workflow/docs-heavy repo의 approved docs pair도 같은 batching posture로 적용 가능함을 증명.

---

## Current Proven Boundary

Baseline v1.2에서 과장 없이 말할 수 있는 범위:

- docs-first low-risk lane only
- maximum 2 files in a batch
- each file remains bounded and independently reviewable
- wording/clarity/label refinement only
- no semantic expansion baseline
- re-read verification required for all touched files

---

## Still Out of Scope

다음은 아직 Baseline v1.2 범위 밖이다.

- 3+ file batching
- section-level semantic rewrite
- workflow/config/runtime modify
- code/runtime modify
- hooks/scripts with execution impact
- rollback-aware batched execution

---

## Why v1.2 matters

v1과 v1.1이 single-file gradient를 확립했다면,
v1.2는 그 gradient를 **controlled execution breadth** 쪽으로 확장했다.

즉 다음이 현실적으로 가능함을 보여준다.
- 같은 low-risk lane 안에서
- 두 파일을 함께 처리하되
- 각 파일의 risk posture는 여전히 bounded하게 유지

---

## Recommended next move

다음 단계는 Baseline v1.3를 정의하는 것이다.

가장 자연스러운 후보:
- **3-file docs batching**

이유:
- semantic depth보다 execution breadth를 한 단계 더 넓히는 것이 현재 gradient와 가장 자연스럽게 연결된다.

---

## Final Statement

> Baseline v1.2 is established as a cross-repo, docs-first, low-risk execution pattern that adds two-file docs batching on top of Baseline v1.1.
