#!/usr/bin/env node

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const APP_DIR = path.join(os.homedir(), '.todo-cli-enhanced');
const DATA_FILE = path.join(APP_DIR, 'todos.json');

function ensureStore() {
  if (!fs.existsSync(APP_DIR)) fs.mkdirSync(APP_DIR, { recursive: true });
  if (!fs.existsSync(DATA_FILE)) {
    writeStore({ todos: [], nextId: 1 });
  }
}

function readStore() {
  ensureStore();
  const raw = fs.readFileSync(DATA_FILE, 'utf8');
  const parsed = JSON.parse(raw);
  if (!parsed || !Array.isArray(parsed.todos) || !Number.isInteger(parsed.nextId)) {
    throw new Error('Todo storage is corrupted.');
  }
  return parsed;
}

function writeStore(store) {
  if (!fs.existsSync(APP_DIR)) fs.mkdirSync(APP_DIR, { recursive: true });
  const temp = `${DATA_FILE}.tmp`;
  fs.writeFileSync(temp, JSON.stringify(store, null, 2));
  fs.renameSync(temp, DATA_FILE);
}

function printHelp() {
  console.log(`Todo CLI (enhanced workflow artifact)\n
Usage:
  todo-cli-enhanced help
  todo-cli-enhanced add <text>
  todo-cli-enhanced list [--all|--done|--open]
  todo-cli-enhanced done <id>
  todo-cli-enhanced remove <id>
  todo-cli-enhanced clear

Notes:
  - data is stored locally in JSON
  - ids are numeric and stable within the local store
  - list defaults to open items only
`);
}

function parseId(value) {
  const id = Number(value);
  if (!Number.isInteger(id) || id <= 0) throw new Error(`Invalid id: ${value}`);
  return id;
}

function normalizeText(parts) {
  const text = parts.join(' ').trim();
  if (!text) throw new Error('Todo text is required.');
  return text;
}

function addTodo(parts) {
  const text = normalizeText(parts);
  const store = readStore();
  const todo = {
    id: store.nextId++,
    text,
    done: false,
    createdAt: new Date().toISOString(),
    completedAt: null
  };
  store.todos.push(todo);
  writeStore(store);
  console.log(`Added todo #${todo.id}: ${todo.text}`);
}

function listTodos(args) {
  const filter = args[0] ?? '--open';
  const store = readStore();
  let todos = store.todos;
  if (filter === '--done') todos = todos.filter((t) => t.done);
  else if (filter === '--open') todos = todos.filter((t) => !t.done);
  else if (filter !== '--all') throw new Error(`Unknown list filter: ${filter}`);

  if (todos.length === 0) {
    console.log('No matching todos.');
    return;
  }

  for (const todo of todos) {
    const status = todo.done ? '[x]' : '[ ]';
    console.log(`${status} ${todo.id}. ${todo.text}`);
  }
}

function doneTodo(idValue) {
  const id = parseId(idValue);
  const store = readStore();
  const todo = store.todos.find((item) => item.id === id);
  if (!todo) throw new Error(`Todo #${id} not found.`);
  if (todo.done) {
    console.log(`Todo #${id} is already done.`);
    return;
  }
  todo.done = true;
  todo.completedAt = new Date().toISOString();
  writeStore(store);
  console.log(`Marked todo #${id} as done.`);
}

function removeTodo(idValue) {
  const id = parseId(idValue);
  const store = readStore();
  const index = store.todos.findIndex((item) => item.id === id);
  if (index === -1) throw new Error(`Todo #${id} not found.`);
  const [removed] = store.todos.splice(index, 1);
  writeStore(store);
  console.log(`Removed todo #${removed.id}: ${removed.text}`);
}

function clearTodos() {
  writeStore({ todos: [], nextId: 1 });
  console.log('Cleared all todos and reset local storage.');
}

function main(argv) {
  const [command = 'help', ...args] = argv;

  switch (command) {
    case 'help':
    case '--help':
    case '-h':
      printHelp();
      return;
    case 'add':
      addTodo(args);
      return;
    case 'list':
      listTodos(args);
      return;
    case 'done':
      doneTodo(args[0]);
      return;
    case 'remove':
      removeTodo(args[0]);
      return;
    case 'clear':
      clearTodos();
      return;
    default:
      throw new Error(`Unknown command: ${command}`);
  }
}

try {
  main(process.argv.slice(2));
} catch (error) {
  console.error(`Error: ${error.message}`);
  console.error('Run `todo-cli-enhanced help` for usage.');
  process.exit(1);
}
