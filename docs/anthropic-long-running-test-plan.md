# Anthropic long-running harness alignment test plan

## Goal
Obora harness를 Anthropic의 "Harness design for long-running application development" 글의 핵심 원칙에 맞춰 평가하고, 현재 harness의 강점/병목/다음 실험 우선순위를 명확히 한다.

Reference:
- https://www.anthropic.com/engineering/harness-design-long-running-apps

## 핵심 질문
1. Generator와 Evaluator가 충분히 분리돼 있는가?
2. 긴 실행에서 coherence를 유지하는가?
3. structured artifact handoff가 충분한가?
4. evaluator가 실제로 strict하고 useful한 피드백을 주는가?
5. runtime cancellation/timeout이 long-running harness의 주 병목인가?

## Anthropic article → Obora mapping
### Anthropic roles
- Planner
- Generator
- Evaluator
- Sprint contract
- Structured artifact handoff

### Current Obora harness mapping
- discover_target → lightweight planning / bug locus discovery
- generate_edit → generator
- validate_edit + final validation → evaluator
- results artifacts (`problem.txt`, `target_file.txt`, `edit.json`, `patch.diff`, `final-validation.json`) → structured handoff

### Current gap
- explicit planner/contract artifact 부족
- evaluator rubric / calibration 명시성 부족
- runtime telemetry 강화 필요

## Current baseline status
Standalone repository:
- `/Users/denovo/workspace/github/obora-harnesses`

Current first-30 slice result:
- PASS: 27
- FAIL_RUNTIME: 3
- QUALITY_FAIL: 0
- INFRA_FAIL: 0

Interpretation:
- 현재 병목은 patch quality보다 runtime stability 쪽이다.
- generator/evaluator separation은 상당 부분 잘 작동하고 있다.
- `SDK_8002` cancellation은 long-running reliability의 핵심 리스크다.

## Test tracks

### Track A. Baseline long-running reliability
목적:
- 현재 harness의 long-running reliability baseline 확보

Run set:
- first 30 sequential
- then 50 sequential

Metrics:
- pass rate
- runtime fail rate
- quality fail rate
- infra fail rate
- `SDK_8002` count
- average runtime per sample
- retry count per sample

Success criteria:
- runtime fail이 minority로 유지될 것
- repeated cancellation이 특정 step/stage에 편중되는지 분류 가능할 것

### Track B. Evaluator strictness audit
목적:
- evaluator가 self-approval 편향 없이 strict하게 동작하는지 확인

Method:
- known bad edits 주입
- wrong target edit
- semantically incomplete edit
- import missing / symbol missing edit
- syntactically valid but logically wrong edit

Metrics:
- false positive rate
- rejection reason specificity
- repair feedback usefulness

Success criteria:
- validator가 잘못된 edit를 대부분 reject할 것
- rejection message가 다음 repair step에 actionable할 것

### Track C. Contract artifact experiment
목적:
- Anthropic article의 sprint contract 개념을 Obora repair loop에 이식

New proposed artifact:
- `repair_contract.json`

Suggested fields:
- `sample_id`
- `target_file`
- `suspected_bug_locus`
- `change_intent`
- `success_criteria`
- `do_not_touch`
- `validation_expectations`

Experiment design:
- A: current flow
  - discover_target → generate_edit → validate_edit
- B: contract flow
  - discover_target → repair_contract → generate_edit → validate_edit

Metrics:
- wrong target rate
- fail_no_target rate
- fail_wrong_target rate
- average repair iterations
- final pass rate

Success criteria:
- contract flow가 target precision 또는 repair efficiency를 개선할 것

### Track D. Runtime failure telemetry
목적:
- `SDK_8002` / timeout / cancellation을 구조적으로 분석 가능하게 만들기

Capture fields per run:
- sample_id
- repo
- failing step
- attempt index
- repair iteration index
- timeout_ms
- provider / model
- failure signature
- whether retry succeeded

Recommended artifact:
- `runtime-failure.json`

Success criteria:
- runtime fail을 transient vs persistent로 구분 가능할 것
- step-specific hotspot이 식별될 것

### Track E. Anthropic-style evaluator calibration
목적:
- evaluator를 더 skeptical하고 threshold-based하게 조정

Suggested rubric:
- target correctness
- minimality of edit
- semantic correctness
- validation compliance
- patch safety

Rule:
- 어느 하나라도 threshold 미달이면 FAIL

Metrics:
- false positive 감소
- repair loop quality 향상
- final pass rate 변화

## Immediate next actions
1. first-30 실패 3건 재실행으로 transient/persistent 분리
2. current baseline 결과를 문서화
3. runtime failure telemetry artifact 추가
4. `repair_contract.json` 실험 설계 및 최소 구현
5. evaluator strictness audit용 synthetic bad patch set 작성

## Recommended priority
1. runtime telemetry 강화
2. `repair_contract.json` 추가 실험
3. evaluator calibration 강화
4. 50-sample sequential 확장

## Working hypothesis
- 현재 harness는 generator/evaluator separation 측면에서는 이미 유의미한 구조를 갖고 있다.
- 현재 가장 큰 병목은 long-running runtime stability이며, 특히 `SDK_8002` cancellation의 관측/완화 체계가 부족하다.
- Anthropic article의 planner/contract 개념을 `repair_contract.json`으로 도입하면 wrong-target / shallow-repair를 줄일 가능성이 높다.
