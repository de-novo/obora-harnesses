# PR Review Harness

Obora-based harness for automated PR review and feedback generation.

## Overview

This harness evaluates Obora's ability to:
1. Fetch a PR's diff and context from GitHub
2. Analyze code changes for issues, improvements, and risks
3. Generate structured review comments
4. Validate the review quality

## Directory Structure

```
harnesses/pr-review/
├── docs/                   # Methodology and policy docs
├── scripts/                # Execution and validation scripts
│   ├── run_pr_review.sh    # Main execution script
│   └── validate_review.py  # Review quality validator
└── workflows/              # Obora workflow YAML files
    └── pr-review.yaml      # PR review workflow
```

## Prerequisites

- Obora CLI installed (`obora` in PATH or `OBORA_BIN` set)
- `GITHUB_TOKEN` environment variable for GitHub API access
- Python 3 for validation scripts

## Quick Start

```bash
# Review a specific PR
cd harnesses/pr-review
./scripts/run_pr_review.sh https://github.com/owner/repo/pull/123

# Or with local obora build
OBORA_BIN="node /path/to/obora-kit/packages/cli/dist/index.js" \
  ./scripts/run_pr_review.sh https://github.com/owner/repo/pull/123
```

## Workflow

The `pr-review.yaml` workflow defines:
1. **fetch_context**: Fetch PR diff and metadata
2. **analyze_changes**: Analyze code changes for issues
3. **generate_review**: Generate structured review comments
4. **validate_review**: Validate review completeness and quality

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `OBORA_BIN` | `obora` | Obora CLI binary path |
| `GITHUB_TOKEN` | — | GitHub API token |
| `REVIEW_OUTPUT_DIR` | `./artifacts` | Review output directory |

## Result Classification

| Status | Bucket | Description |
|--------|--------|-------------|
| `PASS` | PASS | Review generated and validated |
| `FAIL_RUNTIME` | RUNTIME_FAIL | Obora CLI execution failed |
| `FAIL_QUALITY` | QUALITY_FAIL | Review failed validation |
| `FAIL_FETCH` | INFRA_FAIL | GitHub API failure |

## Status

🚧 **Skeleton** — Workflow and scripts are placeholders. Needs:
- [ ] `pr-review.yaml` workflow implementation
- [ ] `run_pr_review.sh` script implementation
- [ ] `validate_review.py` validator implementation
- [ ] End-to-end test with real PR
