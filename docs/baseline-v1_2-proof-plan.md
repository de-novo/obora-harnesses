# Baseline v1.2 Proof Plan

## Goal

Validate the first **two-file docs batch** under the same low-risk execution posture.

## First recommended proof

### Repo
- `polysona`

### Files
- `README.md`
- `README.ko.md`

### Why this pair
- both files already have bounded modify proof
- both are user-facing docs
- terminology alignment is a natural batching use case
- changes can stay wording-only

## Constraints
- max 2 files
- max 1 bounded change per file in first proof
- no semantic expansion
- re-read both files after apply

## Success condition
- two-file batch applied successfully
- both files re-verified
- no broad rewrite drift
