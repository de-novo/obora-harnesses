# Todo CLI baseline vs enhanced

## Scope
This comparison contrasts:
- `generated/cli/experimental/todo-cli-single-agent`
- `generated/cli/validated/todo-cli-enhanced`

## Baseline characteristics
- one-shot style artifact
- simple command surface
- local JSON persistence
- minimal structure and minimal explicit QA artifacts

## Enhanced characteristics
- built as the target artifact for an enhanced long-running workflow
- spec and task contract exist alongside implementation
- implementation notes and QA scaffold preserved
- slightly stronger UX and storage safeguards

## Feature comparison
| Capability | Baseline | Enhanced |
|---|---|---|
| help | yes | yes |
| add | yes | yes |
| list | yes | yes |
| done | yes | yes |
| remove | yes | yes |
| clear | yes | yes |
| list filtering | no | yes (`--all`, `--done`, `--open`) |
| storage validation | basic | explicit validation |
| atomic write | no | yes |
| implementation notes | no | yes |
| QA artifact | no | yes |
| contract artifact | no | yes |

## Qualitative observations
### Baseline strengths
- very small and easy to inspect
- quick to generate
- enough for basic command validation

### Baseline weaknesses
- little surrounding context for future extension
- fewer quality safeguards around storage behavior
- limited comparison/evaluation metadata

### Enhanced strengths
- closer to a real product-development artifact
- better documentation and acceptance framing
- stronger persistence handling and command UX
- easier to evolve through future harness iterations

### Enhanced weaknesses
- more files and coordination overhead
- requires stronger harness discipline to generate consistently

## Conclusion
The enhanced artifact is not just "more code". It captures more of the product-development process:
- spec
- contract
- implementation notes
- QA framing

That makes it a better target for production-oriented harness validation, even for a small CLI.
