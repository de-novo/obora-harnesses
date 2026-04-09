# Modify Concretizer v2 Policy

## 목적

v2의 목적은 broad modify unit을 두 종류의 concrete output으로 나누는 것이다.

1. **apply-ready candidates**
2. **review-ready candidates**

v1은 `applyStrategy=apply` 와 concrete single-file 조건을 동시에 요구해서,
실제 repo에서는 후보가 0개가 되기 쉬웠다.

v2는 `prepare` 상태 modify도 **review queue** 로 살린다.

---

## 출력 레인

### lane A: apply-ready
조건:
- mode = modify
- applyStrategy = apply
- concrete single-file target
- exact replace 가능성 높음

### lane B: review-ready
조건:
- mode = modify
- applyStrategy = prepare 허용
- glob/pattern 에서 concrete file shortlist 도출 가능
- 실제 apply 입력이 아니라 review queue 출력

---

## 허용 규칙

v2는 다음을 할 수 있다.
- broad modify pattern을 concrete file shortlist로 축소
- docs/workflows/scripts 중심 대표 후보를 소수 선택
- apply-ready 와 review-ready를 구분

v2는 다음을 하지 않는다.
- 실제 modify write
- delete/prune apply
- refactor/restructure apply
- wildcard 전체 실행

---

## 후보 선택 원칙

우선순위:
1. docs markdown file
2. README 계열
3. workflow yaml/yml
4. scripts sh/py

제한:
- wildcard-only (`*`) 는 기본 skip
- candidate 수가 많으면 aggressive trimming
- binary/generated/vendor/lockfile 제외
- concrete path가 아니면 apply-ready 금지

---

## review-ready 의미

review-ready는 실제 자동 수정 대상이 아니라,
다음 단계에서 사람이 검토하거나 exact-replace readiness 평가로 넘길 수 있는 **중간 산출물** 이다.

즉 review-ready는:
- 실행 큐가 아니라
- review 큐다.
