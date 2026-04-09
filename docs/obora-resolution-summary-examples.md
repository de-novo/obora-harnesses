# Obora Resolution Summary Examples

## Example 1 — healthy run

```text
Execution Resolution
- workflow: judge.yaml
- step: evaluate_submission
- provider: zai
- model: zai/glm-5-turbo
- auth source: env(ZAI_API_KEY)
- config source: .obora/config.yaml
- model source: .obora/agents.yaml
- fallback/stub: disabled
- warnings: none
```

---

## Example 2 — unsupported model

```text
Execution Resolution
- workflow: judge.yaml
- step: evaluate_submission
- provider: zai
- model: zai/glm-5-turbo
- auth source: env(ZAI_API_KEY)
- config source: .obora/config.yaml
- model source: .obora/agents.yaml
- fallback/stub: disabled
- warnings:
  - MODEL_1002 unsupported model ref in installed runtime catalog
```

---

## Example 3 — missing auth, stub fallback

```text
Execution Resolution
- workflow: judge.yaml
- step: evaluate_submission
- provider: anthropic
- model: claude-sonnet-4-5
- auth source: none
- config source: .obora/config.yaml
- model source: .obora/agents.yaml
- fallback/stub: enabled
- reason: missing auth for non-mock provider
- warnings:
  - AUTH_1003 missing provider auth
  - FALLBACK_1004 execution will run in stub mode
```

---

## Example 4 — override confusion

```text
Execution Resolution
- workflow: review.yaml
- step: refine_output
- provider: anthropic
- model: claude-opus-4-5
- auth source: oauth(anthropic)
- config source: step override
- model source: step override > agent > project config
- fallback/stub: disabled
- warnings:
  - multiple override layers detected; using highest-priority step override
```
