# Obora Judge Mode Spec

## 한줄 결론

Judge Mode는 Obora의 validator/repair/workflow 강점을 유지하되,
**단건 inference / JSON in → JSON out** use case를 위해 훨씬 얇은 진입점을 제공하는 모드다.

---

## Problem

현재 Obora는 multi-step workflow runtime으로는 강하지만,
judge 같은 단건 inference에는 아래 문제가 있다.

- 설정과 입력 바인딩이 무겁게 느껴짐
- workflow authoring ceremony가 큼
- JSON input → JSON output 경로가 first-class하지 않음
- 사용자는 runtime보다 결과 한 건을 빠르게 받고 싶어함

즉 상품 judge, scraper evaluator, one-shot classifier, structured reviewer 같은 use case에는
현재 기본 UX가 과하게 무겁다.

---

## Goal

Judge Mode의 목표는 다음이다.

1. **한 번의 모델 호출**로 끝나는 단건 작업을 단순화
2. **JSON input → JSON output** 을 first-class path로 제공
3. 필요하면 **schema validation** 을 붙일 수 있게 함
4. 실패 시 **짧고 직접적인 diagnostics** 제공
5. 필요할 때만 repair/validator를 optional로 추가

---

## Core UX Principle

Judge Mode는 full workflow mode의 축소판이 아니다.

오히려 다음에 가깝다.

- input contract
- optional prompt
- one-step model invocation
- optional schema validation
- direct output artifact

즉 사용자가 기대하는 경험은:

> 입력 JSON 하나 주고,
> 지정한 모델 한 번 부르고,
> 결과 JSON 하나 받고,
> 실패하면 짧게 왜 실패했는지 안다.

---

## Target Use Cases

### Good fit
- scraper result judge
- moderation/classification
- ranking/scoring
- rubric-based evaluation
- structured extraction
- one-shot review

### Not the primary target
- long-running multi-step workflow
- validator/repair heavy pipeline
- artifact graph orchestration
- code generation chains

---

## Minimal Conceptual Shape

### Human-readable YAML form

```yaml
mode: judge
provider: zai
model: zai/glm-5-turbo

input:
  json: artifacts/input.json
  schema: artifacts/input.schema.json   # optional

prompt: |
  Evaluate the input and return structured JSON.

output:
  path: artifacts/result.json
  schema: artifacts/output.schema.json  # optional

options:
  repair: false
  fallback: false
```

### JSON-equivalent mental model

```json
{
  "mode": "judge",
  "provider": "zai",
  "model": "zai/glm-5-turbo",
  "input": {
    "json": "artifacts/input.json",
    "schema": "artifacts/input.schema.json"
  },
  "prompt": "Evaluate the input and return structured JSON.",
  "output": {
    "path": "artifacts/result.json",
    "schema": "artifacts/output.schema.json"
  },
  "options": {
    "repair": false,
    "fallback": false
  }
}
```

---

## Required Fields

### mode
- must be `judge`

### provider
- explicit provider required in initial version

### model
- explicit model required in initial version

### input.json
- path to input JSON artifact

### prompt
- evaluation/extraction instruction

### output.path
- where the resulting JSON is written

---

## Optional Fields

### input.schema
입력 JSON shape를 설명하거나 preflight validation에 사용

### output.schema
모델 출력 검증에 사용

### options.repair
- `false` default
- `true`이면 schema mismatch 시 한 번 repair 시도 가능

### options.fallback
- `false` default
- implicit stub fallback 금지 방향 권장

### options.temperature
단건 평가용 파라미터

### options.maxTokens
출력 제한

---

## Execution Flow

### Step 1. Resolve
- provider/model/auth/config resolution summary 출력

### Step 2. Input load
- input JSON 로드
- optional input schema validation

### Step 3. One-step inference
- single model call
- no workflow loop by default

### Step 4. Output validation
- optional output schema validation

### Step 5. Write result
- result JSON 저장
- summary 출력

### Step 6. Diagnostics on failure
- MODEL/AUTH/BIND/SCHEMA diagnostics 적용

---

## Output Contract

Judge Mode의 기본 출력은 JSON artifact다.

예:
```json
{
  "score": 0.92,
  "label": "accept",
  "reason": "The answer matches the rubric strongly.",
  "confidence": "high"
}
```

즉 텍스트 중심이 아니라,
**기본 출력 단위가 구조화 JSON** 이다.

---

## Schema Behavior

### input.schema
있으면 input preflight validation 수행

### output.schema
있으면 output validation 수행

### on validation fail
초기 버전 정책:
- default = fail
- optional = repair once

즉 Judge Mode는 기본적으로 **predictable fail-fast** 가 맞다.
workflow mode처럼 자동 repair가 기본이면 오히려 무거워진다.

---

## Diagnostics Integration

Judge Mode는 아래 diagnostics와 결합되어야 한다.

- MODEL_1002 unsupported model
- AUTH_1001 missing auth
- BIND_1001 missing input artifact
- SCHEMA_1001 output validation failed
- FALLBACK_1001 stub fallback attempted

즉 Judge Mode는 Diagnostics Taxonomy의 가장 직접적인 수혜자다.

---

## Resolution Summary Integration

Judge Mode 실행 전엔 반드시 compact resolution summary를 보여준다.

예:
```text
Judge Resolution
- provider: zai
- model: zai/glm-5-turbo
- auth source: env(ZAI_API_KEY)
- input: artifacts/input.json
- output: artifacts/result.json
- output schema: artifacts/output.schema.json
- fallback/stub: disabled
```

---

## CLI Surface Options

### Option A. dedicated command
```bash
obora judge judge.yaml
```

### Option B. workflow mode with mode switch
```bash
obora run judge.yaml
```
where `mode: judge` triggers simplified path

### Recommendation
초기에는 **Option B** 가 구현 비용이 더 낮다.
하지만 UX 관점에선 장기적으로 `obora judge` 가 더 좋다.

---

## First Canonical Example

가장 먼저 제공해야 하는 예제는 아래다.

### Example: rubric judge
- input: submission JSON
- prompt: score according to rubric
- output: `{ score, verdict, rationale }`
- output schema included

이 예제가 있으면 “input JSON → output JSON” 패턴을 직관적으로 이해할 수 있다.

---

## Minimal Implementation Scope (P0)

첫 구현에서는 아래만 있어도 충분하다.

1. explicit provider/model
2. input.json path
3. prompt
4. output.path
5. optional output.schema
6. one-step inference only
7. no implicit stub fallback
8. compact resolution summary
9. short diagnostics

---

## Acceptance Criteria

1. 신규 사용자가 10분 안에 JSON→JSON judge 실행 성공 가능
2. unsupported model/auth/binding/schema 문제를 1분 안에 진단 가능
3. full workflow를 몰라도 single-step judge를 붙일 수 있음
4. output이 항상 명시된 JSON artifact 경로로 저장됨

---

## Out of Scope

- multi-step orchestration
- nested repair chains
- artifact graph pipelines
- advanced workflow branching

이건 full workflow mode의 역할이다.

---

## Recommended Next Doc

Judge Mode spec 다음엔 아래 문서가 자연스럽다.

- `obora-json-in-json-out-example.md`

즉 실제 예제 하나로 이 spec을 바로 이해 가능하게 해야 한다.
