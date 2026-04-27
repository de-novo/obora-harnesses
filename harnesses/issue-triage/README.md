# Issue Triage Harness

Obora-based harness for automated issue classification and label suggestion.

## Overview

This harness evaluates Obora's ability to:
1. Fetch an issue's content and metadata from GitHub
2. Classify the issue (bug, feature, question, etc.)
3. Suggest appropriate labels and assignees
4. Validate the classification quality

## Directory Structure

```
harnesses/issue-triage/
├── docs/                   # Methodology and policy docs
├── scripts/                # Execution and validation scripts
│   ├── run_triage.sh       # Main execution script
│   └── validate_triage.py  # Triage quality validator
└── workflows/              # Obora workflow YAML files
    └── issue-triage.yaml   # Issue triage workflow
```

## Prerequisites

- Obora CLI installed (`obora` in PATH or `OBORA_BIN` set)
- `GITHUB_TOKEN` environment variable for GitHub API access
- Python 3 for validation scripts

## Quick Start

```bash
# Triage a specific issue
cd harnesses/issue-triage
./scripts/run_triage.sh https://github.com/owner/repo/issues/456

# Or with local obora build
OBORA_BIN="node /path/to/obora-kit/packages/cli/dist/index.js" \
  ./scripts/run_triage.sh https://github.com/owner/repo/issues/456
```

## Workflow

The `issue-triage.yaml` workflow defines:
1. **fetch_issue**: Fetch issue content and metadata
2. **classify**: Classify issue type and severity
3. **suggest_labels**: Suggest appropriate labels
4. **validate_triage**: Validate classification accuracy

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `OBORA_BIN` | `obora` | Obora CLI binary path |
| `GITHUB_TOKEN` | — | GitHub API token |
| `TRIAGE_OUTPUT_DIR` | `./artifacts` | Triage output directory |

## Result Classification

| Status | Bucket | Description |
|--------|--------|-------------|
| `PASS` | PASS | Triage generated and validated |
| `FAIL_RUNTIME` | RUNTIME_FAIL | Obora CLI execution failed |
| `FAIL_QUALITY` | QUALITY_FAIL | Triage failed validation |
| `FAIL_FETCH` | INFRA_FAIL | GitHub API failure |

## Status

🚧 **Skeleton** — Workflow and scripts are placeholders. Needs:
- [ ] `issue-triage.yaml` workflow implementation
- [ ] `run_triage.sh` script implementation
- [ ] `validate_triage.py` validator implementation
- [ ] End-to-end test with real issue
