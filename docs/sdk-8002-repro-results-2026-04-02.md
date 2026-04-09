# SDK_8002 Minimal Repro Results — 2026-04-02

## 한줄 결론

1차 최소 재현 세트에서는 **SDK_8002가 재현되지 않았다.**
즉, 문제는 단순 write/read/4-step chain/research-style prompt 자체가 아니라,
**더 복합적인 조건 조합**에 있을 가능성이 높다.

---

## 실행 대상

1. `sdk-8002-repro-write-only.yaml`
2. `sdk-8002-repro-read-then-write.yaml`
3. `sdk-8002-repro-multistep-chain.yaml`
4. `sdk-8002-repro-research-prompt.yaml`

실행 스크립트:
- `harnesses/long-running-apps/scripts/run_sdk_8002_repros.sh`

작업 디렉토리:
- `generated/debug/sdk-8002-repros/`

---

## 결과 요약 표

| workflow | 목적 | 결과 |
|---|---|---|
| write-only | 단일 파일 쓰기 | success |
| read-then-write | 2-step artifact propagation | success |
| multistep-chain | planner→contractor→generator→evaluator | success |
| research-prompt | 조사형 prompt + artifact write | success |

---

## 확인된 사실

### 1. 단순 write path는 정상
- single-step write는 안정적으로 완료됨
- 따라서 SDK_8002의 원인이 단순 파일 생성 경로 자체일 가능성은 낮음

### 2. artifact read → write 체인도 정상
- 2-step dependency 자체는 문제 없음
- artifact propagation 기본 동작은 정상으로 보임

### 3. 4-step multi-agent chain도 정상
- planner / contractor / generator / evaluator 구성이 모두 완료됨
- step 수 증가 자체가 단독 원인은 아님

### 4. research-style prompt도 최소 형태에서는 정상
- 조사형 문장만 있다고 즉시 SDK_8002가 발생하지는 않음
- 즉, "research라는 단어" 또는 짧은 비교 지시 자체가 원인은 아님

---

## 현재 가설 업데이트

1차 결과를 반영하면, SDK_8002는 아래 같은 **복합 조건**에서 발생할 가능성이 높다.

### 가설 A. 프롬프트 규모 / 복잡도 문제
- 실제 실패한 workflow는 prompt가 길고 요구사항이 많았음
- 작은 research-style prompt는 성공
- 따라서 token volume, instruction density, or planning burden이 관련 있을 수 있음

### 가설 B. 장시간 step 실행 문제
- 최소 repro는 모두 2~4초대 step으로 끝남
- 실제 실패 케이스는 특정 단계에서 오래 걸리다가 cancel됨
- timeout/cancel semantics 가능성 있음

### 가설 C. workflow 전체 복잡도 문제
- 실제 실패 workflow는 파일 수, 단계 수, 요구사항 수가 많았음
- 특히 research → decision → setup → migration → evaluation 같이 긴 체인에서 취소됨
- 작은 체인은 성공

### 가설 D. 특정 instruction pattern 문제
- "web search를 하라" 같은 실제 외부 조사형 지시
- 또는 다수 파일을 동시에 생성/수정하는 지시
- 또는 매우 구체적인 structured output + long context 조합

---

## 이번 실험으로 배제된 것

아래는 **단독 원인일 가능성이 낮아졌다.**

- 단순 파일 쓰기
- 단순 artifact 읽기/쓰기
- 4-step chain 자체
- 짧은 조사형 prompt 자체

---

## 다음 실험 추천

이제는 최소 repro를 한 단계 올려서 아래를 확인해야 한다.

### 1. Large Prompt Repro
- 실제 실패 workflow 수준으로 긴 task 작성
- 단일 step에서 긴 조사/비교/결정 지시
- 목적: prompt complexity 임계점 확인

### 2. Long Chain Repro
- 6~8 step 체인
- 각 step이 이전 artifact를 읽고 다음 artifact를 생성
- 목적: cumulative orchestration 문제 확인

### 3. Structured Output Stress Repro
- markdown + JSON + validation result를 모두 요구
- 목적: output formatting pressure 관련 여부 확인

### 4. Multi-file Generation Repro
- 한 step에서 여러 파일 생성 지시
- 목적: file materialization pressure 관련 여부 확인

---

## 결론

이번 데이터로는 SDK_8002를 재현하지 못했다.
하지만 그 자체가 중요한 신호다.

즉, 문제는:
- "Obora는 원래 항상 불안정하다" 수준이 아니라
- **특정 복잡도/길이/지시 패턴에서 취소되는 조건부 문제**일 가능성이 높다.

따라서 다음 단계는
**더 큰 프롬프트 / 더 긴 체인 / 더 엄격한 출력 형식**을 가진 stress repro 세트로 넘어가는 것이 맞다.
