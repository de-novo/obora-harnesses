# Plant Companion Scoped Dry-Run Plan

## 한줄 결론

`plant-companion`의 첫 dry-run은 `README.md`와 `docs/*.md` 중심의 docs-first low-risk lane으로 제한하는 것이 적절하다.

---

## Scoped Goal

README 및 docs 문서의 구조/표현 일관성을 점검하고,
low-risk modify review queue와 safe-create 보조 문서 후보를 도출한다.

---

## Include
- `README.md`
- `docs/architecture.md`
- `docs/local-smoke-flow.md`
- `docs/stack.md`

---

## Hold
- `apps/**`
- `device/**`
- `services/**`
- `packages/**`
- `scripts/**`
- `infra/**`
- runtime/config wiring

---

## Planned Phases

### Phase 1. Discovery
- root README 파악
- docs inventory
- hold zone 분리

### Phase 2. Interpretation
- docs wording/structure consistency 개선 과제로 분류
- modify + safe-create 혼합으로 분류

### Phase 3. Review Queue
- `README.md` review-ready
- `docs/*.md` 중 low-risk single-file candidates review-ready
- app/device/service/runtime 레이어 hold

### Phase 4. Safe-Create
- `docs/plant-companion-doc-consistency-report.md`
- `docs/plant-companion-structure-summary.md`

---

## Expected Proof Sequence

1. safe-create support docs
2. single-line exact replace in README/docs
3. small block replace in README/docs
4. paragraph-bounded replace in README/docs

---

## Success Criteria

- hold-zone 분리 유지
- safe-create 문서 1건 이상 생성
- exact-replace 후보 1건 이상 도출
- broad app/device/runtime 변경 없이 docs lane에서만 검증 진행
