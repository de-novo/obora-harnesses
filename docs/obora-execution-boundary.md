# Obora Execution Boundary

## 목적

이 문서는 **Obora 기반 실험/생성 작업에서 사람 개입 경계**를 명확히 정의한다.
핵심 목적은 다음과 같다.

1. Obora 자체 capability를 순수하게 검증한다.
2. 사람 수동 개입으로 성공처럼 보이는 왜곡을 막는다.
3. 실패를 실패로 기록해 Obora 개선 포인트를 드러낸다.
4. 반복 가능한 실험 규약을 만든다.

---

## 핵심 원칙

### 1. Obora 작업은 Obora가 끝내야 한다
Obora를 사용하기로 한 작업은, 결과 생성의 주체가 Obora여야 한다.

- 허용: 실행, 관찰, 로그 수집, 결과 판정, 문서화
- 금지: 사람이 중간에 코드를 직접 작성해서 결과물을 완성하는 것

즉, **CTO는 Obora 작업의 감독자이지 구현자가 아니다.**

### 2. 수동 개입 결과를 Obora 성공으로 간주하지 않는다
Obora 실행 중 실패한 뒤 사람이 직접 수정해서 결과물이 완성되더라도,
그 작업은 **Obora 성공이 아니라 수동 복구 성공**으로 기록한다.

### 3. 실패는 숨기지 않는다
다음과 같은 경우는 실패로 기록한다.

- SDK_8002 등으로 실행 취소
- workflow 중단
- artifact 미생성
- run bundle 누락
- acceptance criteria 불충족
- smoke/eval 실패

### 4. 결과물보다 재현성이 우선이다
한 번 우연히 나온 결과보다,
같은 조건에서 다시 실행했을 때 재현 가능한지가 더 중요하다.

---

## 역할 분리

### Obora의 역할
- 조사
- 계획
- 코드 생성
- 산출물 작성
- 평가

### CTO의 역할
- workflow 설계
- 실행 트리거
- 로그/아티팩트 수집
- 성공/실패 판정
- 비교 분석
- 개선 포인트 도출

### CTO가 하면 안 되는 것
Obora 실험이 진행 중일 때 아래 행위는 금지한다.

- Obora 대신 코드 직접 작성
- 실패한 step 결과를 수동으로 보정
- artifact를 수동 생성하고 Obora 산출물처럼 취급
- 최종 결과만 맞으면 된다고 보고 과정 실패를 덮는 행위

---

## 허용되는 개입 / 금지되는 개입

### 허용되는 개입
다음은 허용된다.

1. workflow YAML 작성/수정
2. config 조정
3. timeout/retry/sandbox 설정 조정
4. 실행 명령 호출
5. 로그 확인
6. run bundle 수집
7. 실패 원인 분석
8. Obora 결과물을 별도 검증하는 smoke test 실행
9. 문서화

### 금지되는 개입
다음은 금지된다.

1. Obora step 실패 후 사람이 코드 직접 작성
2. generated 디렉토리 안 파일을 수동 수정해서 성공처럼 보고
3. 조사 단계에서 Obora 대신 사람이 직접 조사하고 그 결과를 Obora 성공처럼 기록
4. 평가 실패 후 결과만 맞추기 위해 수동 수정
5. artifact 누락을 사람이 채워 넣고 정상 실행처럼 간주

---

## 작업 유형별 정책

### A. Pure Obora Run
정의:
- 계획, 조사, 생성, 평가를 모두 Obora가 수행
- 사람은 실행/관찰/판정만 수행

판정:
- 성공 시에만 Obora 성공으로 기록
- 중간 실패 시 실패로 기록

### B. Assisted Run
정의:
- Obora를 사용했지만 사람이 조사/코드/산출물 일부를 직접 보완

판정:
- Obora 성공으로 기록하지 않음
- "Assisted" 또는 "Manual Recovery"로 별도 기록

### C. Manual Implementation
정의:
- 사람이 직접 구현

