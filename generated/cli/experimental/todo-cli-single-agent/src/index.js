#!/usr/bin/env node

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const APP_DIR = path.join(os.homedir(), '.todo-cli-single-agent');
const DATA_FILE = path.join(APP_DIR, 'todos.json');

function ensureStore() {
  if (!fs.existsSync(APP_DIR)) fs.mkdirSync(APP_DIR, { recursive: true });
  if (!fs.existsSync(DATA_FILE)) {
    fs.writeFileSync(DATA_FILE, JSON.stringify({ todos: [], nextId: 1 }, null, 2));
  }
}

function readStore() {
  ensureStore();
  return JSON.parse(fs.readFileSync(DATA_FILE, 'utf8'));
}

function writeStore(store) {
  ensureStore();
  fs.writeFileSync(DATA_FILE, JSON.stringify(store, null, 2));
}

function printHelp() {
  console.log(`Todo CLI (single-agent baseline)\n
Usage:
  todo-cli help
  todo-cli add <text>
  todo-cli list
  todo-cli done <id>
  todo-cli remove <id>
  todo-cli clear

Examples:
  todo-cli add "buy milk"
  todo-cli list
  todo-cli done 1
  todo-cli remove 1
  todo-cli clear
`);
}

function formatTodo(todo) {
  const mark = todo.done ? '[x]' : '[ ]';
  return `${mark} ${todo.id}. ${todo.text}`;
}

function parseId(value) {
  const id = Number(value);
  if (!Number.isInteger(id) || id <= 0) {
    throw new Error(`Invalid id: ${value}`);
  }
  return id;
}

function addTodo(text) {
  const trimmed = text.trim();
  if (!trimmed) throw new Error('Todo text is required.');
  const store = readStore();
  const todo = { id: store.nextId++, text: trimmed, done: false, createdAt: new Date().toISOString() };
  store.todos.push(todo);
  writeStore(store);
  console.log(`Added todo #${todo.id}: ${todo.text}`);
}

function listTodos() {
  const store = readStore();
  if (store.todos.length === 0) {
    console.log('No todos yet.');
    return;
  }
  for (const todo of store.todos) console.log(formatTodo(todo));
}

function markDone(idValue) {
  const id = parseId(idValue);
  const store = readStore();
  const todo = store.todos.find((item) => item.id === id);
  if (!todo) throw new Error(`Todo #${id} not found.`);
  todo.done = true;
  writeStore(store);
  console.log(`Marked todo #${id} as done.`);
}

function removeTodo(idValue) {
  const id = parseId(idValue);
  const store = readStore();
  const before = store.todos.length;
  store.todos = store.todos.filter((item) => item.id !== id);
  if (store.todos.length === before) throw new Error(`Todo #${id} not found.`);
  writeStore(store);
  console.log(`Removed todo #${id}.`);
}

function clearTodos() {
  writeStore({ todos: [], nextId: 1 });
  console.log('Cleared all todos.');
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
      addTodo(args.join(' '));
      return;
    case 'list':
      listTodos();
      return;
    case 'done':
      markDone(args[0]);
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
  console.error('Run `todo-cli help` for usage.');
  process.exit(1);
}
