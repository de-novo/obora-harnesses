# Long-Running Apps Harness

## Goal
Evaluate Obora on real product-building loops rather than repair-only tasks.

This harness family is for experiments where Obora must:
1. expand a small product prompt into a usable spec
2. break work into smaller contracts
3. implement one contract at a time
4. evaluate the artifact
5. repair or replan based on findings

## Initial experiment
The first target is a small Todo CLI.

Comparison targets:
- single-agent baseline artifact
- enhanced long-running workflow artifact

## Principles
- start with a narrow product slice
- preserve artifacts between steps
- separate planning, implementation, and evaluation
- use explicit acceptance criteria
- distinguish runtime failures from quality failures

## Expected artifacts
- `product-brief.md`
- `spec.md`
- `milestones.json`
- `backlog.json`
- `sprint-contract.json`
- `qa-report.json`
- `comparison-summary.md`