판정:
- Obora capability 검증 결과에 포함하지 않음
- 단지 reference implementation 으로만 활용

---

## 성공 기준

Obora 성공으로 기록되려면 아래를 모두 만족해야 한다.

1. workflow가 종료까지 완주한다
2. 필수 artifact가 생성된다
3. run bundle 또는 결과 추적이 가능하다
4. acceptance criteria를 만족한다
5. deterministic smoke test를 통과한다
6. 생성된 결과물이 수동 수정 없이 작동한다

---

## 실패 기준

다음 중 하나라도 해당하면 Obora 실패다.

1. 실행 중 취소됨 (`SDK_8002`, `Execution cancelled` 등)
2. workflow 중간 중단
3. artifact 누락
4. 산출물 미생성
5. smoke test 실패
6. evaluator 실패
7. 사람이 직접 개입하지 않으면 완료되지 않음

---

## 실험 기록 포맷

각 Obora 실험은 최소 아래 항목을 남긴다.

- 목표
- workflow 경로
- config 경로
- model/provider
- sandbox 설정
- 실행 시간
- step별 결과
- 생성 artifact 목록
- run bundle 유무
- smoke 결과
- 최종 판정
  - success
  - failed
  - assisted
  - manual-reference

---

## 필수 artifact 최소 세트

가능하면 아래 최소 세트를 유지한다.

- `spec.md`
- `task-contract.json`
- `qa-report.json`
- debug trace / execution log
- run bundle path (존재 시)

artifact가 없으면 그 자체로 실패 신호로 취급한다.

---

## 조사 작업 정책

조사도 Obora capability 검증 대상이면,
**조사 역시 Obora가 수행해야 한다.**

따라서:
- 사람이 직접 웹 검색 후 결론을 대신 작성하면 Pure Obora 성공이 아님
- 이 경우는 `assisted` 로 기록한다

즉,
**조사 단계만 사람이 하고 구현만 Obora가 해도 순수 Obora 성공은 아니다.**

---

## React 업그레이드 케이스에 대한 적용

이번 Todo React 업그레이드 건은 결과물 자체는 성공적이지만,
Obora execution boundary 기준으로는 다음처럼 분류한다.

- 결과물 상태: 성공
- Obora capability 검증 상태: 실패 또는 assisted
- 이유:
  - 조사/구현 과정에서 Obora가 끝까지 완주하지 못함
  - SDK_8002 발생
  - 중간에 CTO 직접 개입이 들어감

따라서 이 건은 **Pure Obora Success로 기록하지 않는다.**

---

## 권장 운영 절차

1. workflow 작성
2. Obora 실행
3. 로그/아티팩트 수집
4. smoke/eval 실행
5. 사람 개입 여부 확인
6. 아래 중 하나로 판정
   - success
   - failed
   - assisted
   - manual-reference
7. 결과 문서화

---

## 의사결정 규칙

### Obora 작업 도중 실패하면
- 먼저 실패로 기록한다
- 필요하면 별도 트랙에서 manual recovery 수행
- 단, manual recovery 결과를 Obora 성공과 합치지 않는다

### Obora 작업 도중 사람이 직접 구현하고 싶어지면
- 해당 시점부터 트랙을 분리한다
- 문서에 다음처럼 명시한다
  - "여기까지는 Obora run"
  - "여기부터는 manual implementation"

---

## 요약

이 문서의 핵심은 단순하다.

> **Obora를 쓰기로 했으면, Obora가 끝내야 한다.**
> 사람이 중간에 완성하면 그것은 Obora 성공이 아니다.

이 원칙을 지켜야만:
- Obora capability를 정직하게 평가할 수 있고
- SDK_8002 같은 문제를 제대로 드러낼 수 있으며
- 장기적으로 개선 가능한 실험 체계를 유지할 수 있다.

---

## 다음 적용 대상

이 원칙은 우선 아래 작업들에 적용한다.

1. frontend framework research
2. React upgrade workflow
3. SDK_8002 최소 재현 workflow
4. 이후 long-running-apps harness 실험 전반
