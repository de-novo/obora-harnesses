#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');

const DATA_DIR = path.join(os.homedir(), '.todo-cli-minimal');
const DATA_FILE = path.join(DATA_DIR, 'todos.json');
const TEMP_FILE = path.join(DATA_DIR, 'todos.tmp.json');

function ensureDataDir() {
  try {
    if (!fs.existsSync(DATA_DIR)) {
      fs.mkdirSync(DATA_DIR, { recursive: true });
    }
  } catch (err) {
    console.error(`Error creating data directory: ${err.message}`);
    process.exit(1);
  }
}

function loadTodos() {
  ensureDataDir();
  if (!fs.existsSync(DATA_FILE)) {
    return { todos: [], nextId: 1 };
  }
  try {
    const data = fs.readFileSync(DATA_FILE, 'utf8');
    return JSON.parse(data);
  } catch (err) {
    console.error(`Error reading todos: ${err.message}`);
    process.exit(1);
  }
}

function saveTodos(data) {
  ensureDataDir();
  try {
    const json = JSON.stringify(data, null, 2);
    fs.writeFileSync(TEMP_FILE, json, 'utf8');
    fs.renameSync(TEMP_FILE, DATA_FILE);
  } catch (err) {
    console.error(`Error saving todos: ${err.message}`);
    process.exit(1);
  }
}

function cmdHelp() {
  console.log('Todo CLI - Minimal version');
  console.log('');
  console.log('Usage:');
  console.log('  todo help          Show this help message');
  console.log('  todo add <text>    Add a new todo');
  console.log('  todo list          Show all todos');
  process.exit(0);
}

function cmdAdd(text) {
  if (!text || text.trim() === '') {
    console.error('Error: todo text cannot be empty');
    process.exit(1);
  }
  const data = loadTodos();
  const todo = {
    id: data.nextId++,
    text: text.trim(),
    done: false
  };
  data.todos.push(todo);
  saveTodos(data);
  console.log(`Added: [${todo.id}] ${todo.text}`);
  process.exit(0);
}

function cmdList() {
  const data = loadTodos();
  if (data.todos.length === 0) {
    console.log('No todos found.');
    process.exit(0);
  }
  data.todos.forEach(todo => {
    const status = todo.done ? '✓' : ' ';
    console.log(`[${status}] [${todo.id}] ${todo.text}`);
  });
  process.exit(0);
}

function main() {
  const args = process.argv.slice(2);
  const command = args[0];

  switch (command) {
    case 'help':
    case '--help':
    case '-h':
      cmdHelp();
      break;
    case 'add':
      cmdAdd(args.slice(1).join(' '));
      break;
    case 'list':
      cmdList();
      break;
    default:
      if (!command) {
        cmdHelp();
      } else {
        console.error(`Unknown command: ${command}`);
        console.error('Run "todo help" for usage.');
        process.exit(1);
      }
  }
}

main();
