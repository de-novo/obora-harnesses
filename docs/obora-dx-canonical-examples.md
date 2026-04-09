# Obora DX Canonical Examples

## 한줄 결론

이 문서는 Obora DX 개선 이후의 **권장 authoring 패턴**을 canonical example로 정리한다.

현재 기준으로 강조하는 축은 아래 4개다.
- input bindings
- output contract (`output.schema`, `output.path`)
- startup preview
- one-file judge path

---

## 1. Normal step with input bindings + output contract

```yaml
name: contract-first-evaluation
version: "1.0"

agents:
  evaluator:
    provider: mock
    model: mock-model

steps:
  - name: evaluate_submission
    agent: evaluator
    input:
      bindings:
        submission:
          path: artifacts/submission.json
          kind: json
        rubric:
          path: artifacts/rubric.json
          kind: json
      task: |
        Evaluate {{submission}} using {{rubric}}.
        Return JSON only.
    output:
      path: artifacts/result.json
      schema: artifacts/result.schema.json
```

### What this gives you
- input artifacts are declared explicitly
- prompt can reference named bindings
- output contract is visible at step definition level
- result can be persisted automatically

---

## 2. Startup preview expectation

At execution start, the runtime can now show:

```text
Execution Resolution
- provider: mock
- model: mock-model
- auth source: direct/unknown
- config source: ...
- model source: runtime.llm
- fallback/stub: disabled
- warnings: none
Binding Preview
- evaluate_submission.submission: json <- artifacts/submission.json [resolved]
- evaluate_submission.rubric: json <- artifacts/rubric.json [resolved]
Output Preview
- evaluate_submission: path <- artifacts/result.json [pending]; schema <- artifacts/result.schema.json [resolved]
```

### Meaning
Before execution, the author can quickly inspect:
- what inputs are bound
- whether schema is present
- where output artifact will be written

---

## 3. One-file judge mode

```yaml
name: one-file-judge
mode: judge

provider: mock
model: mock-evaluator
prompt: |
  Evaluate the submission and return JSON only.

input:
  json: artifacts/submission.json
  schema: artifacts/submission.schema.json

output:
  path: artifacts/result.json
  schema: artifacts/result.schema.json
```

### Meaning
This gives a short path for:
- JSON in
- one-step evaluation
- JSON out

without forcing the user to author a larger workflow first.

---

## 4. Expected schema mismatch diagnostics

When `output.schema` is declared, Obora now provides short diagnostics for common cases.

### Invalid JSON
- `SCHEMA_1001`
- meaning: model output was not parseable JSON

### Missing schema file
- `SCHEMA_1002`
- meaning: declared schema path does not exist

### Contract mismatch
- `SCHEMA_1003`
- current detailed cases:
  - top-level type mismatch
  - missing required field
  - field type mismatch

Example messages:
- `missing required field(s): verdict`
- `field 'score' should be number, got string`

---

## 5. Recommended current authoring style

### Prefer
- explicit `input.bindings`
- prompt with `{{binding}}`
- explicit `output.path`
- explicit `output.schema`
- JSON-only final responses for structured steps

### Avoid
- hiding file paths only in prose
- relying on implicit output shape
- mixing free-form explanation with structured output when contract is strict

---

## 6. Current implementation boundary

What is already implemented:
- path-based input bindings
- binding preview
- step-level output schema declaration
- step-level output artifact persistence
- startup output preview
- minimal detailed schema mismatch diagnostics

What is not yet full-featured:
- full JSON Schema support
- nested object validation depth
- array item schema validation
- enum validation
- repair-loop integration for schema mismatch

---

## Final statement

> The recommended Obora authoring style is now contract-first: explicit inputs, explicit outputs, and visible startup previews.
