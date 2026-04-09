# Modify Concretizer v3.1 Fix Note

## 문제

v3는 discovery materialization에는 성공했지만,
apply-ready lane에 modify 외 unit 의미가 섞이고,
`artifacts/docs` 같은 abstract target이 허용되었다.

## root cause

1. `extract_modify_pattern_units`의 lane 분리가 충분히 엄격하지 않았다.
2. `derive_apply_ready_candidates`가 concrete existing file path 검증을 강하게 하지 않았다.
3. directory-like / abstract alias target이 apply-ready로 새어 들어왔다.

## v3.1 수정 원칙

- apply-ready lane은 `mode=modify`만 허용
- create/audit/refactor/restructure/delete/prune/migrate 절대 금지
- concrete existing file path만 허용
- directory path 금지
- wildcard/glob/alias target 금지
- review-ready lane은 유지
