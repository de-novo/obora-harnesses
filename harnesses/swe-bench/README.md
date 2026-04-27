# SWE-bench Harness

Obora-based SWE-bench evaluation harness with validation-repair loop.

## Overview

This harness evaluates Obora's ability to fix real GitHub issues by:
1. Loading a SWE-bench problem instance
2. Cloning the target repository at the base commit
3. Running Obora CLI with a validation-repair workflow
4. Validating the generated patch
5. Recording structured results

## Directory Structure

```
harnesses/swe-bench/
├── baselines/              # Baseline result snapshots for regression detection
├── configs/                # Obora config.yaml files
│   └── obora/
├── docs/                   # Documentation
├── results-repair/         # Evaluation results (gitignored, created at runtime)
│   └── {instance_id}/
│       ├── status.txt              # PASS | FAIL_* | FAIL_RUNTIME
│       ├── final-validation.json   # Validation details
│       ├── patch.diff              # Generated patch (if PASS)
│       ├── edit.json               # Structured edit metadata
│       ├── obora.log               # Full CLI output
│       └── runtime-failure.json    # Runtime failure classification
├── samples/                # SWE-bench samples with answers (for validation)
├── samples-no-answer/      # SWE-bench samples without answers (for evaluation)
├── scripts/                # Execution scripts
│   ├── run_30_sequential.sh
│   ├── run_50_sequential.sh
│   ├── run_repair_experiment.sh    # Main evaluation script
│   └── structured_repair_helper.py # Validation helper
└── workflows/              # Obora workflow YAML files
    └── obora-os-workflow.yaml
```

## Prerequisites

- Obora CLI installed (`obora` in PATH)
- `ZAI_API_KEY` environment variable (or `~/.obora/auth.json` with zai provider)
- Python 3 with `jq`
- Git

## Quick Start

```bash
# Run on 5 samples (default)
cd harnesses/swe-bench
./scripts/run_repair_experiment.sh

# Run on 30 samples
./scripts/run_repair_experiment.sh 30

# Run on a specific instance
./scripts/run_repair_experiment.sh django__django-13028
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `SAMPLES_DIR` | `samples-no-answer/` | Input sample directory |
| `RESULTS_DIR` | `results-repair/` | Output results directory |
| `WORKFLOW` | `workflows/obora-os-workflow.yaml` | Obora workflow file |
| `CONFIG` | `configs/obora/config.yaml` | Obora config file |
| `OBORA_BIN` | `obora` | Obora CLI binary path |
| `OBORA_RUN_TIMEOUT_MS` | `240000` | Per-sample timeout (ms) |

## Result Classification

Results are classified into 4 buckets as per repository evaluation rules:

| Status | Bucket | Description |
|--------|--------|-------------|
| `PASS` | PASS | Patch generated and validated successfully |
| `FAIL_RUNTIME` | RUNTIME_FAIL | Obora CLI execution failed (SDK_8002, rate limit, etc.) |
| `FAIL_PATCH` | QUALITY_FAIL | Patch generated but failed validation |
| `FAIL_CLONE/FETCH/CHECKOUT` | INFRA_FAIL | Git infrastructure failure |

## Validation

The `structured_repair_helper.py` script performs:
- Target file extraction from problem statement
- Snippet generation for context
- Edit validation against the repository

## Retry Logic

The harness automatically retries on:
- **429 Rate Limit**: Exponential backoff (20s × attempt)
- **SDK_8002 Execution Cancelled**: Short retry with sleep
- **Post-validation failure**: 1 additional repair loop with feedback

## Results Summary

After execution, `results-repair/summary.txt` contains:
```
total: 30
pass: 12
fail: 18
runtime_fail: 5
quality_fail: 10
infra_fail: 3
pass_rate: 40%
```

## Baselines

Baseline results are stored in `baselines/` for regression detection. To create a new baseline:

```bash
# After a successful run
cp -r results-repair baselines/v{version}
```

## Known Issues

- SDK_8002 (execution cancelled) occurs under high step pressure; the harness mitigates with retries
- Rate limiting from ZAI provider requires `ZAI_API_KEY` with sufficient quota
