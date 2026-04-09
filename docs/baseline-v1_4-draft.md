# Baseline v1.4 Draft

## 한줄 결론

Baseline v1.4의 목표는 **docs-first low-risk lane 안에서 4-file docs batching** 을 여는 것이다.

즉 v1.3가 3-file docs batching을 확립했다면,
v1.4는 다음 질문으로 넘어간다.

> 서로 강하게 결합되지 않은 네 개의 문서 파일을,
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

### Baseline v1.3
- all of v1.2
- 3-file docs batching

### Baseline v1.4 (draft)
- all of v1.3
- **4-file docs batching**

---

## What v1.4 means

v1.4는 아래 조건을 만족하는 경우에만 허용되는 보수적 4-file execution을 뜻한다.

### allowed
- docs-first low-risk lane only
- maximum 4 files
- each file remains independently bounded and reviewable
- wording / clarity / consistency oriented changes only
- no runtime/config/instruction layers

### not allowed
- code/runtime files
- workflow/config edits
- instruction layer edits
- semantically coupled large rewrites
- repo-wide sweep changes

---

## Hard constraints

1. **4 files max** to start
2. all files must already qualify for v1/v1.1/v1.2/v1.3 style low-risk modify
3. each file gets at most 1 bounded change in the first proof
4. every change must remain independently understandable per file
5. re-read verification required for all touched files
6. if any file looks risky, downgrade the whole batch to review-only

---

## Candidate batching shapes

### Example A
- `README.md`
- `README.ko.md`
- `docs/guide-1.md`
- `docs/guide-2.md`

### Example B
- `docs/architecture.md`
- `docs/stack.md`
- `docs/local-smoke-flow.md`
- `docs/faq.md`

### Example C
- `skills/content/SKILL.md`
- `skills/interview/SKILL.md`
- `skills/status/SKILL.md`
- `skills/export/SKILL.md`

---

## Why batching breadth next

현재까지 1-file, 2-file, 3-file batching은 충분히 검증됐다.
다음 일반화 포인트는 여전히 execution breadth 쪽이다.

즉:
- one file → proven
- two files → proven
- three files → proven
- four files → next controlled step

---

## Success criteria

v1.4가 실증되었다고 보려면:
1. 실제 repo에서 4-file docs batch 1건 성공
2. 네 파일 모두 bounded low-risk change
3. 네 파일 모두 re-read verification 완료
4. hold-zone separation 유지
5. no semantic expansion

---

## Candidate first proof

가장 자연스러운 첫 후보:
- `plant-companion`
- `README.md`
- `docs/architecture.md`
- `docs/stack.md`
- `docs/local-smoke-flow.md`

이유:
- docs lane이 명확함
- 이미 세 파일 proof가 있음
- README까지 합쳐도 여전히 docs-first low-risk lane 유지 가능

---

## Final statement

> Baseline v1.4 should be treated as the first controlled expansion from three-file docs batching to four-file docs batching within the same low-risk documentation lane.
