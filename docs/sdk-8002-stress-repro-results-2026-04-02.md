# SDK_8002 Stress Repro Results — 2026-04-02

## 한줄 결론

2차 stress repro에서도 **SDK_8002는 재현되지 않았다.**
즉, 아래 요소들은 **단독 원인으로 보기 어렵다.**

- 큰 프롬프트
- 구조화된 출력
- 긴 chain

문제는 이들 중 하나가 아니라, **실제 실패 workflow에 존재한 복합 조합**일 가능성이 높다.

---

## 실행 대상

1. `sdk-8002-repro-large-prompt-small-output.yaml`
2. `sdk-8002-repro-medium-prompt-structured-output.yaml`
3. `sdk-8002-repro-long-chain-short-prompts.yaml`

실행 스크립트:
- `harnesses/long-running-apps/scripts/run_sdk_8002_stress_repros.sh`

작업 디렉토리:
- `generated/debug/sdk-8002-stress-repros/`

---

## 결과 요약 표

| workflow | 분리한 변수 | 결과 |
|---|---|---|
| large-prompt-small-output | 큰 프롬프트, 작은 출력 | success |
| medium-prompt-structured-output | 구조화된 출력 압박 | success |
| long-chain-short-prompts | 긴 체인 | success |

---

## 해석

### 1. 프롬프트 길이 단독 가설 약화
큰 프롬프트 + 작은 출력은 성공했다.
따라서 "컨텍스트 토큰 수만 많으면 바로 cancel된다"는 가설은 약해졌다.

### 2. structured output 단독 가설 약화
artifact + strict JSON return 조합도 성공했다.
따라서 structured output pressure 단독 원인 가설도 약해졌다.

### 3. chain depth 단독 가설 약화
8-step short-prompt chain도 성공했다.
따라서 step 수 증가 자체만으로 cancel된다고 보기 어렵다.

---

## 현재 가장 유력한 가설

실제 실패 케이스는 아래가 한꺼번에 들어 있었다.

1. 긴 조사형/비교형 prompt
2. 다단계 chain
3. 여러 역할(planner, contractor, generator, evaluator)
4. 여러 artifact 타입
5. 구현 지시 + 결정 지시 + 평가 지시 동시 존재
6. 실제 파일 구조가 있는 작업 디렉토리
7. 더 긴 실행 시간

즉 SDK_8002는 **단일 변수 문제가 아니라 조합 임계치 문제**일 가능성이 높다.

---

## 다음 추천 실험

이제는 실제 실패 패턴에 더 가깝게 붙여야 한다.

### 1. Combined Stress Repro
한 workflow 안에 아래를 같이 넣는다.
- 긴 조사형 prompt
- 5~6 step chain
- artifact read/write
- structured JSON return

### 2. Real Workspace Repro
빈 debug 디렉토리가 아니라,
실제 monorepo 또는 packages/web 같은 실제 파일 구조가 있는 곳에서 실행

### 3. Multi-file Generation Repro
한 step에서 여러 파일 생성 지시를 넣는다.

### 4. Near-Real Workflow Reduction
실패했던 `todo-frontend-upgrade.yaml` 를 반으로 줄인 reduced case를 만든다.
- 성공/실패 경계선을 찾는 방식

---

## 결론

현재까지의 데이터로는:

- 단순 write 아님
- read/write 체인 아님
- 긴 chain 단독 아님
- 큰 prompt 단독 아님
- structured output 단독 아님

따라서 SDK_8002는
**복합 complexity threshold 문제** 또는
**실제 workflow 패턴 특이 문제**일 가능성이 높다.

다음 단계는 단순 축 분리보다,
**실패했던 실제 workflow를 축소(reduction)해서 경계 조건을 찾는 것**이 더 효율적이다.
