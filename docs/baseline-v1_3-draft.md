# Baseline v1.3 Draft

## 한줄 결론

Baseline v1.3의 목표는 **docs-first low-risk lane 안에서 3-file docs batching** 을 여는 것이다.

즉 v1.2가 2-file docs batching을 확립했다면,
v1.3은 다음 질문으로 넘어간다.

> 서로 강하게 결합되지 않은 세 개의 문서 파일을,
> 여전히 낮은 리스크로 묶어 실행할 수 있는가?

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

### Baseline v1.2
- all of v1.1
- 2-file docs batching

### Baseline v1.3 (draft)
- all of v1.2
- **3-file docs batching**

---

## What v1.3 means

v1.3는 아래 조건을 만족하는 경우에만 허용되는 보수적 3-file execution을 뜻한다.

### allowed
- docs-first low-risk lane only
- maximum 3 files
- each file remains independently bounded and reviewable
- wording / clarity / consistency oriented changes only
- no runtime/config/instruction layers

### not allowed
- code/runtime files
- workflow/config edits
- instruction layer edits
- semantically coupled large rewrites
- repo-wide consistency sweeps

---

## Hard constraints

1. **3 files max** to start
2. all files must already qualify for v1/v1.1/v1.2 style low-risk modify
3. each file gets at most 1 bounded change in the first proof
4. every change must remain independently understandable per file
5. re-read verification required for all touched files
6. if any file looks risky, downgrade the whole batch to review-only

---

## Candidate batching shapes

### Example A
- `README.md`
- `README.ko.md`
- `CHANGELOG.md`

### Example B
- `docs/architecture.md`
- `docs/stack.md`
- `docs/local-smoke-flow.md`

### Example C
- `skills/content/SKILL.md`
- `skills/interview/SKILL.md`
- `skills/status/SKILL.md`

---

## Why batching breadth next

현재까지 single-file gradient와 2-file batching은 충분히 검증됐다.
다음 일반화 포인트는 여전히 semantic depth보다 execution breadth 쪽이다.

즉:
- 한 파일 → proven
- 두 파일 → proven
- 세 파일 → next controlled step

---

## Success criteria

v1.3가 실증되었다고 보려면:
1. 실제 repo에서 3-file docs batch 1건 성공
2. 세 파일 모두 bounded low-risk change
3. 세 파일 모두 re-read verification 완료
4. hold-zone separation 유지
5. no semantic expansion

---

## Candidate first proof

가장 자연스러운 첫 후보:
- `plant-companion`
- `docs/architecture.md`
- `docs/stack.md`
- `docs/local-smoke-flow.md`

이유:
- docs lane이 명확함
- 세 파일 모두 low-risk docs surface
- architecture / stack / local flow라는 느슨하게 연결된 문서군이라 batching 가치가 있음

---

## Final statement

> Baseline v1.3 should be treated as the first controlled expansion from two-file docs batching to three-file docs batching within the same low-risk documentation lane.
