# Next Real Repo Candidate Criteria

## Goal

`polysona` 다음 실제 repo를 고를 때,
어떤 종류의 저장소가 baseline replication에 적합한지 기준을 남긴다.

---

## Best-fit repo profile

다음 특징을 가진 repo가 가장 좋다.

- user-facing README quality가 중요함
- docs / guides / protocol files 존재
- code도 있지만 docs lane이 분리 가능함
- low-risk wording/clarity 수정 후보가 존재함
- broad product/runtime rewrite 없이도 검증 가치가 있음

---

## Good candidate examples

- agent/tooling repo with docs + config + scripts
- OSS project with substantial README/docs but moderate code complexity
- workflow/toolkit repo with onboarding/usage guides

---

## Poor candidate examples

- library repo with only source code and 거의 no docs
- monorepo where docs lane is buried behind large app/runtime changes
- generated artifact dump
- highly coupled infra repo without low-risk doc surface

---

## What to inspect first

1. root files (`README`, `CHANGELOG`, `CONTRIBUTING`)
2. docs directories
3. protocol/instruction docs
4. scripts/hooks presence
5. whether hold zones can be cleanly separated

---

## Recommendation

다음 실제 repo는 `polysona`보다 약간 더 code-heavy여도 괜찮지만,
반드시 **docs-first lane이 분리 가능한 repo** 여야 한다.
