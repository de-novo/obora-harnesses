# Obora Structured Output / Schema UX Spec

## 한줄 결론

Structured output UX의 목표는 step author가 validation 전용 step에 의존하지 않고,
**step 자체의 output contract**를 더 직접적으로 선언할 수 있게 만드는 것이다.

---

## Problem

현재 structured output은 validation-repair 흐름에 강하게 묶여 있다.

이 구조는 강력하지만 아래 문제가 있다.
- 일반 step author 입장에서 `output.schema`가 first-class가 아님
- "이 step의 결과는 어떤 JSON이어야 하는가"가 step 정의에서 바로 안 보임
- schema mismatch 시 에러가 validation semantics 쪽으로 우회되어 보임
- judge/simple mode 같은 짧은 경로에서 contract-first authoring DX가 약하다

---

## Goal

다음이 가능한 구조를 제공한다.

1. step에 `output.schema`를 직접 선언
2. LLM 응답을 structured JSON으로 파싱
3. schema mismatch 시 짧고 행동 가능한 diagnostics 제공
4. 추후 repair/fail policy와 자연스럽게 연결

---

## Proposed Shape

```yaml
steps:
  - name: evaluate
    agent: writer
    input:
      task: |
        Return JSON only.
    output:
      path: artifacts/result.json
      schema: artifacts/result.schema.json
```

또는 one-file/judge 계열:

```yaml
mode: judge
output:
  path: artifacts/result.json
  schema: artifacts/result.schema.json
```

---

## Minimal P1 Scope

1. `step.output.schema` read support
2. raw response → JSON parse attempt
3. parse failure → short diagnostic
4. schema file 존재 여부 확인
5. initial implementation에서는 **schema file presence + JSON object parse** 중심으로 시작

즉 첫 단계는 full JSON Schema validator보다,
contract-first authoring path를 먼저 세운다.

---

## Diagnostics

### parse failure
- code: `SCHEMA_1001`
- meaning: structured output expected but response was not valid JSON

### schema file missing
- code: `SCHEMA_1002`
- meaning: declared schema file was not found

### schema mismatch
- code: `SCHEMA_1003`
- meaning: parsed JSON did not satisfy required structure

---

## Acceptance Criteria

1. step author can declare `output.schema`
2. execution attempts structured parse automatically for that step
3. invalid JSON fails with a clear short diagnostic
4. declared schema path can be surfaced in startup/preview later

---

## Out of Scope

- full JSON Schema feature completeness
- automatic repair loop integration
- schema-aware prompt synthesis

These can follow after the first contract-first path lands.
