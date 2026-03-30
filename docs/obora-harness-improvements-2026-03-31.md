# Obora harness improvements summary (2026-03-31)

## Summary
이번 작업에서는 Anthropic의 long-running harness engineering 원칙을 참고해 standalone `obora-harnesses`의 SWE-bench harness를 실제로 개선하고 검증했다.

핵심 결론:
- contract layer는 Obora harness에 무리 없이 적용 가능했다.
- runtime telemetry 추가로 failure hotspot을 구조적으로 식별할 수 있게 됐다.
- deterministic final validation failure를 repair loop로 다시 연결하는 post-validation retry가 실제 patch recovery에 효과를 보였다.
- `discover_target` 단계 완화는 persistent `SDK_8002` runtime failure recovery에 효과가 있었다.

## What changed

### 1. Contract layer added
Workflow change:
- `discover_target -> repair_contract -> generate_edit -> validate_edit`

New artifact:
- `artifacts/repair_contract.json`

Schema:
- `target_file`
- `suspected_bug_locus`
- `change_intent`
- `success_criteria`
- `do_not_touch`

Effect:
- generator/validator가 target choice 이후 수정 의도와 성공 기준을 공유하게 됨
- Anthropic article의 sprint contract 개념을 최소 버전으로 이식

### 2. Runtime telemetry added
Runner change:
- `runtime-failure.json` 생성

Recorded fields:
- `sample_id`
- `repo`
- `workflow`
- `obora_bin`
- `failed_step`
- `failure_type`
- `failure_signature`
- `attempt_count`
- `retry_count`
- `run_ok`

Effect:
- `SDK_8002` failure hotspot을 `discover_target` / `generate_edit` 단계 단위로 식별 가능
- transient vs persistent runtime failure 분리 가능

### 3. Post-validation retry added
Runner change:
- deterministic final validation 실패 시 1회 additional repair loop 허용
- `final-validation.json`을 `artifacts/validation-report.json`으로 되먹임

Effect:
- validator PASS but final deterministic validation FAIL 케이스를 복구 가능
- patch quality failure 일부가 recoverable failure로 전환됨

### 4. Discover target runtime tuning
Workflow change:
- `discover_target.config.maxToolRounds: 256 -> 128`

Runner change:
- `discover_target` 단계에서 `SDK_8002` 발생 시 일반 retry보다 긴 backoff 적용

Effect:
- persistent runtime failures recovery 개선

## Validation results

### Contract smoke
- 3-sample smoke: 3/3 PASS
- 10-sample smoke: 10/10 PASS

### Baseline expansion
Standalone harness first 50 slice:
- PASS: 42
- FAIL_RUNTIME: 6
- FAIL_PATCH: 2

### Recovery validation
Representative patch failures recovered after post-validation retry:
- `django__django-12497`
- `django__django-12983`
- `django__django-13028`

Representative runtime failures recovered after discover_target tuning:
- `django__django-12589`
- `django__django-13033`

## Main takeaways
1. Anthropic-style contract agreement is directly applicable to Obora harness design.
2. Most observed failures were not hard architectural failures; they were recoverable with better harness structure.
3. The remaining problem space shifted from “Can this work?” to “How do we operationalize and scale it?”

## Recommended next steps
1. Re-run a larger clean batch with the improved harness (50 or 100 samples).
2. Compare before/after metrics:
   - pass rate
   - runtime fail rate
   - patch fail rate
   - retry count distribution
   - failed_step distribution
3. If stable, promote contract + telemetry + post-validation retry as the default harness pattern.
4. Apply the same pattern to the split workflow variant.
