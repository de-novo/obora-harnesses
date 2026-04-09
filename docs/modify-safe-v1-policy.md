# Modify-Safe v1 Policy

## 목적

`modify-safe v1`은 기존 파일에 대한 실제 자동 적용을 아주 제한적으로 허용한다.

핵심 목표:
- 기존 파일 전체 덮어쓰기 금지
- 단일 파일만 대상
- 명확히 경계가 잡힌 구간만 수정
- destructive / restructure 성격은 제외

---

## 허용 대상

다음 조건을 모두 만족해야 실제 modify apply 가능하다.

1. mode = `modify`
2. targetFiles 길이 = 1
3. 대상 파일이 현재 존재함
4. 수정 범위가 명확한 section 또는 exact replace 로 표현 가능함
5. 파일 전체 재작성 아님
6. destructive / prune / delete / refactor / restructure / migrate 아님
7. applyStrategy = `apply`

---

## 금지 대상

- 파일 전체 rewrite
- 파일 이동/이름 변경
- delete / prune
- refactor / restructure
- 여러 파일 동시 수정
- 수정 경계가 불명확한 경우
- broad stylistic rewrite

---

## 초기 적용 방식

v1에서는 실제 자동 수정 범위를 다음 둘 중 하나로 제한한다.

1. **exact replace**
   - oldText 와 newText 가 명시된 경우

2. **section replace**
   - heading/marker 등 명확한 구간 경계가 있는 경우

초기 버전은 exact replace 중심이 더 안전하다.

---

## 필수 기록

실제 modify가 일어나면 최소 아래를 남긴다.
- modified file path
- replace mode (exact / section)
- replaced target description
- skipped file path
- skip reason
- overwrite 여부 (항상 false 의미로 전체 덮어쓰기 금지)

---

## 안전성 원칙

v1은 modify 전체를 자동화하는 것이 아니라,
**single-file exact replace**를 baseline으로 삼는다.

즉 이 정책의 목적은 가장 안전한 modify subset만 실제 적용하는 것이다.
