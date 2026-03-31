#!/usr/bin/env python3
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path


def run(cmd, cwd, env):
    p = subprocess.run(cmd, cwd=cwd, env=env, capture_output=True, text=True)
    return {
        "cmd": cmd,
        "code": p.returncode,
        "stdout": p.stdout,
        "stderr": p.stderr,
    }


def main():
    if len(sys.argv) != 3:
        print("usage: smoke_todo_cli_slice1.py <target_dir> <output_json>", file=sys.stderr)
        sys.exit(2)

    target_dir = Path(sys.argv[1]).resolve()
    output_json = Path(sys.argv[2]).resolve()
    qa_home = target_dir / ".qa-home-slice1"
    if qa_home.exists():
        shutil.rmtree(qa_home)
    qa_home.mkdir(parents=True, exist_ok=True)

    env = os.environ.copy()
    env["HOME"] = str(qa_home)

    checks = []
    checks.append(run(["node", "./src/index.js", "help"], cwd=target_dir, env=env))
    checks.append(run(["node", "./src/index.js", "add", "buy milk"], cwd=target_dir, env=env))
    checks.append(run(["node", "./src/index.js", "add", "write notes"], cwd=target_dir, env=env))
    checks.append(run(["node", "./src/index.js", "list"], cwd=target_dir, env=env))

    failures = []
    if checks[0]["code"] != 0 or "Usage:" not in checks[0]["stdout"]:
        failures.append({"name": "help-output", "message": "help output missing or failed"})
    if checks[1]["code"] != 0 or ("Added task #1" not in checks[1]["stdout"] and "Added todo #1" not in checks[1]["stdout"]):
        failures.append({"name": "add-first", "message": "first add failed"})
    if checks[2]["code"] != 0 or ("Added task #2" not in checks[2]["stdout"] and "Added todo #2" not in checks[2]["stdout"]):
        failures.append({"name": "add-second", "message": "second add failed"})
    out = checks[3]["stdout"]
    if checks[3]["code"] != 0 or "buy milk" not in out or "write notes" not in out:
        failures.append({"name": "list-after-add", "message": "list output after add is incorrect"})

    payload = {
        "passed": len(failures) == 0,
        "summary": "Todo CLI slice-1 smoke passed" if not failures else "Todo CLI slice-1 smoke failed",
        "failedChecks": failures,
        "signature": "pass" if not failures else failures[0]["name"],
        "checks": checks,
    }
    output_json.parent.mkdir(parents=True, exist_ok=True)
    output_json.write_text(json.dumps(payload, indent=2))
    print(json.dumps(payload, indent=2))
    sys.exit(0 if not failures else 1)


if __name__ == "__main__":
    main()
