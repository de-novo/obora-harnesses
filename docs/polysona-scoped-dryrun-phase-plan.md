# Polysona Scoped Dry-Run Phase Plan

## 한줄 결론

첫 `polysona` dry-run은 **문서 일관성 및 설명력 개선** 범위로 제한하는 것이 적절하다.
코드/훅/인스트럭션 레이어는 hold하고, README/skills/personas 중심으로 phase를 구성한다.

---

## Scoped Goal

README / README.ko / selected skill docs / selected persona docs의 설명 일관성과 가독성을 점검하고,
low-risk modify review queue와 safe-create 보조 문서 후보를 도출한다.

---

## Phase 1. Discovery

목적:
- 문서 파일 범위 확정
- hold zone 분리
- 수정 가능한 문서 축 식별

입력 대상:
- `README.md`
- `README.ko.md`
- `skills/*/SKILL.md`
- `personas/default/*.md`

산출물:
- markdown inventory
- doc grouping (root docs / skill docs / persona docs)
- hold-zone list

---

## Phase 2. Interpretation

목적:
- broad 요구를 실제 작업 유형으로 해석

예상 분류:
- `modify`: README wording / terminology consistency
- `modify`: selected SKILL.md clarity improvements
- `modify`: persona doc explanation clarity review
- `create`: consistency report / structure summary
- `hold`: AGENTS / CLAUDE / hooks / client / server

---

## Phase 3. Micro-Unit Derivation

목적:
- broad 문서 개선 요청을 single-file review 단위로 축소

예상 unit 예시:
- `README.md` quick start wording review
- `README.ko.md` terminology alignment review
- `skills/content/SKILL.md` persistence contract wording review
- `skills/interview/SKILL.md` resume-first protocol clarity review
- `personas/default/persona.md` table/section interpretation note review

---

## Phase 4. Execution Posture

### review-ready modify
- `README.md`
- `README.ko.md`
- `skills/content/SKILL.md`
- `skills/interview/SKILL.md`
- `personas/default/persona.md`

### safe-create
- `docs/polysona-doc-consistency-report.md`
- `docs/polysona-structure-summary.md`

### hold
- `AGENTS.md`
- `CLAUDE.md`
- `hooks/*.sh`
- `client/src/**`
- `server/**`

---

## Success Criteria

이 dry-run이 성공으로 간주되려면:
1. review-ready single-file 문서 후보가 나온다
2. hold zone이 자동으로 분리된다
3. safe-create 보조 문서 후보가 나온다
4. broad repo rewrite 없이도 유의미한 execution posture를 만들 수 있다
