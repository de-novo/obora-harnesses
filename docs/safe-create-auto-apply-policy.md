# Safe Create Auto-Apply Policy

## 목적

초기 auto-apply는 모든 mode를 자동 적용하지 않는다.
우선 **safe create mode**만 제한적으로 자동 적용한다.

---

## 허용 대상

다음 조건을 모두 만족하는 create unit만 auto-apply 가능하다.

1. `mode` 가 `create`
2. targetFiles 수가 1~2개
3. destructive change가 아님
4. 기존 파일 overwrite가 아님
5. impactNotes 에 고위험 표식이 없음
6. 실행 순서상 선행 destructive batch가 없음

---

## 보류 대상

다음은 기본적으로 hold 한다.

- modify
- delete
- prune
- refactor
- restructure
- migrate
- create 이지만 overwrite 가능성이 있는 경우
- create 이지만 targetFiles 가 너무 많은 경우

---

## applyStrategy 규칙

- safe create → `apply`
- create but uncertain → `prepare`
- destructive/high-risk/uncertain existing-state interaction → `hold`

---

## 출력

auto-apply 정책을 반영한 실행 결과는 최소 아래를 남긴다.

- 어떤 batch가 auto-apply 가능했는지
- 어떤 batch가 hold 되었는지
- hold 사유
- overwrite 위험 여부
