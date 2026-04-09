# Obora Resolution Summary Spec

## 한줄 결론

Resolution Summary는 Obora 실행 직전에
**실제로 어떤 provider/model/auth/config/fallback 조합으로 실행될지**를 짧고 직접적으로 보여주는 표준 진단 카드다.

---

## Problem

현재 사용자는 실행 전에 아래를 명확히 알기 어렵다.

- 어떤 provider가 최종 선택되었는가
- 어떤 model이 최종 선택되었는가
- auth는 어디서 왔는가
- config는 어디서 왔는가
- stub/fallback이 활성화되는가
- override가 적용되었는가

이 때문에:
- misconfiguration을 늦게 발견하고
- 실패 원인을 뒤늦게 로그에서 추적해야 하며
- runtime을 신뢰하기 어렵다

---

## Goal

실행 직전 아래를 한 번에 보여준다.

1. selected provider
2. selected model
3. auth source
4. config source
5. override source
6. fallback/stub state
7. risk/warning summary

---

## UX Principle

Resolution Summary는 길고 자세한 디버그 로그가 아니다.

목표는:
- 5~10초 안에 읽을 수 있어야 하고
- "지금 뭘로 실행되는지"를 바로 이해할 수 있어야 하며
- 실패 가능성이 있으면 실행 전에 경고해야 한다

즉 **실행 전 짧은 상태 카드** 여야 한다.

---

## Output Shape

### Human-readable card

```text
Execution Resolution
- workflow: judge.yaml
- step: evaluate_submission
- provider: zai
- model: zai/glm-5-turbo
- auth source: env(ZAI_API_KEY)
- config source: .obora/config.yaml
- model source: .obora/agents.yaml -> step override 없음
- fallback/stub: disabled
- warnings: none
```

### JSON shape

```json
{
  "workflow": "judge.yaml",
  "step": "evaluate_submission",
  "provider": {
    "value": "zai",
    "source": ".obora/config.yaml"
  },
  "model": {
    "value": "zai/glm-5-turbo",
    "source": ".obora/agents.yaml"
  },
  "auth": {
    "mode": "env",
    "source": "ZAI_API_KEY",
    "resolved": true
  },
  "fallback": {
    "enabled": false,
    "reason": null
  },
  "warnings": []
}
```

---

## Required Fields

### workflow
- 현재 실행 중인 workflow 파일명 또는 identifier

### step
- 현재 해석 대상 step 이름

### provider
- 최종 provider 값
- source 포함

### model
- 최종 model ref
- source 포함

### auth
- auth mode (`env`, `file`, `oauth`, `none`)
- source (env var name, auth store id 등)
- resolved 여부

### config source
- config가 어디서 왔는지
- global/project/step override 구분 가능해야 함

### fallback
- fallback/stub 활성화 여부
- 활성화 이유

### warnings
- unsupported model risk
- missing auth
- unresolved binding
- stub fallback 예정

---

## Source Precedence Rules

Resolution Summary는 source precedence 결과를 보여줘야 한다.

우선순위 예시:

1. step override
2. agent definition override
3. workflow-level default
4. project `.obora/config.yaml`
5. global default
6. environment fallback

문서와 출력 모두 이 precedence를 일관되게 써야 한다.

---

## Warnings Policy

다음은 warning 또는 pre-error로 노출되어야 한다.

### warning
- provider/model이 deprecated alias임
- auth source는 있지만 fallback path가 사용될 수 있음
- config source가 multiple layered override 상태임

### hard warning / preflight failure
- unsupported model ref
- unsupported provider ref
- missing auth with non-mock provider
- fallback to stub 예정
- unresolved required binding

---

## Display Timing

Resolution Summary는 최소 두 군데서 보여야 한다.

### 1. execution start
workflow 실행 직전

### 2. step-level resolution (optional compact form)
step별 provider/model이 달라질 수 있으면 compact resolution을 제공

---

## CLI Surfaces

### Surface A. automatic pre-execution card
기본 실행 시 자동 출력

### Surface B. explicit resolve command
예:
```bash
obora resolve workflow.yaml
```

의도:
- 실제 실행 없이 resolution만 확인
- onboarding / debugging / CI validation 용도

---

## Error Interaction

Resolution Summary는 diagnostics와 연결되어야 한다.

예:
- summary가 `fallback/stub: enabled` 라고 보여주고
- 이어지는 diagnostics는 `AUTH_1003` 또는 `FALLBACK_1004` 를 제공

즉 summary는 상태를 보여주고,
diagnostics는 왜 그런지와 fix를 설명한다.

---

## Minimal Implementation Scope (P0)

첫 구현에서는 아래만 있어도 충분하다.

1. provider
2. model
3. auth source
4. config source
5. fallback/stub flag
6. warnings

즉 binding/source tree 전체를 다 구현하기 전에,
가장 혼란을 줄이는 핵심 정보부터 제공한다.

---

## Acceptance Criteria

1. 실행 전에 provider/model/auth/config source가 출력된다
2. stub/fallback 여부가 실행 전에 보인다
3. unsupported model/provider가 실행 전에 감지된다
4. 사용자가 긴 로그를 보기 전에 misconfiguration을 이해할 수 있다

---

## Out of Scope

- full debug trace 대체
- prompt rendering preview 전체
- schema validation details 전체
- workflow graph visualization

이건 후속 단계다.

---

## Recommended Next Spec

Resolution Summary 다음엔 아래 둘이 바로 이어져야 한다.

1. `obora-diagnostics-taxonomy.md`
2. `obora-judge-mode-spec.md`

그래야 summary + failure + thin mode가 하나의 UX 개선 세트로 맞물린다.
