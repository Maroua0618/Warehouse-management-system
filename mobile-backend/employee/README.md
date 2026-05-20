# MobAI WMS - Mobile Backend

FastAPI backend for employee and supervisor mobile interfaces.

## Features

- **Authentication**: JWT-based authentication for employees and supervisors
- **Task Management**: View, update, and complete operational tasks
- **Issue Reporting**: Report and track warehouse issues
- **Profile Management**: View employee performance statistics

## Setup

1. **Install dependencies**:
```bash
pip install -r requirements.txt
```

2. **Configure environment**:
The `.env` file is already configured with Supabase credentials.

3. **Run the server**:
```bash
uvicorn main:app --reload
```

The API will be available at `http://localhost:8000`

## API Documentation

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## API Endpoints

### Authentication
- `POST /auth/login` - Employee/Supervisor login
- `POST /auth/logout` - Logout

### Employee Profile
- `GET /employee/profile` - Get employee profile and performance stats

### Task Management
- `GET /tasks` - Get assigned tasks (ingoing/outgoing)
- `GET /tasks/{task_id}` - Get task details
- `PUT /tasks/{task_id}/status` - Update task status
- `POST /tasks/{task_id}/validate` - Validate and complete task
- `POST /tasks/{task_id}/confirm-placement` - Confirm product placement
- `GET /tasks/{task_id}/route` - Get task route information

### Issue Reporting
- `GET /tasks/issues/types` - Get available issue categories
- `POST /tasks/{task_id}/report-issue` - Report an issue

## Project Structure

```
mobile-backend/
├── main.py                 # FastAPI application entry point
├── requirements.txt        # Python dependencies
├── .env                   # Environment variables
├── app/
│   ├── config.py          # Application configuration
│   ├── database.py        # Supabase client setup
│   ├── dependencies.py    # FastAPI dependencies
│   ├── api/              # API route handlers
│   │   ├── auth.py       # Authentication endpoints
│   │   ├── employee.py   # Employee endpoints
│   │   └── tasks.py      # Task management endpoints
│   ├── schemas/          # Pydantic models for request/response
│   │   ├── auth.py
│   │   ├── employee.py
│   │   ├── task.py
│   │   ├── issue.py
│   │   └── common.py
│   ├── services/         # Business logic layer
│   │   ├── auth_service.py
│   │   ├── task_service.py
│   │   └── issue_service.py
│   └── utils/           # Utility functions
│       ├── security.py  # JWT and password hashing
│       └── helpers.py   # Helper functions
```

## Employee App Features Supported

### 1. Dashboard
- View assigned tasks (ingoing/outgoing orders)
- Current zone information
- Today's task list with status

### 2. Task Operations
- **Receipt**: Check and record received products
- **Storage Assignment**: Confirm product placement in designated slots
- **Picking**: Retrieve products from storage to picking racks
- **Delivery**: Transport and validate delivery placement

### 3. Task Details
- Order information and status
- Product validation checklist
- Optimized route/path (with chariot assignment)
- Storage/picking location details
- Estimated time savings

### 4. Issue Reporting
- Report operational issues by category
- Damaged products
- Wrong quantity/SKU delivered
- Storage assignment errors
- Workflow bottlenecks
- Stock availability problems

### 5. Profile & Stats
- Performance metrics (accuracy, efficiency)
- Tasks completed count
- Shift information
- Duty status toggle

## Development

### Run in development mode:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Run in production:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

## Authentication Flow

1. Employee logs in with email and password
2. Server validates credentials against Supabase database
3. Server returns JWT access token
4. Client includes token in Authorization header for subsequent requests
5. Token valid for 24 hours

## Security

- Passwords hashed with bcrypt
- JWT tokens with expiration
- Role-based access control (Employee/Supervisor)
- Protected endpoints require valid authentication
