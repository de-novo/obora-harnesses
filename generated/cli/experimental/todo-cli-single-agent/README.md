# Todo CLI — Single-Agent Baseline

A small local-file-backed todo CLI used as a baseline artifact for harness comparison.

## Features
- add
- list
- done
- remove
- clear
- local JSON persistence

## Run
```bash
cd generated/cli/experimental/todo-cli-single-agent
node ./src/index.js help
node ./src/index.js add "buy milk"
node ./src/index.js list
```

## Data storage
Todos are stored in:
- `~/.todo-cli-single-agent/todos.json`

## Purpose
This artifact is intentionally simple and represents a single-agent baseline for comparison against an enhanced long-running workflow version.
