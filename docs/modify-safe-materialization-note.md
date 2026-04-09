# Modify-Safe Policy Materialization Note

## 문제

외부 `docs/...` 또는 절대경로 정책 문서를 workflow step이 직접 읽게 하면,
Obora 실행 컨텍스트에서 policy 접근이 불안정할 수 있다.

## 원칙

modify-safe policy는 실행 전에 아래 경로로 materialize 한다.

- `artifacts/policies/modify-safe-v1-policy.md`

즉 workflow는 외부 문서를 직접 읽지 않고,
실행 디렉토리 내부 artifact만 읽는다.

## 기대 효과

- sandbox/materialization 일관성 개선
- fallback rule 사용 감소
- 정책 기반 필터링의 재현성 향상
