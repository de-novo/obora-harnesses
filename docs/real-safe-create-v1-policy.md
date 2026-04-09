# Real Safe Create v1 Policy

## 목적

이 정책은 `safe-create auto-apply` 중에서도 가장 보수적인 형태만 실제 적용하도록 제한한다.

v1에서는 다음만 허용한다.

- **새 파일 생성(create)**
- **target file이 현재 존재하지 않음**
- **파일 수 1개인 unit만 허용**
- **destructive/high-risk 아님**
- **overwrite 없음**

---

## 허용 조건

다음 조건을 모두 만족해야 실제 apply 가능하다.

1. mode = `create`
2. unit의 targetFiles 길이 = 1
3. target file currently does not exist
4. destructive / prune / delete / refactor / restructure / migrate 아님
5. impactNotes 에 high-risk 성격 없음
6. applyStrategy = `apply`

---

## 금지 조건

다음은 모두 실제 apply 금지다.

- 기존 파일 덮어쓰기
- modify
- delete / prune
- refactor / restructure
- migrate
- targetFiles 2개 이상
- batch 단위 destructive 포함
- uncertain / hold / prepare 전략

---

## 출력 원칙

실제 apply가 일어나면 최소 아래를 남긴다.

- applied file path
- skipped file path
- skip reason
- overwrite 여부 (항상 false 여야 함)
- apply summary

---

## 안전성 원칙

v1은 “실제 변경 자동 적용”의 최소 안전 버전이다.

즉 이 정책의 목적은 범위를 넓히는 것이 아니라,
가장 안전한 create case만 실제로 연결해 보는 것이다.
