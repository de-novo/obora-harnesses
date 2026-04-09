# Polysona Dry-Run — Simulated Units

## 한줄 결론

`polysona`를 대상으로 한 low-risk 문서 dry-run에서는,
현재 Generic Micro-Step System이 다음과 같은 unit 구성을 만드는 것이 자연스럽다.

---

## Simulated broad goal

> README / README.ko / skill docs / persona docs의 설명 일관성을 점검하고,
> low-risk 문서 보강 후보를 정리한다.

---

## 예상 phase

### Phase 1. discovery
- README 구조 파악
- skill docs inventory
- persona docs inventory
- hold zone 식별

### Phase 2. interpretation
- 문서 중심 개선 과제로 분류
- modify + create 혼합으로 판단

### Phase 3. unit derivation
- concrete 문서 파일 단위 후보 생성
- instruction/core runtime 영역 hold

### Phase 4. review queue
- modify-safe review queue
- safe create candidate 제안

---

## Simulated micro-units

### modify review candidates
1. `README.md`
   - quick start / dashboard / roadmap wording consistency review
2. `README.ko.md`
   - 영문 README와 구조/용어 일관성 점검
3. `skills/content/SKILL.md`
   - skill description phrasing review
4. `skills/interview/SKILL.md`
   - references/usage wording review
5. `personas/default/persona.md`
   - persona schema explanation clarity review
6. `personas/default/nuance.md`
   - nuance description consistency review

### safe create candidates
1. `docs/polysona-doc-consistency-report.md`
   - README / skill docs / persona docs 비교 요약
2. `docs/polysona-structure-summary.md`
   - repo 구조와 역할 요약

### hold candidates
1. `AGENTS.md`
2. `CLAUDE.md`
3. `client/src/**`
4. `server/**`
5. `hooks/*.sh`

---

## 예상 execution posture

- README / skills / personas: **review-ready modify**
- consistency report / structure summary: **safe create**
- instruction/core runtime layers: **hold**

---

## 의미

이 dry-run은 `polysona` 같은 실제 repo에 대해,
현재 시스템이 최소한 아래를 할 수 있는지 확인하는 좋은 시험이 된다.

- 문서 중심 low-risk scope 설정
- modify concretization
- hold zone 분리
- safe create 보조 문서 제안
