const API_BASE_URL = 'http://localhost:3001/api';

// DOM Elements
const todoForm = document.getElementById('todo-form');
const todoInput = document.getElementById('todo-input');
const todoList = document.getElementById('todo-list');
const errorMessage = document.getElementById('error-message');
const clearCompletedBtn = document.getElementById('clear-completed');
const totalCount = document.getElementById('total-count');
const remainingCount = document.getElementById('remaining-count');
const completedCount = document.getElementById('completed-count');

// State
let todos = [];

// API Functions
async function fetchTodos() {
    try {
        const response = await fetch(`${API_BASE_URL}/todos`);
        if (!response.ok) throw new Error('Failed to fetch todos');
        todos = await response.json();
        renderTodos();
        updateStats();
    } catch (error) {
        showError('Failed to load tasks. Please check if the API server is running.');
    }
}

async function createTodo(text) {
    try {
        const response = await fetch(`${API_BASE_URL}/todos`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ text })
        });
        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.message || 'Failed to create task');
        }
        const newTodo = await response.json();
        todos.push(newTodo);
        renderTodos();
        updateStats();
        hideError();
    } catch (error) {
        showError(error.message);
    }
}

async function updateTodo(id, updates) {
    try {
        const response = await fetch(`${API_BASE_URL}/todos/${id}`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(updates)
        });
        if (!response.ok) throw new Error('Failed to update task');
        const updatedTodo = await response.json();
        todos = todos.map(todo => todo.id === id ? updatedTodo : todo);
        renderTodos();
        updateStats();
    } catch (error) {
        showError(error.message);
    }
}

async function deleteTodo(id) {
    try {
        const response = await fetch(`${API_BASE_URL}/todos/${id}`, {
            method: 'DELETE'
        });
        if (!response.ok) throw new Error('Failed to delete task');
        todos = todos.filter(todo => todo.id !== id);
        renderTodos();
        updateStats();
    } catch (error) {
        showError(error.message);
    }
}

async function clearCompleted() {
    try {
        const response = await fetch(`${API_BASE_URL}/todos`, {
            method: 'DELETE'
        });
        if (!response.ok) throw new Error('Failed to clear completed tasks');
        todos = todos.filter(todo => !todo.completed);
        renderTodos();
        updateStats();
    } catch (error) {
        showError(error.message);
    }
}

// UI Functions
function renderTodos() {
    if (todos.length === 0) {
        todoList.innerHTML = '<li class="empty-state">No tasks yet. Add one above!</li>';
        return;
    }

    todoList.innerHTML = todos.map(todo => `
        <li class="todo-item" data-id="${todo.id}">
            <input 
                type="checkbox" 
                class="todo-checkbox" 
                ${todo.completed ? 'checked' : ''} 
                aria-label="Mark task as complete"
            >
            <input 
                type="text" 
                class="todo-text ${todo.completed ? 'completed' : ''}" 
                value="${escapeHtml(todo.text)}"
                aria-label="Task text"
            >
            <button class="btn btn-delete" aria-label="Delete task">✕</button>
        </li>
    `).join('');

    // Add event listeners
    todoList.querySelectorAll('.todo-checkbox').forEach(checkbox => {
        checkbox.addEventListener('change', handleToggle);
    });

    todoList.querySelectorAll('.todo-text').forEach(input => {
        input.addEventListener('blur', handleEdit);
        input.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                e.target.blur();
            }
        });
    });

    todoList.querySelectorAll('.btn-delete').forEach(btn => {
        btn.addEventListener('click', handleDelete);
    });
}

function updateStats() {
    const total = todos.length;
    const completed = todos.filter(t => t.completed).length;
    const remaining = total - completed;

    totalCount.textContent = `${total} total`;
    remainingCount.textContent = `${remaining} remaining`;
    completedCount.textContent = `${completed} completed`;
}

function showError(message) {
    errorMessage.textContent = message;
    errorMessage.classList.add('show');
    setTimeout(hideError, 5000);
}

function hideError() {
    errorMessage.classList.remove('show');
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Event Handlers
async function handleSubmit(e) {
    e.preventDefault();
    const text = todoInput.value.trim();
    
    if (!text) {
        showError('Task text cannot be empty');
        return;
    }

    await createTodo(text);
    todoInput.value = '';
    todoInput.focus();
}

async function handleToggle(e) {
    const todoItem = e.target.closest('.todo-item');
    const id = parseInt(todoItem.dataset.id);
    const completed = e.target.checked;
    await updateTodo(id, { completed });
}

async function handleEdit(e) {
    const todoItem = e.target.closest('.todo-item');
    const id = parseInt(todoItem.dataset.id);
    const text = e.target.value.trim();
    
    if (!text) {
        showError('Task text cannot be empty');
        e.target.value = todos.find(t => t.id === id)?.text || '';
        return;
    }

    const originalTodo = todos.find(t => t.id === id);
    if (originalTodo && originalTodo.text !== text) {
        await updateTodo(id, { text });
    }
}

async function handleDelete(e) {
    const todoItem = e.target.closest('.todo-item');
    const id = parseInt(todoItem.dataset.id);
    await deleteTodo(id);
}

async function handleClearCompleted() {
    const completedCount = todos.filter(t => t.completed).length;
    if (completedCount === 0) {
        showError('No completed tasks to clear');
        return;
    }
    await clearCompleted();
}

// Initialize
todoForm.addEventListener('submit', handleSubmit);
clearCompletedBtn.addEventListener('click', handleClearCompleted);

// Load todos on page load
fetchTodos();
