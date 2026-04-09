# Baseline v1.2 Draft

## 한줄 결론

Baseline v1.2의 목표는 **docs-first low-risk lane 안에서 multi-file docs batching** 을 여는 것이다.

즉 v1.1이 single-file 범위에서 multi-paragraph bounded replace까지 확립했다면,
v1.2는 다음 질문으로 넘어간다.

> 서로 강하게 결합되지 않은 여러 문서 파일을,
> 여전히 낮은 리스크로 묶어서 실행할 수 있는가?

---

## Relationship to prior baselines

### Baseline v1
- safe-create
- exact-replace
- small block replace
- paragraph-bounded replace

### Baseline v1.1
- all of v1
- multi-paragraph bounded replace

### Baseline v1.2 (draft)
- all of v1.1
- **multi-file docs batching**

---

## What v1.2 means

v1.2는 아래 조건을 만족하는 경우에만 허용되는 보수적 multi-file execution을 뜻한다.

### allowed
- docs-first low-risk lane only
- multiple files, but each file remains bounded and low-risk
- wording / clarity / consistency oriented changes only
- no runtime/config/instruction layers
- each file still individually reviewable

### not allowed
- code/runtime files
- workflow/config edits
- instruction layer edits
- semantically coupled large rewrites
- broad repo-wide cleanup

---

## Candidate batching shape

v1.2에서 허용 가능한 예시는 다음과 같다.

### Example A
- `README.md`
- `README.ko.md`

Use case:
- terminology consistency alignment
- same concept wording cleanup

### Example B
- `docs/stack.md`
- `docs/architecture.md`

Use case:
- wording consistency across architecture/stack notes

### Example C
- `skills/content/SKILL.md`
- `skills/interview/SKILL.md`

Use case:
- protocol wording consistency

---

## Hard constraints

1. **2 files max** to start
2. both files must already qualify for v1/v1.1 style low-risk modify
3. each file change must remain bounded
4. changes must be independently understandable per file
5. re-read verification required for both files
6. if either file looks risky, the whole batch should fall back to review-only

---

## Why batching next

현재까지는 single-file gradient를 충분히 검증했다.
다음 일반화 포인트는 semantic depth보다 execution breadth 쪽이다.

즉:
- 한 파일에서 안전하게 되는가 → already proven
- 두 파일을 함께 처리해도 safety posture가 유지되는가 → next proof

---

## Success criteria

v1.2가 실증되었다고 보려면:
1. 실제 repo에서 2-file docs batch 1건 성공
2. 두 파일 모두 bounded low-risk change
3. re-read verification 완료
4. hold-zone separation 유지
5. no semantic expansion

---

## Candidate first proof

가장 자연스러운 첫 후보:
- `polysona`의 `README.md` + `README.ko.md`

이유:
- 이미 각각 low-risk modify proof가 있음
- user-facing docs pair라 batching 가치가 큼
- docs-first lane 유지 가능

---

## Final statement

> Baseline v1.2 should be treated as the first controlled expansion from single-file bounded modify to two-file docs batching within the same low-risk documentation lane.
