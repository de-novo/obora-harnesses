# Todo CLI experiment

## Purpose
Use a very small but real CLI product as the first long-running application harness target.

The purpose is not just to generate code once, but to test whether Obora can:
- plan from a short prompt
- define a contract for a small implementation slice
- implement the slice
- evaluate the result
- repair or refine the plan

## Why Todo CLI
Todo CLI is intentionally small, but still useful for harness validation because it includes:
- user-facing commands
- persistence
- command help / UX
- edge-case handling
- a meaningful acceptance surface

## Comparison setup
### Baseline
- `generated/cli/experimental/todo-cli-single-agent`

### Enhanced target
- `generated/cli/validated/todo-cli-enhanced`

## Initial scope
Required commands:
- add
- list
- done
- remove
- clear
- help

Required quality:
- local JSON storage remains valid
- command errors are understandable
- output is readable
- implementation is small and maintainable

## Success conditions for the first experiment
1. enhanced workflow produces a runnable CLI artifact
2. artifacts document product intent, bounded task contracts, and acceptance criteria
3. evaluator can explain failures concretely
4. enhanced artifact is at least as functional as baseline
5. comparison summary can state where enhanced workflow helped or failed

## Artifact discipline
The experiment is only useful if the planning trail is preserved without creating unnecessary documentation.

At minimum, the enhanced workflow should leave behind:
- `spec.md`
- `task-contract.json`
- `qa-report.json`
- `comparison-summary.md`

Optional:
- `implementation-notes.md` when short context about changes, tradeoffs, or remaining risks is useful.

The contract should be small, explicit, and actionable enough that a human can see exactly what the current implementation slice is.

## Next expansion if successful
If Todo CLI succeeds, the next target can be:
- a richer CLI with tagging/filtering/export
- a small web tool
- a local dashboard
- a thin full-stack internal app
