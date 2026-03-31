# Todo App

A minimal viable todo application with a web frontend and RESTful API using in-memory storage.

## Monorepo Structure

This project uses npm workspaces to manage multiple packages in a single repository:

```
todo-app/
├── package.json           # Root package with workspaces config
├── packages/
│   ├── api/              # Express.js REST API
│   │   └── package.json
│   └── web/              # Static HTML/CSS/JS frontend
│       └── package.json
└── README.md
```

## Packages

### `@todo-app/api`
RESTful API serving JSON over HTTP with in-memory storage.

### `@todo-app/web`
Browser-based UI with vanilla JavaScript for task management.

## Installation

```bash
npm install
```

This will install dependencies for all workspace packages.

## Development

Run both API and web frontend in parallel:

```bash
npm run dev
```

Run individual packages:

```bash
npm run dev:api   # Start API server (http://localhost:3001)
npm run dev:web   # Start web server (http://localhost:3000)
```

## Features

- Add tasks with descriptions
- View all tasks in a single list
- Toggle task completion status
- Edit task text
- Delete tasks
- Clear completed tasks
- Task counter (total, remaining, completed)
- Basic validation (non-empty task text)

## API Endpoints

- `GET /tasks` - List all tasks
- `POST /tasks` - Create a new task
- `PUT /tasks/:id` - Update a task
- `DELETE /tasks/:id` - Delete a task
- `POST /tasks/clear` - Clear all completed tasks

## Technology Stack

- **Frontend**: Vanilla HTML/CSS/JS
- **Backend**: Express.js
- **Storage**: In-memory (data lost on server restart)
- **Package Manager**: npm with workspaces

## Browser Support

Modern browsers with ES2020+ support.

## License

MIT
