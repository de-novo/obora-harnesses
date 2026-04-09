import { useState, ChangeEvent, KeyboardEvent, useCallback } from 'react';
import type { Todo } from '../types/todo';

interface TodoItemProps {
  todo: Todo;
  onToggle: (id: string, completed: boolean) => Promise<void>;
  onUpdateText: (id: string, text: string) => Promise<void>;
  onDelete: (id: string) => Promise<void>;
}

function TodoItem({ todo, onToggle, onUpdateText, onDelete }: TodoItemProps) {
  const [editing, setEditing] = useState(false);
  const [editText, setEditText] = useState(todo.text);

  const handleToggle = useCallback(() => {
    onToggle(todo.id, todo.completed);
  }, [todo.id, todo.completed, onToggle]);

  const handleDelete = useCallback(() => {
    onDelete(todo.id);
  }, [todo.id, onDelete]);

  const handleEditStart = useCallback(() => {
    setEditing(true);
    setEditText(todo.text);
  }, [todo.text]);

  const handleEditChange = (e: ChangeEvent<HTMLInputElement>) => {
    setEditText(e.target.value);
  };

  const handleEditSubmit = useCallback(() => {
    const trimmed = editText.trim();
    if (!trimmed) {
      setEditText(todo.text);
      setEditing(false);
      return;
    }

    if (trimmed !== todo.text) {
      onUpdateText(todo.id, trimmed);
    }
    setEditing(false);
  }, [editText, todo.id, todo.text, onUpdateText]);

  const handleKeyDown = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      handleEditSubmit();
    } else if (e.key === 'Escape') {
      setEditText(todo.text);
      setEditing(false);
    }
  };

  return (
    <li className="todo-item" data-id={todo.id}>
      <input
        type="checkbox"
        className="todo-checkbox"
        checked={todo.completed}
        onChange={handleToggle}
        aria-label="Mark task as complete"
      />
      {editing ? (
        <input
          type="text"
          className="todo-text-input"
          value={editText}
          onChange={handleEditChange}
          onBlur={handleEditSubmit}
          onKeyDown={handleKeyDown}
          autoFocus
          aria-label="Edit task text"
        />
      ) : (
        <span
          className={`todo-text ${todo.completed ? 'completed' : ''}`}
          onClick={handleEditStart}
          role="button"
          tabIndex={0}
          onKeyDown={(e) => e.key === 'Enter' && handleEditStart()}
          aria-label="Task text - click to edit"
        >
          {todo.text}
        </span>
      )}
      <button
        className="btn btn-delete"
        onClick={handleDelete}
        aria-label="Delete task"
      >
        ✕
      </button>
    </li>
  );
}

export default TodoItem;
