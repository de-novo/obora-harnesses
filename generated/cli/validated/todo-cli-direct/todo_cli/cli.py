"""CLI entrypoint for todo application."""

import sys
from todo_cli.storage import load_tasks, add_task, mark_done, delete_task, clear_completed_tasks


def show_help() -> None:
    """Display usage information."""
    print("Todo CLI - A minimal task management application")
    print()
    print("Usage:")
    print("  todo <command> [arguments]")
    print()
    print("Commands:")
    print("  help        Show this help message")
    print("  add <text>  Create a new task")
    print("  list        Display all tasks")
    print("  done <id>   Mark a task as completed")
    print("  delete <id> Remove a task")
    print("  clear       Delete all completed tasks")
    print()
    print("Examples:")
    print("  todo add Buy groceries")
    print("  todo list")
    print("  todo done 1")
    print("  todo delete 1")
    print("  todo clear")


def cmd_add(args: list[str]) -> None:
    """Add a new task."""
    if len(args) < 1:
        print("Error: add requires task text", file=sys.stderr)
        print("Usage: todo add <text>", file=sys.stderr)
        sys.exit(1)
    text = " ".join(args)
    task_id = add_task(text)
    print(f"Added task #{task_id}: {text}")


def cmd_list() -> None:
    """List all tasks."""
    tasks = load_tasks()
    if not tasks:
        print("No tasks found.")
        return
    for task in tasks:
        status = "✓" if task.get("done") else " "
        print(f"[{task['id']}] [{status}] {task['text']}")


def cmd_done(args: list[str]) -> None:
    """Mark a task as completed."""
    if len(args) < 1:
        print("Error: done requires task ID", file=sys.stderr)
        print("Usage: todo done <id>", file=sys.stderr)
        sys.exit(1)
    try:
        task_id = int(args[0])
    except ValueError:
        print(f"Error: invalid task ID '{args[0]}'", file=sys.stderr)
        sys.exit(1)
    if mark_done(task_id):
        print(f"Marked task #{task_id} as done")
    else:
        print(f"Error: task #{task_id} not found", file=sys.stderr)
        sys.exit(1)


def cmd_delete(args: list[str]) -> None:
    """Delete a task."""
    if len(args) < 1:
        print("Error: delete requires task ID", file=sys.stderr)
        print("Usage: todo delete <id>", file=sys.stderr)
        sys.exit(1)
    try:
        task_id = int(args[0])
    except ValueError:
        print(f"Error: invalid task ID '{args[0]}'", file=sys.stderr)
        sys.exit(1)
    if delete_task(task_id):
        print(f"Deleted task #{task_id}")
    else:
        print(f"Error: task #{task_id} not found", file=sys.stderr)
        sys.exit(1)


def cmd_clear() -> None:
    """Delete all completed tasks."""
    response = input("Delete all completed tasks? (y/N): ")
    if response.lower() != "y":
        print("Cancelled.")
        return
    removed = clear_completed_tasks()
    if removed == 0:
        print("No completed tasks to remove.")
    else:
        print(f"Deleted {removed} completed task(s).")


def main() -> None:
    """Main CLI entrypoint."""
    if len(sys.argv) < 2:
        show_help()
        sys.exit(0)
    
    command = sys.argv[1].lower()
    args = sys.argv[2:]
    
    if command in ("help", "-h", "--help"):
        show_help()
    elif command == "add":
        cmd_add(args)
    elif command in ("list", "ls"):
        cmd_list()
    elif command in ("done", "d"):
        cmd_done(args)
    elif command in ("delete", "rm"):
        cmd_delete(args)
    elif command == "clear":
        cmd_clear()
    else:
        print(f"Error: unknown command '{command}'", file=sys.stderr)
        print("Run 'todo help' for usage information.", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
