# Baseline v1.1

## 한줄 결론

Baseline v1.1 is now **cross-repo replicated**.

검증 대상:
- `polysona`
- `obora-todoapp`
- `plant-companion`

v1.1의 핵심은:
- docs-first low-risk lane 안에서
- **multi-paragraph bounded replace** 를 실제 repo에 적용하고
- re-read verification까지 마치는 것

즉 Baseline v1.1은 이제 first proof가 아니라,
**3개 실제 repo에서 재현된 다음 단계 baseline** 이다.

---

## Relationship to Baseline v1

### Baseline v1
- safe-create support docs
- exact-replace
- small block replace
- paragraph-bounded replace

### Baseline v1.1
- all of v1, plus
- **multi-paragraph bounded replace**

즉 v1.1은 v1의 문서 수정 gradient를 한 단계 더 넓힌 버전이다.

---

## Repo Proofs

## 1. polysona
### proof
- README opening multi-paragraph block refined

### meaning
mixed-surface repo에서도 multi-paragraph bounded replace가 가능함을 증명.

---

## 2. obora-todoapp
### proof
- `docs/architecture/ARCHITECTURE-v1.md` ADR block multi-paragraph refinement

### meaning
workflow/docs-heavy repo에서도 multi-paragraph bounded replace가 가능함을 증명.

---

## 3. plant-companion
### proof
- README opening multi-paragraph block refined

### meaning
product/app/device/service monorepo에서도 docs-first lane 안에서 같은 proof가 재현됨을 증명.

---

## Current Proven Boundary

Baseline v1.1에서 과장 없이 말할 수 있는 범위:

- single-file only
- docs-first low-risk lane only
- contiguous bounded text blocks only
- wording refinement only
- no semantic expansion baseline
- re-read verification required

---

## Still Out of Scope

다음은 아직 Baseline v1.1 범위 밖이다.

- multi-file batching
- section-level semantic rewrite
- code/runtime modify
- workflow/config modify
- hooks/scripts with execution impact
- rollback-aware execution

---

## Why v1.1 matters

v1이 문서층의 conservative modify baseline을 세웠다면,
v1.1은 그 baseline이 **한 문단을 넘는 bounded block** 까지도 확장 가능함을 보여준다.

즉 broad rewrite로 바로 가지 않고,
다음과 같은 gradient가 현실적으로 작동한다는 뜻이다.

1. exact replace
2. small block replace
3. paragraph replace
4. multi-paragraph bounded replace

이 gradient가 이제 3개 실제 repo에서 재현되었다.

---

## Recommended next move

다음 단계는 Baseline v1.2를 정의하는 것이다.

가장 자연스러운 후보:
- multi-file docs batching
- 또는 section-level bounded semantic rewrite

단, 둘 다 아직 Baseline v1.1 이후의 범위다.

---

## Final Statement

> Baseline v1.1 is established as a cross-repo, docs-first, low-risk execution pattern that adds multi-paragraph bounded replace on top of Baseline v1.
