# Baseline v1.4 Proof Plan

## Goal

Validate the first **4-file docs batch** under the same low-risk execution posture.

## First recommended proof

### Repo
- `plant-companion`

### Files
- `README.md`
- `docs/architecture.md`
- `docs/stack.md`
- `docs/local-smoke-flow.md`

### Why this quartet
- same docs-first lane
- already partially proven trio + root README
- no runtime layer touch
- still small enough for explicit re-read verification

## Constraints
- max 4 files
- max 1 bounded change per file in first proof
- no semantic expansion
- re-read all four files after apply

## Success condition
- 4-file batch applied successfully
- all four files re-verified
- no broad rewrite drift
