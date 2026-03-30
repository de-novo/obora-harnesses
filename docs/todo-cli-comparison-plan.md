# Todo CLI comparison plan

## Goal
간단한 실제 CLI 도구를 대상으로 아래 두 방식을 비교한다.

1. **Single-agent baseline**
2. **Enhanced long-running workflow**

Anthropic의 harness engineering 사례처럼, 단순 생성이 아니라:
- spec / contract
- generator / evaluator separation
- structured artifacts
- iterative repair
- long-running orchestration
을 적용했을 때 실제 artifact 품질과 안정성이 좋아지는지 본다.

## Target application
A small but real Todo CLI.

Required features:
- add
- list
- done
- remove
- clear
- local JSON persistence
- help / usage output

Nice-to-have:
- priorities
- tags
- filtering
- export

## Comparison outputs
### A. Single-agent baseline
Path:
- `generated/cli/experimental/todo-cli-single-agent`

Characteristics:
- one-shot generation
- minimal loop
- no explicit contract negotiation
- no external evaluator step

### B. Enhanced workflow artifact
Proposed path:
- `generated/cli/validated/todo-cli-enhanced`

Characteristics:
- spec artifact
- sprint / task contract
- generator implementation loop
- evaluator checklist / acceptance validation
- repair loop on failure
- preserved artifacts and reports

## Evaluation questions
1. Does the enhanced workflow improve implementation completeness?
2. Does it improve CLI usability and help quality?
3. Does it reduce hidden correctness bugs?
4. Does artifact quality/documentation improve?
5. What is the cost/time tradeoff?

## Success criteria
### Functional
- all required commands work
- persistence is correct
- no destructive command breaks the data file format

### UX
- help text is clear
- command errors are understandable
- output is readable

### Code quality
- structure is maintainable
- core data operations are not duplicated excessively
- obvious edge cases are handled

### Harness quality
- artifacts preserve implementation reasoning and acceptance criteria
- evaluator can explain failures concretely
- repair loop can correct failed outputs

## Proposed enhanced workflow design
### Agent roles
1. **Planner**
   - expand short prompt into product spec
   - define command surface and persistence model

2. **Contractor**
   - produce sprint/task contract
   - define acceptance criteria for each chunk

3. **Generator**
   - implement code for the current contract

4. **Evaluator**
   - run CLI commands / inspect outputs / check storage behavior
   - score against acceptance criteria

5. **Repair loop**
   - generator revises based on evaluator feedback

## Recommended artifacts
- `spec.md`
- `task-contract.json`
- `implementation-notes.md`
- `qa-report.json`
- `repair-log.json`
- `comparison-summary.md`

## Minimum experiment phases
### Phase 1
Create single-agent baseline artifact.

### Phase 2
Define enhanced workflow artifacts and acceptance rubric.

### Phase 3
Build enhanced artifact with contract + evaluation loop.

### Phase 4
Run side-by-side comparison:
- command coverage
- error handling
- storage correctness
- code organization
- artifact completeness

## Initial scope decision
Start intentionally small.

The first comparison should aim for:
- one local-file-backed todo CLI
- a narrow command surface
- clean acceptance checks

This keeps the first harness comparison interpretable while still mapping to real application work.
