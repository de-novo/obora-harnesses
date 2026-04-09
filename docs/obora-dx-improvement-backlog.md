# Obora DX Improvement Backlog

## 한줄 결론

현재 Obora의 핵심 문제는 런타임 자체의 약점보다,
**초기 통합 UX / 입력 바인딩 DX / 설정 해석 가시성 / 짧은 실패 진단 부재**에 있다.

이 문서는 해당 문제를 실제 개발 착수 가능한 backlog로 분해한다.

---

# Epic 1. Resolution Visibility

## Problem
사용자는 실행 전에 아래를 명확히 알 수 없다.
- 어떤 provider가 선택됐는지
- 어떤 model이 선택됐는지
- auth source가 무엇인지
- config source가 무엇인지
- stub/fallback 여부

## Why it matters
실패 원인 파악이 늦어지고,
실행 전 상태를 신뢰하기 어렵다.

## Scope
- execution resolution summary 출력
- source precedence 명시
- dry-run resolve command 또는 equivalent output

## Acceptance Criteria
- workflow 실행 직전 provider/model/auth/config source가 출력된다
- stub/fallback 여부가 명시된다
- model/provider mismatch가 실행 전 드러난다

## Out of Scope
- provider onboarding 자체 UX 개편 전체

## Priority
**P0**

---

# Epic 2. Failure Diagnostics

## Problem
에러가 나도 다음이 바로 보이지 않는다.
- unsupported model인지
- auth 누락인지
- binding 실패인지
- fallback/stub 진입인지

## Why it matters
사용자는 로그를 길게 읽어야 하고,
원인 분석 비용이 크다.

## Scope
- short diagnostic errors
- typed error categories
- fallback/stub explicit warnings

## Acceptance Criteria
- 에러가 `무엇이 문제인지 + 어떻게 고칠지`를 짧게 말한다
- unsupported model은 버전/지원 여부를 직접 알려준다
- stub fallback은 실행 초반에 명시된다

## Suggested Error Families
- CONFIG_1001
- MODEL_1002
- AUTH_1003
- FALLBACK_1004
- BIND_1005
- SCHEMA_1006

## Priority
**P0**

---

# Epic 3. Judge / Simple Mode

## Problem
validator/repair 중심 workflow 구조는 judge 같은 단건 inference에 무겁다.

## Why it matters
사용자는 단순한 JSON in/out 작업에도 과한 ceremony를 느낀다.

## Scope
- simple mode 또는 judge mode spec
- 1-step inference optimized path
- JSON input / JSON output 중심 예제

## Acceptance Criteria
- 신규 사용자가 workflow engine 전체 이해 없이 judge task를 실행 가능
- JSON 입력과 출력 경로가 명시적이다
- 에러 메시지가 workflow 모드보다 짧고 직접적이다

## Out of Scope
- full workflow mode 제거

## Priority
**P0**

---

# Epic 4. Input Binding DX

## Problem
`input.task` 중심이라 structured payload binding이 불편하고,
step input이 prompt에 어떻게 합성되는지 불명확하다.

## Why it matters
실전형 integration에서 prompt-first authoring이 부담이 된다.

## Scope
- explicit bindings
- input json/schema/path contract
- binding preview

## Acceptance Criteria
- 사용자가 step만 보고 입력 원천과 출력 경로를 설명할 수 있다
- json/schema binding이 first-class로 표현된다
- prompt preview 또는 equivalent inspection path가 존재한다

## Priority
**P1**

---

# Epic 5. Structured Output / Schema UX

## Problem
structured output은 가능하지만,
schema 강제력과 문서 패턴이 충분히 강하지 않다.

## Why it matters
judge/use-case에서 신뢰도와 예측 가능성이 떨어진다.

## Scope
- output schema first-class support
- validation error clarity
- canonical examples

## Acceptance Criteria
- output schema mismatch가 필드 수준으로 설명된다
- json→json 예제가 공식 quickstart로 제공된다
- repair/fail policy가 명시적이다

## Priority
**P1**

---

# Epic 6. Docs / Onboarding IA Refresh

## Problem
예제는 많지만 실전 시작 경로가 약하다.

## Why it matters
사용자는 “어디서 시작해야 하는지”에서 막힌다.

## Scope
- quickstart split
- troubleshooting guide
- integration recipes

## Acceptance Criteria
- judge quickstart
- workflow quickstart
- provider/auth/model troubleshooting
세 문서가 분리돼 제공된다

## Priority
**P2**

---

# Priority Summary

## P0
1. Resolution Visibility
2. Failure Diagnostics
3. Judge / Simple Mode

## P1
4. Input Binding DX
5. Structured Output / Schema UX

## P2
6. Docs / Onboarding IA Refresh

---

# Recommended Delivery Order

## Phase 1
- resolution summary spec
- diagnostics taxonomy spec
- judge mode spec

## Phase 2
- resolution summary implementation
- short diagnostics implementation
- fallback/stub warning improvement

## Phase 3
- judge mode prototype
- json→json canonical example

## Phase 4
- input binding contract improvements
- schema UX improvements

## Phase 5
- docs IA refresh

---

# Success Metrics

## User-facing
- first-success time 감소
- "왜 실패했는지 모르겠다" 피드백 감소
- judge task onboarding 시간 감소

## Engineering
- provider/model/auth resolution visibility 확보
- typed diagnostics 도입
- docs-first + judge-first 경로 분리

## Product
- runtime strength는 유지하면서 initial integration friction 감소
