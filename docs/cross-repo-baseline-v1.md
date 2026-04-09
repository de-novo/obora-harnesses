# Cross-Repo Baseline v1

## 한줄 결론

Generic Micro-Step System의 **docs-first low-risk execution baseline** 은 이제 최소 세 개의 실제 repo에서 재현되었다.

검증 대상:
- `polysona`
- `obora-todoapp`
- `plant-companion`

즉 이 baseline은 더 이상 단일 사례가 아니라,
**cross-repo로 재현 가능한 execution pattern** 으로 볼 수 있다.

---

## Baseline v1 정의

현재 Baseline v1은 아래 조건을 만족하는 보수적 실행 범위를 뜻한다.

### Safe lane
- safe-create support docs
- single-line exact replace
- single-sentence exact replace
- small contiguous section-local block replace
- paragraph-bounded replace
- post-change re-read verification

### Hold lane
- instruction files
- workflow/runtime core
- hooks/scripts with execution impact
- app/server/device/packages code
- multi-file or higher-risk changes

즉 Baseline v1은 “모든 걸 자동 수정”하는 단계가 아니라,
**risk를 분리하고 low-risk 문서층부터 실제 적용하는 단계** 다.

---

## Repo Proofs

## 1. polysona

### repo type
mixed-surface repo
- docs
- skills
- personas
- hooks
- client/server
- instruction layer

### proven
- safe-create support docs
- exact-replace on skill docs and README files
- small block replace in README
- paragraph-bounded replace in README

### meaning
mixed-surface repo에서도 docs-first lane 분리와 bounded modify가 가능함을 증명.

---

## 2. obora-todoapp

### repo type
workflow/docs-heavy repo
- README
- approved docs
- workflow runtime layer
- script entrypoint

### proven
- safe-create support doc
- exact-replace in README
- small block replace in README
- paragraph-bounded replace in README

### meaning
workflow-heavy repo에서도 same proof sequence가 재현됨을 증명.

---

## 3. plant-companion

### repo type
product/app/device/service monorepo with explicit docs lane
- README
- docs
- apps/device/services/packages
- scripts/infra

### proven
- safe-create support docs
- exact-replace in docs
- small block replace in README
- paragraph-bounded replace in README

### meaning
implementation-heavy monorepo에서도 docs-first lane을 분리해 같은 baseline을 재현 가능함을 증명.

---

## What is now proven across repos

세 repo를 통틀어 실제로 증명된 공통점:

1. docs-first scope isolation 가능
2. hold-zone separation 가능
3. safe-create support docs 생성 가능
4. exact-replace가 실제 repo에서 안정적으로 적용 가능
5. small contiguous block replace 가능
6. paragraph-bounded replace 가능
7. post-change re-read verification 가능

---

## What is NOT yet baseline v1

다음은 아직 Baseline v1 범위 밖이다.

- multi-paragraph replace
- section-level semantic rewrite
- persona/data-sensitive apply
- workflow/config/runtime modify
- code/runtime modify
- multi-file batching
- rollback-aware modify execution

즉 현재 일반화 범위는 여전히 **documentation-first low-risk lane** 까지다.

---

## Why this matters

이 결과는 세 가지 의미가 있다.

### 1. one-off 아님
세 repo에서 재현되었으므로 특정 저장소 우연 성공으로 보기 어렵다.

### 2. entry strategy가 검증됨
실제 repo에 들어갈 때 docs-first low-risk lane으로 시작하는 전략이 현실적이다.

### 3. modify gradient가 검증됨
modify는 아래 순서로 점진 확장하는 것이 맞다.
- exact replace
- block replace
- paragraph replace

이 gradient가 세 repo에서 모두 유지되었다.

---

## Recommended next move

다음 단계는 두 갈래다.

### Breadth
- fourth real repo replication

### Depth
- multi-paragraph bounded replace in docs-first lane

현재 Baseline v1을 고정한다면,
다음 단계는 **Baseline v1.1 = multi-paragraph bounded replace** 검증이 자연스럽다.

---

## Final Statement

> Generic Micro-Step System Baseline v1 is now established as a cross-repo, docs-first, low-risk execution pattern proven on three real repositories.
