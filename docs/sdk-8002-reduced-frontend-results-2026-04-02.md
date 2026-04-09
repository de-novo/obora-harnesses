# SDK_8002 Reduced Frontend Repro Results — 2026-04-02

## 한줄 결론

`todo-frontend-upgrade`에서 실패했던 핵심 축을 줄여서 만든 reduced repro 3종도 모두 성공했다.
따라서 SDK_8002는 아래 수준에서는 재현되지 않는다.

- research only
- setup only
- research + contract + setup 조합

즉, 실패 조건은 **더 큰 실제 workflow 조합**에 있을 가능성이 높다.

---

## 실행 대상

1. `sdk-8002-reduced-frontend-research-only.yaml`
2. `sdk-8002-reduced-frontend-setup-only.yaml`
3. `sdk-8002-reduced-frontend-combined.yaml`

---

## 결과 요약

| workflow | 구성 | 결과 |
|---|---|---|
| reduced-frontend-research-only | research 1-step | success |
| reduced-frontend-setup-only | setup 1-step | success |
| reduced-frontend-combined | research + contract + setup 3-step | success |

---

## 해석

이번 결과로 약해진 가설:

1. research step 자체가 원인이다 → 약화
2. setup/multi-file generation 자체가 원인이다 → 약화
3. research + contract + setup 조합만으로도 실패한다 → 약화

즉, 실제 실패 workflow에는 이번 reduced case보다 더 많은 부담이 있었을 가능성이 높다.

유력 후보:
- 추가 migration 단계
- style migration 단계
- evaluator + retry loop
- 더 긴 전체 workflow 체인
- 더 많은 파일 생성/수정
- 실제 기존 파일을 읽고 변환하는 작업

---

## 현재 결론

SDK_8002는 지금까지의 실험 기준으로 보면:
- 단순 path 버그가 아니고
- 단일 변수 버그도 아니며
- 실제 production-like workflow complexity에 가까워질 때만 드러나는 조건부 문제일 수 있다.

가장 효율적인 다음 단계는
**실패했던 원래 workflow를 반씩 잘라가며 binary reduction** 하는 것이다.

예:
- original 실패 workflow
- 절반 A (research~contract~setup)
- 절반 B (migration~style~evaluate)
- 이후 실패하는 절반만 다시 절반으로 축소

이 방식이 가장 빨리 실패 지점을 특정한다.
