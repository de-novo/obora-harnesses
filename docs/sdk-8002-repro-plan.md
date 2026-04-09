# SDK_8002 Minimal Repro Plan

## 목표

`SDK_8002 / Execution cancelled` 가 어떤 조건에서 발생하는지 가장 작은 단위로 분리해서 확인한다.

핵심은 추측이 아니라 **실패 지점을 단계별로 격리**하는 것이다.

---

## 가설

현재 의심 축은 4개다.

1. **단순 파일 쓰기 자체는 정상**일 수 있다.
2. **artifact를 읽고 다음 step에서 다시 쓰는 체인**에서 문제가 생길 수 있다.
3. **step 수가 늘어나면서 cancel semantics** 가 깨질 수 있다.
4. **조사형 프롬프트(research-style prompt)** 가 포함되면 취소될 수 있다.

---

## repro workflow 세트

### 1. `sdk-8002-repro-write-only.yaml`
목적:
- 가장 단순한 single-step write 확인

성공 시 의미:
- 파일 쓰기 기본 경로는 살아 있음

실패 시 의미:
- 가장 기초적인 generation/write path 문제 가능성

### 2. `sdk-8002-repro-read-then-write.yaml`
목적:
- artifact read → next-step write 체인 확인

성공 시 의미:
- 2-step 의존성 체인은 정상일 가능성

실패 시 의미:
- step dependency 또는 artifact propagation 문제 가능성

### 3. `sdk-8002-repro-multistep-chain.yaml`
목적:
- planner → contractor → generator → evaluator 4-step 체인 확인

성공 시 의미:
- multi-step chaining 자체는 가능

실패 시 의미:
- step 수 증가 / role 전환 / evaluator return path 문제 가능성

### 4. `sdk-8002-repro-research-prompt.yaml`
목적:
- 조사형 prompt + artifact write 상황 확인

성공 시 의미:
- research-style prompt 자체는 문제 아닐 수 있음

실패 시 의미:
- 조사형 지시 / 긴 reasoning / external-knowledge style prompt 에서 cancel 가능성

---

## 판정 규칙

각 workflow마다 아래를 기록한다.

- command
- exit code
- debug trace path
- artifacts 생성 여부
- run bundle 여부
- final classification
  - success
  - failed

---

## 권장 실행 순서

1. write-only
2. read-then-write
3. multistep-chain
4. research-prompt

이 순서로 해야 원인을 뒤에서 앞으로 좁히지 않고,
가장 단순한 경로부터 확장해 나갈 수 있다.

---

## 기대 산출물

- 실패/성공 매트릭스
- 최소 재현 경로
- Obora 개선 포인트
- 다음 액션
  - timeout 조정이 의미 있는지
  - research step 분리가 의미 있는지
  - multi-step chaining이 원인인지
  - evaluator return 형식이 원인인지
