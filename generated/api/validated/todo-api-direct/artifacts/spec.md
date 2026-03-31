# Todo REST API - Product Specification

## Target User
Developers who need a lightweight, local todo management API for prototyping, testing, or learning REST API design without database setup overhead.

## Primary Use Cases
- Create a new todo item with a title and optional description
- Retrieve a list of all todos
- Retrieve a specific todo by ID
- Update an existing todo's title, description, or completion status
- Mark a todo as complete/incomplete
- Delete a todo by ID

## Required Endpoints

| Method | Path | Description | Request Body |
|--------|------|-------------|--------------|
| GET | `/todos` | List all todos | None |
| POST | `/todos` | Create a new todo | `{ "title": string, "description": string (optional) }` |
| GET | `/todos/{id}` | Get a specific todo | None |
| PUT | `/todos/{id}` | Update a todo | `{ "title": string, "description": string, "completed": boolean }` |
| PATCH | `/todos/{id}` | Partially update a todo | Any of: `{ "title": string, "description": string, "completed": boolean }` |
| DELETE | `/todos/{id}` | Delete a todo | None |

## Non-Goals
- User authentication/authorization
- Persistent storage (data lost on restart)
- Multi-user support or sharing
- Due dates, priorities, or categorization
- Search or filtering capabilities
- Bulk operations

## Quality Expections
- **RESTful Design**: Proper HTTP methods, status codes, and resource-oriented URLs
- **Idempotency**: PUT and DELETE operations are idempotent
- **Error Handling**: Clear error messages with appropriate HTTP status codes (404 for not found, 400 for invalid input)
- **Input Validation**: Reject invalid requests with descriptive error messages
- **Response Format**: Consistent JSON responses for all endpoints
- **API Documentation**: Self-documenting through clear endpoint contracts
- **Simplicity**: Minimal dependencies, easy to run locally
