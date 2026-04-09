# Obora DX Status v2

## 한줄 결론

Obora DX 개선은 이제 문서 설계 수준을 넘어서,
**contract-first authoring을 실제 코드와 테스트로 뒷받침하는 상태**에 도달했다.

---

## Completed layers

### P0
- execution resolution summary
- short actionable diagnostics
- judge mode minimal runtime path

### P1 Input
- `input.bindings`
- `{{binding}}` substitution
- binding preview at startup

### P1 Output
- `step.output.schema`
- automatic structured JSON parse
- `step.output.path` persistence
- output preview at startup
- minimal field-level schema mismatch diagnostics

---

## Why this matters

Before this work:
- input/output contract was mostly prompt-driven
- startup visibility was limited
- schema mismatch feedback was too coarse

After this work:
- inputs can be declared structurally
- outputs can be declared structurally
- startup logs can preview contract shape
- runtime can persist structured artifacts
- common schema failures are more actionable

---

## Current best description of the system

Obora is now moving from:
- prompt-first workflow authoring

toward:
- contract-first workflow authoring

This shift is still partial, but it is already real in product behavior.

---

## Recommended next step

The next best step is not another broad redesign.
It is one of these focused follow-ups:

1. strengthen canonical docs/examples in user-facing places
2. widen schema subset support gradually
3. connect schema mismatch handling to repair policies

---

## Final statement

> Obora DX v2 is now credible because the new authoring path is visible in the runtime, validated in tests, and documented as a repeatable pattern.
