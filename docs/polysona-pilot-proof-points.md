# Polysona Pilot Proof Points

## Proven
- real repo discovery and scope isolation
- hold-zone separation
- safe-create support docs on a real repo
- exact-replace on concrete low-risk doc files
- small contiguous section-bounded block replace
- paragraph-bounded replace in a user-facing README
- re-read based verification after modify

## Proven files
- `skills/content/SKILL.md`
- `skills/interview/SKILL.md`
- `README.md`
- `README.ko.md`

## Proven modify constraints
- single-file only
- single-line or single-sentence exact replace
- small contiguous section-local block replace
- paragraph-bounded replace
- readability clarification only
- no semantic expansion

## Not yet proven
- multi-paragraph replace
- section-level semantic rewrite
- persona bundle apply
- hooks/client/server apply
- multi-file modify-safe batching

## Next proof point
- either multi-paragraph bounded replace in docs, or repeat the same baseline on another real repo
