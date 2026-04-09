# Baseline v1.3 Proof Plan

## Goal

Validate the first **3-file docs batch** under the same low-risk execution posture.

## First recommended proof

### Repo
- `plant-companion`

### Files
- `docs/architecture.md`
- `docs/stack.md`
- `docs/local-smoke-flow.md`

### Why this trio
- same docs-first lane
- no runtime layer touch
- each file already looks like a bounded wording candidate surface
- trio still small enough to verify manually by re-read

## Constraints
- max 3 files
- max 1 bounded change per file in first proof
- no semantic expansion
- re-read all three files after apply

## Success condition
- 3-file batch applied successfully
- all three files re-verified
- no broad rewrite drift
