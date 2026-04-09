# Modify Concretizer v2 Plan

## 목표

prepare 상태의 modify unit도 버리지 않고,
**reviewable concrete file shortlist** 로 낮추는 v2를 설계한다.

---

## v1 한계

현재 v1은 아래 조건을 동시에 요구한다.
- modify
- applyStrategy=apply
- concrete single-file target

이 기준은 안전하지만,
실제 broad repo 개선 요청에서는 후보가 0개가 되기 쉽다.

---

## v2 방향

v2는 두 개의 출력 레인을 가진다.

### lane A: apply-ready candidates
- mode=modify
- applyStrategy=apply
- concrete single-file
- exactReplaceReady 가능성 높음

### lane B: review-ready candidates
- mode=modify
- applyStrategy=prepare 허용
- glob/pattern에서 concrete file shortlist 도출
- exactReplaceReady=false 가능
- human/next-step review 대상

---

## 기대 효과

- broad modify unit이 전부 0개로 사라지는 문제 완화
- planning과 execution 사이의 중간 review layer 형성
- 실제 repo에서 docs/workflows/scripts shortlist를 뽑아 후속 판단 가능

---

## v2 핵심 규칙

1. apply-ready 와 review-ready를 분리한다.
2. wildcard-only (`*`) 는 기본 skip 또는 very-low-confidence review 로 둔다.
3. docs/workflows/scripts 는 대표 candidate 소수만 뽑는다.
4. candidate 수가 많으면 aggressive trimming 한다.
5. review-ready는 실제 apply 입력이 아니라 review queue 아티팩트다.

---

## 권장 출력

- `artifacts/modify-concrete-candidates.json`
- `artifacts/modify-review-queue.json`
- `artifacts/modify-concretization-summary.md`

---

## 추천 적용 대상

- docs/**/*.md
- .github/workflows/*.yml
- scripts/**/*.sh

이 세 영역은 broad pattern에서 concrete shortlist를 만들기 좋다.
