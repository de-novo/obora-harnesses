# Implementation Notes

## Step: implement_scaffold

### What was implemented:
- **CLI entrypoint**: `todo_cli/cli.py` with `main()` function
- **Help command**: `show_help()` displays usage and examples
- **Add command**: `cmd_add()` creates tasks with auto-incrementing IDs
- **List command**: `cmd_list()` displays all stored tasks
- **Persistence layer**: `todo_cli/storage.py` with JSON file storage at `~/.todo-cli/tasks.json`
- **Package structure**: `pyproject.toml` defines CLI script entry point `todo`

### Decisions:
- Simple JSON array for task storage
- Auto-incrementing integer IDs (1-based)
- Data directory created automatically on first use
- Graceful handling of missing/corrupted data file (returns empty list)
- Basic argument parsing without external dependencies

### Not implemented (deferred per contract):
- Task status (done/undone)
- Delete/remove operations
- Clear all tasks
- Filtering by status
- Priority levels, due dates, tagging

## Step: implement_done

### What was implemented:
- **Task model extension**: Added `"done"` field (boolean) to task objects, defaults to `False`
- **Storage additions**: 
  - `find_task(task_id)` returns task by ID or None
  - `mark_done(task_id)` sets task's done flag to True and persists, returns bool success
- **CLI done command**: `cmd_done()` parses ID, validates input, calls mark_done, shows confirmation or error
- **Help update**: Added done command usage with example
- **List update**: Displays `[✓]` for completed tasks, `[ ]` for pending

### Changes:
- `add_task()` now includes `"done": False` in new tasks
- `cmd_list()` shows status indicator: `[id] [✓] text` or `[id] [ ] text`
- `cmd_done()` handles invalid ID format and non-existent task errors
- Command alias `d` supported for done

### Backward compatibility:
- Existing tasks without `"done"` field treated as pending (task.get("done") returns None)
- Storage format remains JSON array

## Step: implement_delete

### What was implemented:
- **Storage addition**: `delete_task(task_id)` removes task by ID and persists, returns bool success
- **CLI delete command**: `cmd_delete()` parses ID, validates input, calls delete_task, shows confirmation or error
- **Help update**: Added delete command usage with example
- **Command alias**: `rm` supported for delete

### Changes:
- Added `delete_task()` in `storage.py` - finds task by index and removes it, then saves
- Added `cmd_delete()` in `cli.py` with same ID validation pattern as `cmd_done()`
- Updated `main()` to handle "delete" and "rm" commands
- Updated help text to include delete command and example

### Backward compatibility:
- All existing help/add/list/done behavior preserved
- Storage format unchanged (still JSON array)

## Step: implement_clear

### What was implemented:
- **Storage addition**: `clear_completed_tasks()` filters out all tasks with `done: True` and persists, returns count of removed tasks
- **CLI clear command**: `cmd_clear()` prompts user for confirmation (y/N), calls clear_completed_tasks, shows count of deleted tasks
- **Help update**: Added clear command usage with example
- **Main update**: Added "clear" command handler

### Changes:
- Added `clear_completed_tasks()` in `storage.py` - filters tasks list and saves if any removed
- Added `cmd_clear()` in `cli.py` with user confirmation prompt
- Updated `show_help()` to include clear command
- Updated `main()` to handle "clear" command

### Backward compatibility:
- All existing help/add/list/done/delete behavior preserved
- Storage format unchanged (still JSON array)
- Pending tasks unaffected by clear operation
