# Polysona Applicability Assessment

## 한줄 결론

`LilMGenius/polysona` 같은 repo는 **Generic Micro-Step System 적용 대상이 맞다.**
다만 현재 baseline 기준으로는 **전체 자동 수정 엔진**이 아니라,
**정책 기반 planning + safe create + modify concretization + review-driven execution** 방식으로 접근하는 것이 현실적이다.

---

## repo 성격 해석

공개 설명 기준 `polysona`는 다음 특성을 가진다.

- persona orchestration 중심 repo
- multi-agent / multi-CLI integration 흔적 존재
- Codex / Claude Code / OpenCode 연결성 존재
- dashboard / scripts / docs / skills 성격이 혼합된 구조
- fullstack-ish product surface + tooling surface 공존 가능성 높음

즉 단일 앱 repo라기보다,
**문서 + 스크립트 + 설정 + 앱 + 에이전트 instruction 레이어가 혼합된 운영형 repo** 에 가깝다.

이런 repo는 broad 변경을 한 번에 걸면 위험하지만,
Micro-Step 기반 planning에는 잘 맞는다.

---

## 왜 적용 대상인가

현재 Generic Micro-Step System이 잘하는 일:

1. broad 요구사항 해석
2. dynamic phase planning
3. mixed mode classification
4. impact-aware micro-unit planning
5. execution batch planning
6. safe create real apply
7. modify concretization (초기 단계)

`polysona` 같은 repo는 broad goal이 자주 나온다.
예:
- 문서 체계 정리
- onboarding 개선
- scripts inventory 정리
- dashboard 진입 가이드 개선
- workflow/skill 구조 정리

이런 목표는 바로 대수술보다,
**작은 unit으로 쪼개고 위험한 변경을 hold하는 방식**이 적합하다.

---

## 지금 baseline으로 가능한 범위

### A. 매우 적합

#### 1. discovery / audit
- repo tree 구조 파악
- docs inventory
- workflows inventory
- scripts inventory
- dependency surface 요약
- stale/generated/obsolescence 힌트 수집

#### 2. planning
- 목표 해석
- create / modify / delete / refactor / prune 분류
- phase 선택
- unit 분해
- 위험도 annotation
- execution batches 생성

#### 3. safe create real apply
- 새 status 문서
- 새 summary 문서
- 새 contributor guide 초안
- 새 architecture note
- 새 onboarding doc
- 새 audit report

#### 4. modify concretization
- broad modify 요청을 concrete file shortlist로 축소
- docs/workflows/scripts 중심 review queue 생성

---

## 조건부 가능한 범위

### B. 조심해서 가능

#### 1. 문서 modify
가능 조건:
- single file
- exact replace 또는 명확한 section replace
- broad rewrite 아님

예:
- README 특정 섹션 보강
- command reference 업데이트
- 설치 가이드 일부 수정

#### 2. low-risk config tweak
가능 조건:
- single file
- exact replace 가능
- 영향 범위 명확

예:
- package script 한 줄 조정
- 문서 링크 수정
- 작은 workflow metadata 수정

이 영역은 `modify-safe v1` 이후에 열릴 수 있다.

---

## 아직 이른 범위

### C. 현재 baseline 밖

#### 1. repo-wide refactor
- multi-file rename
- skill 구조 재배치
- plugin system 재조정
- dashboard/CLI 동시 개편

#### 2. destructive cleanup
- 대량 delete/prune
- instruction layer 제거/이동
- old prompt asset 정리

#### 3. orchestration logic rewrite
- persona pipeline 재설계
- exporter/injector 흐름 재구성
- cross-tool compatibility 구조 변경

이건 현재 baseline에선 자동 apply보다 plan+review가 맞다.

---

## polysona에서 특히 위험한 영역

다음 영역은 hold 기본값이 적절하다.

1. `AGENTS.md`, `CLAUDE.md` 류 instruction 파일
2. `.agents/skills` 또는 skill mirror 구조
3. plugin marketplace / integration 설정
4. multi-agent orchestration scripts
5. dashboard + backend + CLI 동시 수정

이유:
- 사용자-facing 동작과 agent-facing 동작이 동시에 바뀔 수 있음
- 작은 수정이 세션 동작, agent discovery, plugin loading에 영향을 줄 수 있음
- broad refactor가 숨은 coupling을 깨기 쉬움

---

## 추천 적용 시나리오

### 시나리오 1. repo onboarding 강화
목표:
- 신규 기여자가 repo 구조를 이해하기 쉽게 만들기

적용 방식:
- discovery
- docs gap analysis
- safe create로 onboarding docs / architecture summary 생성
- 기존 README modify는 후보화만 하고 review

### 시나리오 2. workflow / script inventory 정리
목표:
- 어떤 스크립트와 workflow가 있는지 명확히 보기

적용 방식:
- discovery artifacts 생성
- stale candidate 보고서 생성
- 삭제는 hold
- 새 inventory docs는 safe create로 실제 생성 가능

### 시나리오 3. docs modernization
목표:
- outdated docs 식별 및 보완

적용 방식:
- docs 패턴 unit 생성
- concretizer로 concrete markdown file shortlist 도출
- exact-replace 가능한 문서만 modify-safe review queue로 전환

---

## 현재 구조로 적용 시 권장 파이프라인

### Phase 1. Discovery
- tree
- docs inventory
- workflows inventory
- scripts inventory

### Phase 2. Change Engine
- goal interpretation
- phase plan
- micro-units
- execution batches

### Phase 3. Concretization
- broad modify unit → concrete file shortlist

### Phase 4. Safe Execution
- safe create는 실제 적용 가능
- modify는 exact-replace candidate만 review or later apply
- destructive change는 hold

---

## 적용 가능성 최종 판정

### 결론
`polysona` 같은 repo는 **적용 가능**하다.

단, 적용 방식은 아래여야 한다.

- broad repo rewrite 금지
- discovery 우선
- micro-step planning 우선
- modify는 concretization 후 review 기반
- safe create만 즉시 실제 적용
- destructive / orchestration-core 변경은 hold

즉 현재 baseline에서의 적합도는:

- **planning / audit / doc generation / structure understanding:** 높음
- **broad refactor / multi-file orchestration rewrite:** 낮음

---

## 추천 다음 액션

`polysona` 같은 실제 repo 대상으로 다음 두 흐름 중 하나를 수행할 수 있다.

1. **applicability dry-run**
   - 실제 repo를 clone/read-only로 분석
   - 어떤 units가 나올지 시뮬레이션

2. **scoped pilot**
   - onboarding/docs audit 같은 low-risk 목표 하나 선정
   - change-engine → concretizer → safe create 중심으로 실행

현재 기준으로는 **2보다 1이 먼저**가 더 안전하다.
