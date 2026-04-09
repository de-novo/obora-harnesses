# Cross-Repo Docs-First Baseline Proof

## 한줄 결론

현재 Generic Micro-Step System의 **docs-first real-repo baseline** 은 최소 두 개의 실제 repo에서 재현되었다.

검증 대상:
- `polysona`
- `obora-todoapp`

즉 baseline은 더 이상 단일 사례(one-off)가 아니라,
**재현 가능한 실제 repo 실행 패턴** 으로 볼 수 있다.

---

## What baseline means here

현재 baseline은 다음과 같은 보수적 실행 경계를 의미한다.

### safe lane
- safe-create support docs
- single-line exact replace
- single-sentence exact replace
- small contiguous block replace
- paragraph-bounded replace
- post-change re-read verification

### hold lane
- instruction files
- runtime hooks/scripts
- app/server code
- workflow/runtime core
- multi-file or higher-risk changes

즉 baseline은 “아무거나 자동 수정”이 아니라,
**risk를 분리하고 low-risk 문서층부터 실제 적용하는 실행 방식** 이다.

---

## Repo 1: polysona

### repo profile
- mixed-surface repo
- docs + skills + personas + hooks + client/server + instruction layer 혼합

### proven in practice
- safe-create support docs 생성
- exact-replace on:
  - `skills/content/SKILL.md`
  - `skills/interview/SKILL.md`
  - `README.md`
  - `README.ko.md`
- small section-local block replace on `README.md`
- paragraph-bounded replace on `README.md`

### meaning
`polysona`는 mixed-surface repo에서도 docs-first lane 분리가 가능하고,
bounded modify가 실제로 동작함을 보여줬다.

---

## Repo 2: obora-todoapp

### repo profile
- workflow/docs-heavy repo
- `README.md`, `docs/**/*.md`, `.obora/workflows`, `scripts/` 분리 구조

### proven in practice
- safe-create support doc 생성
- exact-replace on `README.md`
- small contiguous block replace on `README.md`
- paragraph-bounded replace on `README.md`

### meaning
`obora-todoapp`은 workflow-heavy repo에서도 docs-first lane 분리가 가능하고,
`polysona`에서 검증한 proof sequence가 재현됨을 보여줬다.

---

## Why this matters

이 cross-repo proof는 세 가지를 보여준다.

### 1. not repo-specific
baseline이 특정 repo 구조 하나에만 묶여 있지 않다.
- mixed-surface repo (`polysona`)
- workflow/docs-heavy repo (`obora-todoapp`)
둘 다에서 재현되었다.

### 2. docs-first entry is a strong universal strategy
처음부터 runtime/code layer로 가지 않고,
docs-first low-risk lane으로 진입하는 전략이 현실적이다.

### 3. modify expansion gradient is working
modify 확장 순서가 안정적으로 유지된다.
- exact replace
- small block replace
- paragraph replace

이 gradient가 실제 repo 두 곳에서 모두 성립했다.

---

## Current proven boundary

현재까지 과장 없이 말할 수 있는 범위는 다음이다.

> 실제 repo에서,
> docs-first low-risk lane을 분리하고,
> safe-create와 bounded modify를 점진적으로 수행할 수 있다.

더 구체적으로는:
- concrete single-file docs
- bounded wording edits
- bounded contiguous block edits
- paragraph-level bounded edits

까지는 실증되었다.

---

## Not yet proven

다음은 아직 cross-repo proof 범위 밖이다.

- multi-paragraph replace
- section-level semantic rewrite
- hooks/script modify apply
- client/server/code modify apply
- multi-file batching
- rollback-aware execution

즉 현재 일반화 범위는 여전히 **documentation-first low-risk lane** 까지다.

---

## Recommended next proof point

이제 다음은 둘 중 하나다.

### Option A
third real repo replication
- 같은 baseline을 세 번째 repo에도 재현

### Option B
same-repo depth extension
- multi-paragraph bounded replace 1건 검증

재현성 관점에서는 **Option A** 가 더 가치가 크다.

---

## Final Conclusion

현재 Generic Micro-Step System은:

> **최소 두 개의 실제 repo에서,
> docs-first low-risk lane에 대해 safe-create + bounded modify baseline을 재현했다.**

이건 internal experiment를 넘어선,
실제 적용 가능한 초기 execution baseline이다.
