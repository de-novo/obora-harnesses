# Modify Concretization Spec

## 목표

change-engine의 modify units를
`modify-safe applier`가 소비 가능한 concrete file candidates로 변환한다.

---

## 입력

- `artifacts/micro-units.json`
- `artifacts/apply-order.json`
- repository file tree / inventory
- `docs/modify-concretization-policy.md`

---

## 출력

- `artifacts/modify-concrete-candidates.json`

Required shape:

```json
{
  "candidates": [
    {
      "unitId": "u17",
      "sourcePattern": "docs/**/*.md",
      "targetFile": "docs/architecture.md",
      "reason": "...",
      "priority": "high",
      "exactReplaceReady": false
    }
  ],
  "skippedUnits": [
    {
      "unitId": "u29",
      "reason": "Wildcard-only target too broad to concretize safely"
    }
  ],
  "notes": "..."
}
```

---

## 단계

### 1. extract modify-pattern units
- mode=modify만 추출
- delete/prune/refactor/restructure 제외

### 2. read repository tree
- 실제 파일 목록을 확보
- binary/generated/vendor 제외

### 3. expand patterns conservatively
- glob을 파일 후보로 축소
- wildcard-only target은 기본 skip
- 너무 많은 후보가 나오면 small representative subset만 허용

### 4. prioritize concrete candidates
- docs/workflows/scripts 우선
- single-file exact-replace 가능성이 높은 파일 우선

### 5. write concrete candidate artifact
- 각 candidate를 file-level로 기록

---

## 안전성 원칙

- concretization은 broad plan을 좁히는 단계이지, broad plan을 실행하는 단계가 아니다
- file candidate가 너무 많으면 적극적으로 skip/hold 한다
- confidence가 낮으면 exactReplaceReady=false 로 둔다
