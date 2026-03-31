const express = require('express');
const cors = require('cors');

const app = express();
const PORT = 3001;

// Middleware
app.use(cors({
  origin: 'http://localhost:3000'
}));
app.use(express.json());

// In-memory storage
let todos = [];
let nextId = 1;

// Validation helper
function validateTodo(req, res, next) {
  const { text } = req.body;
  
  if (req.method === 'POST' && (!text || typeof text !== 'string' || text.trim() === '')) {
    return res.status(400).json({ error: 'Task text is required and cannot be empty' });
  }
  
  if (req.method === 'PATCH' && req.body.text !== undefined && (typeof req.body.text !== 'string' || req.body.text.trim() === '')) {
    return res.status(400).json({ error: 'Task text cannot be empty' });
  }
  
  next();
}

// Routes

// GET /api/todos - Get all todos
app.get('/api/todos', (req, res) => {
  res.json(todos);
});

// POST /api/todos - Create a new todo
app.post('/api/todos', validateTodo, (req, res) => {
  const { text } = req.body;
  
  const newTodo = {
    id: nextId++,
    text: text.trim(),
    completed: false,
    createdAt: new Date().toISOString()
  };
  
  todos.push(newTodo);
  res.status(201).json(newTodo);
});

// PATCH /api/todos/:id - Update a todo
app.patch('/api/todos/:id', validateTodo, (req, res) => {
  const id = parseInt(req.params.id);
  const updates = req.body;
  
  const todoIndex = todos.findIndex(todo => todo.id === id);
  
  if (todoIndex === -1) {
    return res.status(404).json({ error: 'Todo not found' });
  }
  
  // Update only allowed fields
  if (updates.text !== undefined) {
    todos[todoIndex].text = updates.text.trim();
  }
  if (updates.completed !== undefined) {
    todos[todoIndex].completed = Boolean(updates.completed);
  }
  
  res.json(todos[todoIndex]);
});

// DELETE /api/todos/:id - Delete a todo
app.delete('/api/todos/:id', (req, res) => {
  const id = parseInt(req.params.id);
  
  const todoIndex = todos.findIndex(todo => todo.id === id);
  
  if (todoIndex === -1) {
    return res.status(404).json({ error: 'Todo not found' });
  }
  
  const deletedTodo = todos.splice(todoIndex, 1)[0];
  res.json(deletedTodo);
});

// DELETE /api/todos - Clear completed todos
app.delete('/api/todos', (req, res) => {
  const originalCount = todos.length;
  todos = todos.filter(todo => !todo.completed);
  const deletedCount = originalCount - todos.length;
  
  res.json({ 
    message: `Cleared ${deletedCount} completed todo(s)`,
    deletedCount 
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// Start server
app.listen(PORT, () => {
  console.log(`Todo API server running on http://localhost:${PORT}`);
});
