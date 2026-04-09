# Obora JSON In → JSON Out Example

## 한줄 결론

이 문서는 Obora에서 가장 먼저 성공시켜야 하는 패턴인
**JSON input → single-step model call → JSON output** 예제를 보여준다.

목표는 신규 사용자가 Judge Mode를 이해하기 전에라도,
입력/출력 계약이 어떻게 생겼는지 직관적으로 파악하게 하는 것이다.

---

## Use Case

예시 작업:
- 사용자의 제출물(`submission.json`)을
- 간단한 rubric으로 평가하고
- 구조화된 결과(`result.json`)를 만든다.

즉 매우 전형적인 judge use case다.

---

## Input File

### `artifacts/submission.json`

```json
{
  "title": "Polysona overview",
  "body": "Polysona helps create and maintain multiple personas across domains.",
  "rubric": {
    "clarity": 0.4,
    "correctness": 0.4,
    "specificity": 0.2
  }
}
```

---

## Output Schema

### `artifacts/result.schema.json`

```json
{
  "type": "object",
  "required": ["score", "verdict", "rationale"],
  "properties": {
    "score": { "type": "number" },
    "verdict": { "type": "string", "enum": ["accept", "revise", "reject"] },
    "rationale": { "type": "string" }
  },
  "additionalProperties": false
}
```

---

## Judge Mode Example

### `judge.yaml`

```yaml
mode: judge
provider: zai
model: zai/glm-5-turbo

input:
  json: artifacts/submission.json

prompt: |
  Evaluate the submission using the rubric in the input.
  Return JSON with exactly these fields:
  - score
  - verdict
  - rationale

output:
  path: artifacts/result.json
  schema: artifacts/result.schema.json

options:
  repair: false
  fallback: false
```

---

## Expected Resolution Summary

```text
Judge Resolution
- provider: zai
- model: zai/glm-5-turbo
- auth source: env(ZAI_API_KEY)
- input: artifacts/submission.json
- output: artifacts/result.json
- output schema: artifacts/result.schema.json
- fallback/stub: disabled
```

---

## Expected Output

### `artifacts/result.json`

```json
{
  "score": 0.91,
  "verdict": "accept",
  "rationale": "The submission is clear, correct, and specific enough for the stated scope."
}
```

---

## Failure Example 1 — Missing Input

If `artifacts/submission.json` does not exist:

```text
[BIND_1001] Missing input artifact: artifacts/submission.json
Reason: the declared judge input file does not exist
Fix: create the input artifact or correct the input.json path
```

---

## Failure Example 2 — Schema Validation Failure

If the model returns an invalid JSON object:

```text
[SCHEMA_1001] Output schema validation failed
Reason: the model output does not satisfy the declared schema
Fix: tighten prompt contract or enable repair once
```

---

## Why this example matters

이 예제는 Obora의 가장 기본적이고 중요한 제품 경험을 정의한다.

즉 사용자는 이 예제를 통해 아래를 바로 이해해야 한다.

1. 입력은 어디에 둔다
2. 모델은 어디서 정한다
3. 출력은 어디로 간다
4. schema는 어떻게 강제한다
5. 실패하면 어떤 메시지를 보게 된다

---

## Success Criteria

이 예제를 기준으로 신규 사용자는 아래를 10분 안에 성공할 수 있어야 한다.

- input JSON 준비
- judge 실행
- output JSON 생성
- schema validation 통과

이게 되면 Judge Mode의 기본 온보딩은 성립한 것이다.
