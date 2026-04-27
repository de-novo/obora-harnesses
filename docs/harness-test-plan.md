# Obora Harnesses Test Plan

> Status: Draft (2026-04-27)
> Scope: obora-harnesses repository

## 1. Overview

This plan defines a phased approach to validate and mature the harness infrastructure for Obora-based benchmarks and evaluations.

### Current State

| Category | Status | Coverage |
|----------|--------|----------|
| swe-bench | Active | Results exist, scripts operational |
| long-running-apps | Active | Todo CLI experiments, SDK-8002 repros |
| pr-review | Skeleton | Docs/scripts/workflows minimal |
| issue-triage | Skeleton | Docs/scripts/workflows minimal |
| shared | Partial | Validators, reporters, schemas exist |

### Goal

Move all harness categories from their current state to **validated, reproducible, documented** state.

---

## 2. Phase 1: Foundation (Week 1)

### 2.1 swe-bench Harness Hardening

**Objective**: Ensure the swe-bench harness is reproducible and documented.

**Tasks**:
- [ ] Document the exact execution flow: `workflow → script → validation → report`
- [ ] Verify `results-repair/` structure is consistent (all entries have: patch.diff, final-validation.json, status.txt)
- [ ] Validate that `shared/validators/` can be invoked independently
- [ ] Create a single-command smoke test: `make test-swe-bench-smoke` or equivalent
- [ ] Check for stale paths/hardcoded values in scripts

**Deliverables**:
- `harnesses/swe-bench/README.md` — execution guide
- `harnesses/swe-bench/Makefile` — smoke test target
- Consistent results directory structure

### 2.2 shared/ Infrastructure Audit

**Objective**: Ensure shared components are reusable across all harnesses.

**Tasks**:
- [ ] Inventory: `shared/validators/`, `shared/reporters/`, `shared/runtime/`, `shared/scripts/`
- [ ] Check each validator for hardcoded paths or assumptions
- [ ] Verify reporters output the 4 evaluation buckets: PASS, RUNTIME_FAIL, QUALITY_FAIL, INFRA_FAIL
- [ ] Document the interface contract for validators/reporters

**Deliverables**:
- `shared/README.md` — component catalog and interface contracts

---

## 3. Phase 2: Expansion (Week 2)

### 3.1 long-running-apps Harness Validation

**Objective**: Validate that long-running app generation is reproducible.

**Tasks**:
- [ ] Select 1 representative workflow (e.g., `generic-microstep-applier.yaml`)
- [ ] Document prerequisites: Obora CLI version, config.yaml requirements
- [ ] Execute the workflow end-to-end and record: execution time, success/failure, artifacts produced
- [ ] Verify generated artifacts land in correct `generated/{api,cli,fullstack,server,web}/` subdirectory
- [ ] Validate artifact with `shared/validators/`

**Deliverables**:
- `harnesses/long-running-apps/README.md` — execution guide
- 1 validated execution trace (log + artifacts)

### 3.2 pr-review Harness Bootstrap

**Objective**: Move from skeleton to functional harness.

**Tasks**:
- [ ] Define the workflow: PR URL → checkout → analysis → comment generation → validation
- [ ] Create initial workflow YAML in `harnesses/pr-review/workflows/`
- [ ] Create validation script in `harnesses/pr-review/scripts/`
- [ ] Test with 1 real PR (or mock PR fixture)

**Deliverables**:
- `harnesses/pr-review/README.md`
- 1 working workflow YAML
- 1 validation script

### 3.3 issue-triage Harness Bootstrap

**Objective**: Move from skeleton to functional harness.

**Tasks**:
- [ ] Define the workflow: Issue URL → fetch → classification → label suggestion → validation
- [ ] Create initial workflow YAML in `harnesses/issue-triage/workflows/`
- [ ] Create validation script in `harnesses/issue-triage/scripts/`
- [ ] Test with 1 real issue (or mock issue fixture)

**Deliverables**:
- `harnesses/issue-triage/README.md`
- 1 working workflow YAML
- 1 validation script

---

## 4. Phase 3: Integration (Week 3)

### 4.1 Cross-Harness Validation

**Objective**: Ensure shared components work uniformly across all harnesses.

**Tasks**:
- [ ] Run all 4 harnesses with the same Obora CLI version
- [ ] Verify all use `shared/validators/` and `shared/reporters/` consistently
- [ ] Check that evaluation output format is uniform (JSON schema)

**Deliverables**:
- Cross-harness validation report
- Uniform JSON output schema definition

### 4.2 CI/CD Integration

**Objective**: Automate harness execution.

**Tasks**:
- [ ] Create `.github/workflows/harness-smoke.yml` — runs all harness smoke tests on push
- [ ] Create `.github/workflows/harness-swe-bench.yml` — scheduled swe-bench run (weekly)
- [ ] Document CI setup requirements (GitHub tokens, Obora config)

**Deliverables**:
- `.github/workflows/` directory with 2 workflow files
- CI setup documentation

---

## 5. Phase 4: Advanced (Week 4+)

### 5.1 Comparative Benchmarking

**Objective**: Run comparative evaluations (Obora vs baseline).

**Tasks**:
- [ ] Define comparison protocol: same tasks, same time limits, same validation criteria
- [ ] Populate `comparisons/` with structured result summaries
- [ ] Generate automated comparison reports

**Deliverables**:
- `comparisons/README.md` — comparison methodology
- 1 comparison report (e.g., Obora vs human on swe-bench subset)

### 5.2 Regression Detection

**Objective**: Detect performance regressions across Obora versions.

**Tasks**:
- [ ] Store baseline results in `harnesses/*/baselines/`
- [ ] Create regression detection script: compare current vs baseline
- [ ] Alert on significant degradation (PASS rate drop > threshold)

**Deliverables**:
- `shared/scripts/regression-check.py`
- Regression detection documentation

---

## 6. Success Criteria

| Phase | Criterion |
|-------|-----------|
| 1 | `make test` passes for swe-bench smoke test |
| 2 | All 4 harnesses have README + working workflow |
| 3 | All harnesses produce uniform JSON evaluation output |
| 4 | CI runs weekly, regression alerts functional |

---

## 7. Immediate Next Actions

1. **swe-bench README 작성** — 현재 결과 구조와 실행 방법 문서화
2. **shared/validators/ 인터페이스 문서화** — 어떤 입력을 받고 어떤 출력을 내는지
3. **pr-review/issue-triage skeleton 채우기** — 최소한의 workflow YAML 생성

어떤 단계부터 시작할까요?
