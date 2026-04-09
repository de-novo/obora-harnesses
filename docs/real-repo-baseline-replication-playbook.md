# Real Repo Baseline Replication Playbook

## 한줄 결론

`polysona`에서 검증한 baseline을 다른 실제 repo에도 재현하려면,
처음부터 broad rewrite를 시도하지 말고 **docs-first low-risk lane**으로 들어가야 한다.

---

## Goal

이 playbook의 목적은 다음을 표준화하는 것이다.

1. 어떤 실제 repo를 다음 검증 대상으로 고를지
2. 처음 어떤 범위로 들어갈지
3. 무엇을 hold해야 하는지
4. 어떤 proof point 순서로 검증할지

---

## Entry Rule

새 실제 repo에 들어갈 때는 아래 순서를 강제한다.

1. repo discovery
2. low-risk docs lane 식별
3. hold-zone 분리
4. safe-create support docs 생성
5. exact-replace 후보 선정
6. single-line exact replace
7. small block replace
8. paragraph-bounded replace

즉 `polysona`에서 했던 순서를 재현한다.

---

## Candidate Repo Selection Criteria

다음 조건을 만족하는 repo가 좋다.

### preferred
- README / docs / guides 가 존재
- concrete markdown files 가 여러 개 존재
- scripts/hooks/config 가 일부 있지만 전부가 코드 repo는 아님
- instruction/runtime 영역과 docs 영역이 구분 가능
- single-file low-risk modify 후보가 명확함

### avoid as next target
- docs가 거의 없는 pure code repo
- generated files 비중이 너무 큰 repo
- instruction/runtime layer만 있는 repo
- tiny repo라 modify gradient를 검증하기 어려운 repo

---

## Baseline Proof Sequence

### Proof 1
safe-create support docs

### Proof 2
single-line exact replace

### Proof 3
single-sentence exact replace

### Proof 4
small contiguous section-local block replace

### Proof 5
paragraph-bounded replace

이 다섯 단계가 현재 baseline core proof다.

---

## Hold-Zone Heuristic

새 repo에서도 초기에는 아래를 기본 hold로 둔다.

- instruction files (`AGENTS.md`, `CLAUDE.md` 등)
- runtime hooks
- app code (`src/**`, `server/**`)
- complex config / CI / deployment files
- multi-file restructure candidates

---

## Safe Lane Heuristic

처음엔 아래부터 시작한다.

- `README*.md`
- `docs/**/*.md`
- `guides/**/*.md`
- `skills/*/SKILL.md` 류 protocol docs
- contributor/onboarding notes

---

## Exit Criteria

다음 repo에서 아래가 충족되면 baseline 재현 성공으로 본다.

1. safe-create 1건 이상
2. exact-replace 1건 이상
3. block replace 1건 이상 또는 paragraph replace 1건 이상
4. hold-zone 분리가 유지됨
5. post-change re-read verification 완료

---

## Meaning

이 playbook은 baseline을 넓히기 위한 것이 아니라,
**실제 repo에서도 같은 안전 경계가 재현되는지 검증**하기 위한 것이다.
