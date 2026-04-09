# Polysona Dry-Run Observations — 2026-04-04

## 한줄 결론

`polysona`는 artifact-only 테스트 공간보다 훨씬 좋은 실제 검증 대상이다.
현재 Generic Micro-Step System의 다음 단계(특히 modify concretization, review queue, safe create applicability)를 시험하기에 적합하다.

---

## 실제 확인된 구조

루트 핵심 파일:
- `AGENTS.md`
- `CLAUDE.md`
- `README.md`
- `README.ko.md`
- `package.json`
- `vite.config.ts`
- `tsconfig.json`
- `process_svg.py`

주요 디렉토리:
- `agents/`
- `assets/`
- `client/`
- `content/`
- `decks/`
- `hooks/`
- `personas/`
- `scripts/`
- `server/`
- `skills/`

구체 파일 예시:
- `client/src/pages/*.tsx`
- `client/src/components/*.tsx`
- `server/index.ts`
- `server/routes/api.ts`
- `hooks/*.sh`
- `skills/*/SKILL.md`
- `personas/default/*.md`

---

## 왜 좋은 검증 대상인가

artifact-only 공간과 달리, 이 repo는 실제로 다음을 모두 가진다.

1. 문서 레이어
2. 앱 코드 레이어 (client/server)
3. scripts/hooks 레이어
4. instruction/agent 레이어
5. persona/content data 레이어

즉 broad goal을 받았을 때:
- create
- modify
- refactor
- prune
- docs
- scripts
- UI
- server
를 실제로 구분해 볼 수 있다.

---

## 현재 baseline과 잘 맞는 영역

### 매우 적합
- repo discovery
- docs / skills / hooks / scripts inventory
- onboarding or architecture summary 생성
- content/persona 구조 설명 문서 생성
- modify review queue 생성

### 조심해서 가능
- README 계열 단일 파일 수정
- skills 문서 단일 파일 수정
- low-risk docs wording refresh
- 일부 shell/script metadata 수정

### 기본 hold 권장
- `AGENTS.md`, `CLAUDE.md`
- `hooks/*.sh`
- `client/src/**`
- `server/**`
- multi-file skill structure changes
- plugin / marketplace config changes

---

## 실제 다음 검증 포인트

### 1. discovery 품질
이 repo에서는 discovery inventories가 실제로 유의미한 내용을 가져야 한다.
특히:
- skills inventory
- hooks inventory
- client/server tree
- docs/persona/content markdown inventory

### 2. modify concretization 품질
다음 패턴이 concrete shortlist로 잘 내려오는지 봐야 한다.
- `README*.md`
- `skills/*/SKILL.md`
- `hooks/*.sh`
- `client/src/pages/*.tsx`

### 3. lane separation 현실성
- docs wording refresh → review/apply 후보화 가능한가
- hooks/client/server → hold 또는 review로 적절히 빠지는가

---

## dry-run 추천 범위

### 1차 권장 대상
- `README.md`
- `README.ko.md`
- `skills/*/SKILL.md`
- `personas/default/*.md`

이유:
- single-file modify candidate로 좁히기 좋다
- exact-replace readiness 평가가 가능하다
- destructive 리스크가 낮다

### 2차 권장 대상
- `hooks/*.sh`
- `scripts/*.mjs`

이유:
- concrete file path는 있으나 실행 영향이 있어 보수적 review가 필요하다

### 3차 보류 대상
- `client/src/**`
- `server/**`

이유:
- 코드/동작 영향이 커서 현재 baseline의 자동 apply 범위를 넘는다

---

## 결론

`polysona`는 “되려나?” 수준이 아니라,
**현재 Generic Micro-Step System의 다음 검증 무대로 충분히 적합한 실제 repo** 다.

특히 다음을 시험하기 좋다.
- discovery quality
- modify concretization quality
- review queue usefulness
- docs-first safe execution strategy
