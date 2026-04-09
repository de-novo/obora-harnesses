# Polysona Low-Risk Dry-Run Goal

## Goal

`polysona` 실제 repo에 대해,
**README / README.ko / skill docs 계열의 문서 일관성 개선 가능성**을 검증하는 low-risk dry-run을 수행한다.

---

## 왜 이 goal인가

현재 baseline에서 가장 안전하고 검증 가치가 높은 영역은 다음이다.

- `README.md`
- `README.ko.md`
- `skills/*/SKILL.md`
- `personas/default/*.md`

이유:
1. single-file modify 후보로 좁히기 좋다
2. exact-replace readiness 평가에 적합하다
3. destructive risk가 낮다
4. 실제 repo 문서 품질 개선과 직접 연결된다

---

## dry-run 질문

이 dry-run은 아래를 본다.

1. broad goal을 micro-units로 쪼갤 수 있는가
2. 문서 계열 modify를 concrete review queue로 내릴 수 있는가
3. safe create가 필요한 보조 문서를 제안할 수 있는가
4. instruction/core runtime 영역을 자동으로 hold할 수 있는가

---

## hold zones

다음은 이번 dry-run에서 기본 hold다.
- `AGENTS.md`
- `CLAUDE.md`
- `client/src/**`
- `server/**`
- `hooks/*.sh`

---

## expected output

- scoped phase plan
- micro-unit candidates for README / skills / personas docs
- modify review queue
- optional safe-create artifacts (e.g. docs consistency report)
