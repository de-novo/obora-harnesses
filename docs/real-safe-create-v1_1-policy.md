# Real Safe Create v1.1 Policy

## 목적

v1.1은 safe-create v1에서 한 단계만 더 나아가,
**조건을 만족하는 새 파일 1개 대상에 한해서만 실제 write**를 허용한다.

---

## 실제 write 허용 조건

다음 조건을 모두 만족해야 한다.

1. mode = `create`
2. target file exactly 1
3. target file currently does not exist
4. applyStrategy = `apply`
5. payload content is non-empty
6. overwrite risk = false
7. destructive/high-risk 아님

---

## 금지 조건

- 기존 파일 존재 시 write 금지
- modify/delete/prune/refactor/restructure/migrate 금지
- multi-file write 금지
- prepare/hold batch 금지

---

## 필수 기록

- applied file path
- skipped file path
- skip reason
- overwrite detected 여부
- apply result summary
