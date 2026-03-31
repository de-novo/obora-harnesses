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
  console.log(`Todo CLI\n
Usage:
  todo-cli-enhanced help
  todo-cli-enhanced add <task>
  todo-cli-enhanced list
  todo-cli-enhanced done <id>
  todo-cli-enhanced delete <id>
  todo-cli-enhanced clear

Commands:
  add <task>    Create a new pending task
  list          Display all tasks with status indicators
  done <id>     Mark a specific task as completed
  delete <id>   Remove a task by ID
  clear         Delete all completed tasks
`);
}

function parseId(value) {
  const id = Number(value);
  if (!Number.isInteger(id) || id <= 0) throw new Error(`Invalid id: ${value}`);
  return id;
}

function normalizeTaskText(parts) {
  const text = parts.join(' ').trim();
  if (!text) throw new Error('Task description is required.');
  return text;
}

function addTask(parts) {
  const description = normalizeTaskText(parts);
  const store = readStore();
  const task = {
    id: store.nextId++,
    description,
    status: 'pending'
  };
  store.todos.push(task);
  writeStore(store);
  console.log(`Added task #${task.id}: ${task.description}`);
}

function listTasks() {
  const store = readStore();
  const todos = store.todos;

  if (todos.length === 0) {
    console.log('No tasks.');
    return;
  }

  for (const task of todos) {
    const status = task.status === 'completed' ? '[x]' : '[ ]';
    console.log(`${status} ${task.id}. ${task.description}`);
  }
}

function doneTask(idValue) {
  const id = parseId(idValue);
  const store = readStore();
  const task = store.todos.find((item) => item.id === id);
  if (!task) throw new Error(`Task #${id} not found.`);
  if (task.status === 'completed') {
    console.log(`Task #${id} is already completed.`);
    return;
  }
  task.status = 'completed';
  writeStore(store);
  console.log(`Marked task #${id} as completed.`);
}

function deleteTask(idValue) {
  const id = parseId(idValue);
  const store = readStore();
  const index = store.todos.findIndex((item) => item.id === id);
  if (index === -1) throw new Error(`Task #${id} not found.`);
  const [removed] = store.todos.splice(index, 1);
  writeStore(store);
  console.log(`Deleted task #${removed.id}: ${removed.description}`);
}

function clearTasks() {
  const store = readStore();
  const originalCount = store.todos.length;
  store.todos = store.todos.filter((task) => task.status !== 'completed');
  const clearedCount = originalCount - store.todos.length;
  
  if (clearedCount === 0) {
    console.log('No completed tasks to clear.');
    return;
  }
  
  writeStore(store);
  console.log(`Cleared ${clearedCount} completed task(s).`);
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
      addTask(args);
      return;
    case 'list':
      listTasks();
      return;
    case 'done':
      doneTask(args[0]);
      return;
    case 'delete':
      deleteTask(args[0]);
      return;
    case 'clear':
      clearTasks();
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
