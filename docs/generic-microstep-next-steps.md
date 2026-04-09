# Generic Micro-Step System — Next Steps

## Immediate Next Step

### modify-safe v1
가장 자연스러운 다음 단계는 `modify-safe v1` 이다.

이 단계의 목표:
- 기존 파일 overwrite 전체 금지 유지
- exact replace 또는 section-level safe patch만 허용
- destructive mode는 계속 hold

---

## Why modify-safe v1 next?

이유:
1. create-only baseline은 확보됨
2. 실제 프로젝트 개선은 modify가 핵심임
3. delete/prune보다 위험이 낮음
4. refactor/restructure보다 범위가 작음

---

## Scope of modify-safe v1

허용:
- exact text replacement
- clearly bounded section replacement
- single file only
- no rename/move/delete

금지:
- broad rewrite
- multiple files per unit
- implicit overwrite of unrelated sections
- destructive action

---

## After modify-safe v1

1. modify-safe v1
2. prune-safe planning hardening
3. refactor/restructure apply support
4. rollback-aware execution
