# Polysona Scoped Dry-Run Review Queue

## Review-Ready Modify Candidates

### 1. `README.md`
- Focus: quick start 설명 밀도, dashboard 설명 구조, roadmap 표현 정리
- Reason: root onboarding 문서이며 single-file bounded review 가능
- Risk: low
- Posture: review-ready modify

### 2. `README.ko.md`
- Focus: 영어 README와 용어/구조 정합성, 한국어 표현 통일
- Reason: 번역/로컬라이징 일관성 검토 가치 높음
- Risk: low
- Posture: review-ready modify

### 3. `skills/content/SKILL.md`
- Focus: draft persistence contract wording clarity
- Reason: single-file 규칙 문서이며 동작 설명의 정확성 점검 가능
- Risk: low-medium
- Posture: review-ready modify

### 4. `skills/interview/SKILL.md`
- Focus: resume-first protocol, interview-log append semantics 설명 선명화
- Reason: protocol 문서로서 bounded review 가능
- Risk: low-medium
- Posture: review-ready modify

### 5. `personas/default/persona.md`
- Focus: persona schema readability, section interpretation note 필요성 점검
- Reason: 실제 persona data 구조 이해에 중요
- Risk: low
- Posture: review-ready modify

### 6. `personas/default/nuance.md`
- Focus: persona 보조 설명 문맥 정합성 점검
- Reason: persona bundle consistency 검토 대상
- Risk: low
- Posture: review-ready modify

---

## Safe-Create Candidates

### 1. `docs/polysona-doc-consistency-report.md`
- Purpose: README / skills / personas 간 용어와 구조 차이 요약
- Posture: safe-create

### 2. `docs/polysona-structure-summary.md`
- Purpose: repo 구조와 각 레이어 역할 요약
- Posture: safe-create

---

## Hold Queue

- `AGENTS.md`
- `CLAUDE.md`
- `hooks/*.sh`
- `client/src/**`
- `server/**`

Reason:
- runtime / behavior / instruction 영향이 커서 현재 baseline의 자동 modify 범위를 넘음
