#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');

const DATA_DIR = path.join(os.homedir(), '.todo-cli-minimal');
const DATA_FILE = path.join(DATA_DIR, 'todos.json');

function ensureDataDir() {
  if (!fs.existsSync(DATA_DIR)) {
    fs.mkdirSync(DATA_DIR, { recursive: true });
  }
}

function readTodos() {
  if (!fs.existsSync(DATA_FILE)) {
    return { todos: [], nextId: 1 };
  }
  try {
    const data = fs.readFileSync(DATA_FILE, 'utf8');
    return JSON.parse(data);
  } catch (err) {
    console.error('Error: Failed to read todos file. It may be corrupted.');
    process.exit(1);
  }
}

function writeTodos(data) {
  ensureDataDir();
  const tempFile = path.join(DATA_DIR, `todos.${Date.now()}.tmp`);
  try {
    fs.writeFileSync(tempFile, JSON.stringify(data, null, 2), 'utf8');
    fs.renameSync(tempFile, DATA_FILE);
  } catch (err) {
    console.error('Error: Failed to write todos file.');
    process.exit(1);
  }
}

function showHelp() {
  console.log('Usage: todo <command>');
  console.log('');
  console.log('Commands:');
  console.log('  help          Show this help message');
  console.log('  add <text>    Add a new todo');
  console.log('  list          Show all todos');
}

function cmdAdd(text) {
  if (!text || text.trim() === '') {
    console.error('Error: Todo text cannot be empty.');
    process.exit(1);
  }
  const data = readTodos();
  const newTodo = {
    id: data.nextId,
    text: text.trim(),
    done: false
  };
  data.todos.push(newTodo);
  data.nextId += 1;
  writeTodos(data);
  console.log(`Added: ${newTodo.text}`);
}

function cmdList() {
  const data = readTodos();
  if (data.todos.length === 0) {
    console.log('No todos yet.');
    return;
  }
  data.todos.forEach(todo => {
    console.log(`${todo.id}: [${todo.done ? 'x' : ' '}] ${todo.text}`);
  });
}

function main() {
  const args = process.argv.slice(2);
  if (args.length === 0) {
    showHelp();
    process.exit(0);
  }

  const command = args[0];
  const commandArgs = args.slice(1);

  switch (command) {
    case 'help':
      showHelp();
      break;
    case 'add':
      cmdAdd(commandArgs.join(' '));
      break;
    case 'list':
      cmdList();
      break;
    default:
      console.error(`Error: Unknown command '${command}'`);
      showHelp();
      process.exit(1);
  }
}

main();
