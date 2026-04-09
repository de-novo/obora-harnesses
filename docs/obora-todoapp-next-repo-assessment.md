# Obora TodoApp — Next Real Repo Assessment

## 한줄 결론

`obora-todoapp`은 `polysona` 다음 baseline replication 대상으로 적합하다.

이유:
- root README 존재
- `docs/` 존재
- `scripts/` 존재
- `.obora/workflows/` 존재
- docs lane과 workflow/runtime lane을 구분하기 쉽다

---

## Why it fits the replication playbook

`polysona`에서 검증한 docs-first baseline을 재현하기 위해 필요한 요소가 있다.

### present
- user-facing README
- approved/final docs hierarchy
- script entrypoint
- workflow definitions
- clear architecture of doc outputs vs execution machinery

### likely safe lane
- `README.md`
- `docs/**/*.md`

### likely hold lane
- `.obora/**`
- `scripts/run-workflow.sh`
- `src/**`
- provider/config/runtime wiring

---

## Why this is a good next step

`polysona`는 mixed-surface repo였고,
`obora-todoapp`은 workflow/docs-heavy repo다.

즉 다음 검증 포인트로 좋다.
- docs-first lane이 더 명확한 repo에서도 baseline이 재현되는가
- workflow/config/harness 레이어를 hold로 분리할 수 있는가
- README/docs 중심 exact-replace + safe-create가 다시 작동하는가

---

## Recommended first dry-run scope

### include
- `README.md`
- `docs/**/*.md`

### hold
- `.obora/**`
- `scripts/run-workflow.sh`
- `src/**`
- runtime/provider config

---

## Expected proof sequence

1. safe-create support doc
2. exact-replace on README or docs file
3. small block replace in README/docs
4. paragraph-bounded replace in README/docs

---

## Recommendation

Proceed with `obora-todoapp` as the next real repo baseline replication target.
