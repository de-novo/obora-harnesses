#!/usr/bin/env python3
"""Deterministic smoke test for Todo CLI slice-2 (done/delete/clear)."""
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

TARGET_DIR = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()
OUT_PATH = Path(sys.argv[2]) if len(sys.argv) > 2 else TARGET_DIR / "artifacts" / "smoke-report-slice2.json"

# Use actual storage location from implementation
import os as _os
STORAGE_FILE = Path(_os.path.expanduser("~/.todo-cli-enhanced/todos.json"))

def run_cmd(args, check=False):
    """Run a command and capture output."""
    result = subprocess.run(
        ["node", str(TARGET_DIR / "src" / "index.js")] + args,
        capture_output=True,
        text=True,
        cwd=TARGET_DIR,
        check=check
    )
    return {"cmd": ["node", "./src/index.js"] + args, "code": result.returncode, "stdout": result.stdout, "stderr": result.stderr}

def reset_storage():
    """Clean storage before test."""
    if STORAGE_FILE.exists():
        STORAGE_FILE.unlink()
    STORAGE_FILE.parent.mkdir(parents=True, exist_ok=True)
    STORAGE_FILE.write_text('{"todos":[],"nextId":1}')

def main():
    reset_storage()

    checks = []
    passed = True
    failed_checks = []

    # Test: help includes done/delete/clear
    r = run_cmd(["help"])
    checks.append(r)
    if "done" not in r["stdout"].lower() or "delete" not in r["stdout"].lower() or "clear" not in r["stdout"].lower():
        passed = False
        failed_checks.append({"name": "help-slice2-coverage", "message": "help output missing done/delete/clear", "stdout_tail": r["stdout"][-200:]})

    # Setup: add two todos
    r = run_cmd(["add", "task one"])
    checks.append(r)
    if r["code"] != 0:
        passed = False
        failed_checks.append({"name": "add-command-1", "message": f"add task one failed with code {r['code']}", "stderr_tail": r["stderr"][-200:]})
    
    r = run_cmd(["add", "task two"])
    checks.append(r)
    if r["code"] != 0:
        passed = False
        failed_checks.append({"name": "add-command-2", "message": f"add task two failed with code {r['code']}", "stderr_tail": r["stderr"][-200:]})

    # Test: done <id>
    r = run_cmd(["done", "1"])
    checks.append(r)
    if r["code"] != 0:
        passed = False
        failed_checks.append({"name": "done-command", "message": f"done 1 failed with code {r['code']}", "stderr_tail": r["stderr"][-200:]})

    # Verify done in list
    r = run_cmd(["list"])
    checks.append(r)
    if "[x]" not in r["stdout"].lower() and "✓" not in r["stdout"]:
        passed = False
        failed_checks.append({"name": "done-reflects-in-list", "message": "list does not show completed marker after done", "stdout_tail": r["stdout"][-200:]})

    # Test: delete <id>
    r = run_cmd(["delete", "2"])
    checks.append(r)
    if r["code"] != 0:
        passed = False
        failed_checks.append({"name": "delete-command", "message": f"delete 2 failed with code {r['code']}", "stderr_tail": r["stderr"][-200:]})

    # Verify delete in list
    r = run_cmd(["list"])
    checks.append(r)
    if "task two" in r["stdout"]:
        passed = False
        failed_checks.append({"name": "delete-removes-from-list", "message": "deleted task still appears in list", "stdout_tail": r["stdout"][-200:]})

    # Test: clear
    r = run_cmd(["clear"])
    checks.append(r)
    if r["code"] != 0:
        passed = False
        failed_checks.append({"name": "clear-command", "message": f"clear failed with code {r['code']}", "stderr_tail": r["stderr"][-200:]})

    # Verify clear in list
    r = run_cmd(["list"])
    checks.append(r)
    if r["stdout"].strip() and r["stdout"].strip() != "No tasks.":
        passed = False
        failed_checks.append({"name": "clear-empties-list", "message": "list not empty after clear", "stdout_tail": r["stdout"][-200:]})

    # Write report
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    report = {
        "passed": passed,
        "summary": "Todo CLI slice-2 smoke passed" if passed else "Todo CLI slice-2 smoke failed",
        "failedChecks": failed_checks,
        "signature": "pass" if passed else "fail",
        "checks": checks
    }
    OUT_PATH.write_text(json.dumps(report, indent=2) + "\n")

    print(json.dumps(report, indent=2))
    sys.exit(0 if passed else 1)

if __name__ == "__main__":
    main()
