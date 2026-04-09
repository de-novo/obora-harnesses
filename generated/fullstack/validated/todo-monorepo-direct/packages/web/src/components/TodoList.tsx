import type { Todo } from '../types/todo';
import TodoItem from './TodoItem';

interface TodoListProps {
  todos: Todo[];
  onToggle: (id: string, completed: boolean) => Promise<void>;
  onUpdateText: (id: string, text: string) => Promise<void>;
  onDelete: (id: string) => Promise<void>;
}

function TodoList({ todos, onToggle, onUpdateText, onDelete }: TodoListProps) {
  if (todos.length === 0) {
    return (
      <ul className="todo-list" role="list">
        <li className="empty-state">No tasks yet. Add one above!</li>
      </ul>
    );
  }

  return (
    <ul className="todo-list" role="list">
      {todos.map(todo => (
        <TodoItem
          key={todo.id}
          todo={todo}
          onToggle={onToggle}
          onUpdateText={onUpdateText}
          onDelete={onDelete}
        />
      ))}
    </ul>
  );
}

export default TodoList;
