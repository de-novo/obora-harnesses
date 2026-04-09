# Obora Input Binding DX Spec

## 한줄 결론

Input Binding DX의 목표는 Obora step author가 `input.task` 프롬프트 작성에 의존하지 않고,
**입력 원천 / 바인딩 이름 / 출력 경로**를 더 명시적으로 선언할 수 있게 만드는 것이다.

---

## Problem

현재 step authoring은 `input.task` 중심이다.

이 구조는 유연하지만 아래 문제가 있다.
- JSON payload를 명시적으로 주입하기 어렵다
- prompt에 무엇이 어떻게 합성되는지 불명확하다
- input file / binding name / output path가 한눈에 안 보인다
- workflow author가 prompt-first authoring으로 밀린다

즉 실전형 integration에서는 contract-first authoring DX가 부족하다.

---

## Goal

다음이 가능한 구조를 제공한다.

1. 입력 파일/값을 **명시적 binding** 으로 선언
2. prompt에서 `{{binding}}` 형태로 사용
3. 출력 경로와 schema를 step 단위에서 명시
4. 실행 전 binding preview 또는 equivalent summary 확인

---

## Proposed Shape

### Current style
```yaml
input:
  task: |
    Read artifacts/input.json and evaluate it.
```

### Proposed style
```yaml
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

output:
  path: artifacts/result.json
  schema: artifacts/result.schema.json
```

---

## Binding Entry Fields

### required
- `path` or `value`
- `kind`

### optional
- `required` (default true)
- `description`

### kinds
- `text`
- `json`
- `markdown`
- `yaml`

---

## Resolution Rules

### binding source
A binding may come from:
- artifact path
- inline literal value
- workflow variable reference

### required behavior
- missing required binding → `BIND_1001`
- unsupported kind → `BIND_1003`
- unresolved variable → `BIND_1002`

---

## Rendering Rules

### json binding
- rendered as serialized JSON text in prompt context

### text/markdown binding
- rendered as raw text

### yaml binding
- rendered as original YAML text or normalized text form

---

## Binding Preview

Resolution Summary or preflight should show:
- binding names
- source paths
- kinds
- missing/optional state

Example:
```text
Binding Preview
- submission: json <- artifacts/submission.json
- rubric: json <- artifacts/rubric.json
- output.path: artifacts/result.json
```

---

## Minimal Implementation Scope (P1)

1. `input.bindings` syntax
2. path-based bindings only initially
3. `{{binding}}` substitution in task
4. missing binding diagnostics
5. binding preview in execution start

---

## Acceptance Criteria

1. step author can declare bindings without embedding file instructions in prose
2. missing input files fail with clear binding diagnostics
3. prompt can reference named bindings deterministically
4. execution start can show which bindings resolved successfully

---

## Out of Scope

- nested expression language
- arbitrary template logic
- dynamic binding transforms

These can come later if needed.
