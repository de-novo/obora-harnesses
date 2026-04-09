# Polysona Dry-Run Recommendation

## Recommendation

첫 실제 repo dry-run은 아래 범위로 제한하는 것이 가장 적절하다.

### Include
- `README.md`
- `README.ko.md`
- `skills/*/SKILL.md`
- `personas/default/*.md`

### Allow as safe-create outputs
- `docs/polysona-doc-consistency-report.md`
- `docs/polysona-structure-summary.md`

### Hold
- `AGENTS.md`
- `CLAUDE.md`
- `client/src/**`
- `server/**`
- `hooks/*.sh`

## Why

이 범위는:
- 구조 이해에 도움되고
- modify concretization 검증에 적합하며
- 실제 동작 리스크는 낮다

즉 현재 baseline에서 가장 현실적인 첫 실전 dry-run 범위다.
