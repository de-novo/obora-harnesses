"""Local file persistence for tasks."""

import json
import os
from pathlib import Path
from typing import List, Dict, Optional


DATA_DIR = Path.home() / ".todo-cli"
DATA_FILE = DATA_DIR / "tasks.json"


def _ensure_data_dir() -> None:
    """Ensure the data directory exists."""
    DATA_DIR.mkdir(exist_ok=True)


def load_tasks() -> List[Dict]:
    """Load all tasks from local storage."""
    _ensure_data_dir()
    if not DATA_FILE.exists():
        return []
    try:
        with open(DATA_FILE, "r") as f:
            return json.load(f)
    except (json.JSONDecodeError, IOError):
        return []


def save_tasks(tasks: List[Dict]) -> None:
    """Save tasks to local storage."""
    _ensure_data_dir()
    with open(DATA_FILE, "w") as f:
        json.dump(tasks, f, indent=2)


def add_task(text: str) -> int:
    """Add a new task and return its ID."""
    tasks = load_tasks()
    if tasks:
        task_id = max(task["id"] for task in tasks) + 1
    else:
        task_id = 1
    tasks.append({"id": task_id, "text": text, "done": False})
    save_tasks(tasks)
    return task_id


def find_task(task_id: int) -> Optional[Dict]:
    """Find a task by ID."""
    tasks = load_tasks()
    for task in tasks:
        if task["id"] == task_id:
            return task
    return None


def mark_done(task_id: int) -> bool:
    """Mark a task as completed. Returns True if task was found and updated."""
    tasks = load_tasks()
    for task in tasks:
        if task["id"] == task_id:
            task["done"] = True
            save_tasks(tasks)
            return True
    return False


def delete_task(task_id: int) -> bool:
    """Delete a task by ID. Returns True if task was found and removed."""
    tasks = load_tasks()
    for i, task in enumerate(tasks):
        if task["id"] == task_id:
            tasks.pop(i)
            save_tasks(tasks)
            return True
    return False


def clear_completed_tasks() -> int:
    """Delete all completed tasks. Returns count of tasks removed."""
    tasks = load_tasks()
    original_count = len(tasks)
    tasks = [task for task in tasks if not task.get("done")]
    removed_count = original_count - len(tasks)
    if removed_count > 0:
        save_tasks(tasks)
    return removed_count
