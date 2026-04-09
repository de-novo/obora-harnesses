# Obora Diagnostics Taxonomy

## 한줄 결론

Obora Diagnostics는 실패 원인을 긴 로그로 숨기지 않고,
**짧고 행동 가능한 코드화된 메시지**로 드러내는 체계다.

목표는 사용자가 다음을 즉시 이해하게 만드는 것이다.
- 무엇이 실패했는가
- 어느 레이어에서 실패했는가
- 지금 무엇을 확인/수정해야 하는가

---

## Problem

현재 사용자는 실패 시 아래를 빠르게 구분하기 어렵다.

- provider/model misconfiguration
- auth 누락
- stub fallback 진입
- binding 해석 실패
- schema validation 실패
- workflow/runtime 내부 에러

이 때문에:
- 로그를 길게 읽어야 하고
- root cause가 늦게 드러나며
- 동일한 시행착오를 반복하기 쉽다

---

## Goal

Diagnostics는 최소 다음을 제공해야 한다.

1. 짧은 error code
2. 한 줄 요약
3. root cause 설명
4. immediate next action
5. optional evidence/context

즉 형식은 아래여야 한다.

```text
[MODEL_1002] Unsupported model ref: zai/glm-5-turbo
Reason: installed runtime catalog does not include this model
Fix: upgrade @mariozechner/pi-ai or use zai/glm-5
```

---

## UX Principles

### Principle 1. Short first
첫 1~3줄만 읽어도 원인을 이해할 수 있어야 한다.

### Principle 2. Actionable always
모든 diagnostics는 다음 행동을 제시해야 한다.

### Principle 3. Layer-aware
에러는 어느 레이어인지 보여줘야 한다.
- config
- model/provider
- auth
- binding
- schema
- runtime

### Principle 4. Pairs with Resolution Summary
Resolution Summary가 현재 상태를 보여주고,
Diagnostics가 왜 실패했는지와 수정 방법을 설명한다.

---

## Error Code Families

## CONFIG_1xxx
설정/우선순위/override 해석 문제

### CONFIG_1001
Invalid provider value

### CONFIG_1002
Conflicting override sources

### CONFIG_1003
Missing required config field

---

## MODEL_1xxx
모델/provider catalog 문제

### MODEL_1001
Unsupported provider ref

### MODEL_1002
Unsupported model ref

### MODEL_1003
Provider-model mismatch

### MODEL_1004
Deprecated alias used

---

## AUTH_1xxx
인증 문제

### AUTH_1001
Missing provider auth

### AUTH_1002
OAuth credential expired or invalid

### AUTH_1003
Auth source unresolved

---

## FALLBACK_1xxx
fallback / stub 관련 문제

### FALLBACK_1001
Execution switched to stub mode

### FALLBACK_1002
Mock adapter selected implicitly

### FALLBACK_1003
Fallback chain exhausted

---

## BIND_1xxx
입력 바인딩/step input 문제

### BIND_1001
Missing input artifact

### BIND_1002
Unresolved binding variable

### BIND_1003
Binding type mismatch

### BIND_1004
Structured input contract incomplete

---

## SCHEMA_1xxx
출력 구조/validation 문제

### SCHEMA_1001
Output schema validation failed

### SCHEMA_1002
Required field missing in output

### SCHEMA_1003
Output type mismatch

### SCHEMA_1004
Repair failed after schema violation

---

## RUNTIME_1xxx
런타임/step execution 문제

### RUNTIME_1001
Step execution failed

### RUNTIME_1002
Tool invocation failed

### RUNTIME_1003
Provider call failed

### RUNTIME_1004
Unexpected runtime exception

---

## Message Template

모든 diagnostics는 아래 구조를 따르는 것이 좋다.

```text
[CODE] Short summary
Reason: root cause explanation
Fix: immediate next action
Context: optional detail
```

### Example
```text
[AUTH_1001] Missing auth for provider anthropic
Reason: no env auth, no file auth, no oauth credentials were resolved
Fix: set ANTHROPIC_API_KEY or authenticate provider before execution
Context: step=reviewer, workflow=judge.yaml
```

---

## Required Fields per Diagnostic

### code
예: `MODEL_1002`

### severity
- info
- warning
- error
- fatal

### summary
짧은 한 줄 요약

### reason
root cause 설명

### fix
바로 할 수 있는 수정 행동

### context
선택적 상세 정보
- workflow
- step
- provider
- model
- source path

---

## Severity Rules

### info
정상 실행이 가능하나 참고할 만한 상태
예: deprecated alias

### warning
실행은 가능하나 혼란 가능성이 큰 상태
예: multiple override layers

### error
현재 실행 실패 또는 곧 실패할 가능성이 높은 상태
예: unsupported model, missing auth

### fatal
즉시 중단해야 하는 상태
예: required binding missing, runtime hard failure

---

## Example Diagnostics

### Unsupported model
```text
[MODEL_1002] Unsupported model ref: zai/glm-5-turbo
Reason: installed runtime catalog does not include this model
Fix: upgrade @mariozechner/pi-ai or use zai/glm-5
Context: provider=zai, source=.obora/agents.yaml
```

### Stub fallback
```text
[FALLBACK_1001] Execution will run in stub mode
Reason: no valid auth was resolved for selected provider anthropic
Fix: configure provider auth or switch explicitly to mock mode
Context: workflow=judge.yaml, step=evaluate_submission
```

### Missing binding
```text
[BIND_1001] Missing input artifact: artifacts/input.json
Reason: the declared step input file does not exist
Fix: generate the artifact before this step or correct the binding path
Context: step=judge, binding=input.json
```

### Schema validation failure
```text
[SCHEMA_1002] Required field missing in output: score
Reason: model response did not satisfy output schema
Fix: strengthen prompt contract or enable repair for schema mismatch
Context: output.path=artifacts/result.json
```

---

## CLI / Runtime Surfaces

### Surface A. concise default output
기본 실행에서는 concise message만 출력

### Surface B. verbose detail flag
`--verbose-diagnostics` 또는 equivalent에서 context/detail 확장

### Surface C. machine-readable JSON
CI나 tooling을 위해 JSON diagnostics 가능

```json
{
  "code": "MODEL_1002",
  "severity": "error",
  "summary": "Unsupported model ref: zai/glm-5-turbo",
  "reason": "installed runtime catalog does not include this model",
  "fix": "upgrade @mariozechner/pi-ai or use zai/glm-5",
  "context": {
    "provider": "zai",
    "source": ".obora/agents.yaml"
  }
}
```

---

## Minimal Implementation Scope (P0)

첫 구현에서는 최소 아래 diagnostics만 있어도 가치가 크다.

- MODEL_1002 unsupported model
- AUTH_1001 missing auth
- FALLBACK_1001 stub fallback
- BIND_1001 missing input artifact
- SCHEMA_1001 schema validation failure

---

## Acceptance Criteria

1. 대표 misconfiguration들이 코드화된 짧은 메시지로 출력된다
2. diagnostics만 봐도 immediate next action을 알 수 있다
3. resolution summary와 함께 읽으면 root cause를 1분 내 파악 가능하다
4. CI/automation을 위한 machine-readable output이 가능하다

---

## Out of Scope

- full stack trace replacement
- observability platform integration
- advanced remediation automation

이건 후속 단계다.

---

## Recommended Next Spec

Diagnostics 다음엔 아래 문서가 이어져야 한다.

- `obora-judge-mode-spec.md`

그래야 “상태 표시 + 실패 진단 + 얇은 진입 모드” 세 축이 연결된다.
