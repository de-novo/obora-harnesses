# Long-Running Apps Harness

Obora-based harness for generating and validating long-running applications through iterative microstep workflows.

## Overview

This harness evaluates Obora's ability to:
1. Generate applications from scratch (CLI, API, web, fullstack)
2. Upgrade existing applications with new features
3. Repair failing implementations through validation-repair loops
4. Execute complex multi-phase changes safely

## Directory Structure

```
harnesses/long-running-apps/
├── configs/                # Obora config.yaml files
│   └── obora/
├── docs/                   # Experiment documentation
│   └── todo-cli-experiment.md
├── scripts/                # Execution and validation scripts
│   ├── smoke_todo_cli.py           # Smoke test
│   ├── run_todo_cli_fresh.sh       # Fresh generation
│   ├── run_todo_react_upgrade.sh   # Upgrade workflow
│   └── run_sdk_8002_*.sh           # SDK-8002 reproduction scripts
└── workflows/              # Obora workflow YAML files
    ├── generic-microstep-*.yaml    # Generic microstep system workflows
    ├── todo-*.yaml                 # Todo app specific workflows
    └── sdk-8002-*.yaml             # SDK-8002 reproduction workflows
```

## Workflow Categories

### 1. Generic Microstep System (14 workflows)

Core building blocks for safe, incremental changes:

| Workflow | Purpose |
|----------|---------|
| `generic-microstep-builder.yaml` | Build execution plan from goal |
| `generic-microstep-change-engine.yaml` | Generate change batches |
| `generic-microstep-applier.yaml` | Apply changes safely |
| `generic-microstep-executor.yaml` | Execute validated batches |
| `generic-microstep-modify-concretizer.yaml` | Convert modifications to concrete edits |

These workflows form a pipeline:
```
builder → change-engine → applier → executor
```

### 2. Todo App Workflows (10 workflows)

Application-specific workflows:

| Workflow | Purpose |
|----------|---------|
| `todo-cli-minimal.yaml` | Minimal Todo CLI generation |
| `todo-cli-enhanced.yaml` | Enhanced Todo CLI with filters |
| `todo-api-enhanced.yaml` | Todo REST API generation |
| `todo-monorepo-enhanced.yaml` | Fullstack monorepo generation |
| `todo-react-upgrade*.yaml` | React frontend upgrade phases |

### 3. SDK-8002 Reproduction (16 workflows)

Stress tests and regression reproductions for SDK-8002 (execution cancellation):

| Workflow | Purpose |
|----------|---------|
| `sdk-8002-repro-*.yaml` | Various reproduction scenarios |
| `sdk-8002-bisect-*.yaml` | Bisection experiments |
| `sdk-8002-styles-*.yaml` | Styles-focused stress tests |

## Prerequisites

- Obora CLI installed (`obora` in PATH)
- `ZAI_API_KEY` environment variable (or `~/.obora/auth.json`)
- Python 3 for validation scripts

## Quick Start

```bash
# Smoke test (minimal validation)
cd harnesses/long-running-apps
python3 scripts/smoke_todo_cli.py

# Fresh Todo CLI generation
./scripts/run_todo_cli_fresh.sh

# React upgrade with phases
./scripts/run_todo_react_upgrade_phases.sh
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `OBORA_BIN` | `obora` | Obora CLI binary path |
| `OBORA_CONFIG` | `configs/obora/config.yaml` | Obora config file |

## Known Limitations

### ⚠️ Provider/Model Hardcoding

**All workflows currently hardcode:**
```yaml
provider: zai
model: glm-4.7
```

This limits the harness to ZAI provider only. To use a different provider or model, you must edit the workflow YAML files.

**Recommended improvement**: Support environment variable override:
```yaml
provider: ${OBORA_PROVIDER:-zai}
model: ${OBORA_MODEL:-glm-4.7}
```

### Workflow Reusability

| Aspect | Status | Notes |
|--------|--------|-------|
| Input/output contracts | ✅ Defined | `artifacts/*.json` schema |
| Agent roles | ✅ Consistent | planner/contractor/evaluator |
| Sandbox isolation | ✅ Enabled | `sandbox.enabled: true` |
| Provider abstraction | ❌ Missing | Hardcoded to zai |
| Model selection | ❌ Missing | Hardcoded to glm-4.7 |

## Validation

Scripts in `scripts/` perform:
- **Smoke tests**: Quick validation of generated artifacts
- **Materialization**: Copy artifacts to `generated/` directory
- **Comparison**: Compare variants (e.g., `compare_todo_cli_variants.py`)

## Generated Artifacts

Successful runs produce artifacts in:
- `generated/cli/validated/` — Validated CLI applications
- `generated/api/validated/` — Validated API applications
- `generated/web/validated/` — Validated web applications
- `generated/fullstack/validated/` — Validated fullstack applications
- `generated/server/validated/` — Validated server applications

## Experiment History

| Experiment | Date | Result |
|------------|------|--------|
| Todo CLI v1 | 2026-03-31 | ✅ Working CLI generated |
| Todo React upgrade | 2026-04-01 | ✅ Multi-phase upgrade successful |
| SDK-8002 repro | 2026-04-02 | ⚠️ Intermittent cancellation |
