# Obora Judge Mode Examples

## Example 1 — rubric judge

```yaml
mode: judge
provider: zai
model: zai/glm-5-turbo

input:
  json: artifacts/submission.json

prompt: |
  Evaluate the submission against the rubric and return JSON.
  Include: score, verdict, rationale.

output:
  path: artifacts/result.json
  schema: artifacts/result.schema.json

options:
  repair: false
  fallback: false
```

---

## Example 2 — extraction judge

```yaml
mode: judge
provider: anthropic
model: claude-sonnet-4-5

input:
  json: artifacts/article.json

prompt: |
  Extract structured facts from the input and return JSON.

output:
  path: artifacts/facts.json
```

---

## Example 3 — failure surface

If `artifacts/submission.json` is missing:

```text
[BIND_1001] Missing input artifact: artifacts/submission.json
Reason: the declared judge input file does not exist
Fix: create the input artifact or correct the input.json path
```

If output fails schema validation:

```text
[SCHEMA_1001] Output schema validation failed
Reason: the model output does not satisfy the declared schema
Fix: tighten prompt contract or enable repair once
```
