# Obora Diagnostics Examples

## Example 1 — unsupported model

```text
[MODEL_1002] Unsupported model ref: zai/glm-5-turbo
Reason: installed runtime catalog does not include this model
Fix: upgrade @mariozechner/pi-ai or use zai/glm-5
Context: provider=zai, source=.obora/agents.yaml
```

---

## Example 2 — missing auth

```text
[AUTH_1001] Missing auth for provider anthropic
Reason: no env auth, no file auth, and no oauth credentials were resolved
Fix: set ANTHROPIC_API_KEY or authenticate provider before execution
Context: workflow=judge.yaml, step=evaluate_submission
```

---

## Example 3 — stub fallback

```text
[FALLBACK_1001] Execution will run in stub mode
Reason: no valid auth was resolved for selected provider anthropic
Fix: configure provider auth or switch explicitly to mock mode
Context: workflow=judge.yaml, step=evaluate_submission
```

---

## Example 4 — missing input artifact

```text
[BIND_1001] Missing input artifact: artifacts/input.json
Reason: the declared step input file does not exist
Fix: generate the artifact before this step or correct the binding path
Context: step=judge, binding=input.json
```

---

## Example 5 — schema validation failure

```text
[SCHEMA_1001] Output schema validation failed
Reason: model output does not satisfy the declared schema
Fix: tighten output instructions or enable repair on schema mismatch
Context: output.path=artifacts/result.json
```
