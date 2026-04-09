import { useState, useEffect, useCallback } from 'react';
import type { Todo } from './types/todo';
import * as api from './services/api';
import TodoForm from './components/TodoForm';
import TodoList from './components/TodoList';
import './App.css';

function App() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [error, setError] = useState<string>('');
  const [loading, setLoading] = useState(true);

  // Fetch todos on mount
  useEffect(() => {
    loadTodos();
  }, []);

  const loadTodos = async () => {
    try {
      setLoading(true);
      const data = await api.getTodos();
      setTodos(data);
      setError('');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load tasks');
    } finally {
      setLoading(false);
    }
  };

  const handleAdd = useCallback(async (text: string) => {
    try {
      const newTodo = await api.createTodo({ text });
      setTodos(prev => [...prev, newTodo]);
      setError('');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to add task');
    }
  }, []);

  const handleToggle = useCallback(async (id: string, completed: boolean) => {
    try {
      const updated = await api.updateTodo(id, { completed: !completed });
      setTodos(prev => prev.map(todo => (todo.id === id ? updated : todo)));
      setError('');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update task');
    }
  }, []);

  const handleUpdateText = useCallback(async (id: string, text: string) => {
    try {
      const updated = await api.updateTodo(id, { text });
      setTodos(prev => prev.map(todo => (todo.id === id ? updated : todo)));
      setError('');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update task');
    }
  }, []);

  const handleDelete = useCallback(async (id: string) => {
    try {
      await api.deleteTodo(id);
      setTodos(prev => prev.filter(todo => todo.id !== id));
      setError('');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to delete task');
    }
  }, []);

  const handleClearCompleted = useCallback(async () => {
    try {
      await api.clearCompletedTodos();
      setTodos(prev => prev.filter(todo => !todo.completed));
      setError('');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to clear completed tasks');
    }
  }, []);

  const stats = {
    total: todos.length,
    completed: todos.filter(t => t.completed).length,
    remaining: todos.filter(t => !t.completed).length,
  };

  return (
    <div className="container">
      <header>
        <h1>My Tasks</h1>
        <div className="stats">
          <span>{stats.total} total</span>
          <span>{stats.remaining} remaining</span>
          <span>{stats.completed} completed</span>
        </div>
      </header>

      <TodoForm onAdd={handleAdd} />

      {error && (
        <div className="error-message show" role="alert">
          {error}
        </div>
      )}

      {loading ? (
        <div className="loading">Loading tasks...</div>
      ) : (
        <TodoList
          todos={todos}
          onToggle={handleToggle}
          onUpdateText={handleUpdateText}
          onDelete={handleDelete}
        />
      )}

      <footer className="footer">
        <button
          className="btn btn-secondary"
          onClick={handleClearCompleted}
          disabled={stats.completed === 0}
        >
          Clear Completed
        </button>
      </footer>
    </div>
  );
}

export default App;
