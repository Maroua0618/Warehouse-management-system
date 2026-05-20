# API Endpoints Documentation

Complete API reference for the Mobile Backend.

## Base URL
```
http://localhost:8000
```

---

## Authentication Endpoints

### 1. Login
**POST** `/auth/login`

Authenticate employee or supervisor.

**Request Body:**
```json
{
  "email": "employee1@example.com",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Alex Johnson",
    "email": "employee1@example.com",
    "role": "EMPLOYEE",
    "status": "ACTIVE"
  }
}
```

**Errors:**
- `401 Unauthorized` - Invalid credentials
- `403 Forbidden` - Account not active

---

### 2. Logout
**POST** `/auth/logout`

Invalidate current session (client should discard token).

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200 OK):**
```json
{
  "message": "Logged out successfully"
}
```

---

## Employee Profile Endpoints

### 1. Get Employee Profile
**GET** `/employee/profile`

Get employee information and performance statistics.

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200 OK):**
```json
{
  "profile": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Alex Johnson",
    "email": "employee1@example.com",
    "role": "EMPLOYEE",
    "status": "ACTIVE",
    "zone": "North Zone",
    "shift_start": "08:00",
    "shift_end": "16:00",
    "duty_status": true
  },
  "performance": {
    "tasks_completed": 14,
    "total_tasks": 20,
    "accuracy": 98.0,
    "efficiency": 94.0
  }
}
```

---

## Task Management Endpoints

### 1. Get Employee Tasks
**GET** `/tasks`

Get all tasks assigned to the current employee.

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200 OK):**
```json
{
  "ingoing_tasks": [
    {
      "id": "task-uuid-1",
      "order_id": "order-uuid-1",
      "order_type": "COMMAND",
      "status": "ASSIGNED",
      "operation_type": "RECEIPT",
      "created_at": "2026-02-13T09:30:00Z",
      "item_count": 12,
      "delivery_id": "DEL-99283"
    }
  ],
  "outgoing_tasks": [
    {
      "id": "task-uuid-2",
      "order_id": "order-uuid-2",
      "order_type": "DELIVERY",
      "status": "IN_PROGRESS",
      "operation_type": "DELIVERY",
      "created_at": "2026-02-13T10:45:00Z",
      "item_count": 8,
      "delivery_id": "DEL-99284"
    }
  ]
}
```

---

### 2. Get Task Detail
**GET** `/tasks/{task_id}`

Get detailed information for a specific task.

**Headers:**
```
Authorization: Bearer <token>
```

**Path Parameters:**
- `task_id` (string) - Task UUID

**Response (200 OK):**
```json
{
  "id": "task-uuid-1",
  "order_id": "order-uuid-1",
  "order_code": "ING-9932",
  "order_type": "COMMAND",
  "order_status": "VALIDATED",
  "status": "IN_PROGRESS",
  "operation_type": "RECEIPT",
  "created_at": "2026-02-13T09:30:00Z",
  "completed_at": null,
  "validated": false,
  "chariot": {
    "id": "chariot-uuid",
    "code": "C-04",
    "is_active": true
  },
  "route": {
    "id": "route-uuid",
    "total_distance_meters": 125.5,
    "path_nodes": [
      {"x": 10, "y": 5, "floor_level": 3},
      {"x": 12, "y": 5, "floor_level": 3}
    ],
    "estimated_time_minutes": 8
  },
  "delivery_id": "DEL-99283",
  "storage_location": {
    "id": "loc-uuid",
    "code": "Floor 3, Row B",
    "type": "STORAGE",
    "floor_level": 3,
    "row": null,
    "col": null
  },
  "items": [
    {
      "id": "line-uuid-1",
      "sku": {
        "id": "sku-uuid",
        "sku_code": "1002-AX",
        "name": "Product Name",
        "weight_kg": 2.5
      },
      "quantity": 50,
      "source_location": null,
      "destination_location": null
    }
  ],
  "product_validations": [
    {
      "description": "Quantity verified",
      "validated": false
    },
    {
      "description": "Product type verified",
      "validated": false
    }
  ]
}
```

**Errors:**
- `404 Not Found` - Task not found
- `403 Forbidden` - Not authorized to view this task

---

### 3. Update Task Status
**PUT** `/tasks/{task_id}/status`

Update the status of a task.

**Headers:**
```
Authorization: Bearer <token>
```

**Path Parameters:**
- `task_id` (string) - Task UUID

**Request Body:**
```json
{
  "status": "IN_PROGRESS",
  "notes": "Started working on this task"
}
```

**Valid Status Transitions:**
- `ASSIGNED` → `IN_PROGRESS`
- `IN_PROGRESS` → `DONE`

**Response (200 OK):**
Returns updated task detail (same format as Get Task Detail).

**Errors:**
- `404 Not Found` - Task not found
- `403 Forbidden` - Not authorized to update this task

---

### 4. Validate Task
**POST** `/tasks/{task_id}/validate`

Validate and complete a task.

**Headers:**
```
Authorization: Bearer <token>
```

**Path Parameters:**
- `task_id` (string) - Task UUID

**Request Body:**
```json
{
  "validated": true,
  "notes": "All items verified and placed correctly"
}
```

**Response (200 OK):**
Returns updated task detail with `validated: true` and `status: DONE`.

---

### 5. Confirm Placement
**POST** `/tasks/{task_id}/confirm-placement`

Confirm product placement in storage or picking location.

**Headers:**
```
Authorization: Bearer <token>
```

**Path Parameters:**
- `task_id` (string) - Task UUID

**Request Body:**
```json
{
  "sku_code": "1002-AX",
  "target_slot": "B-12",
  "quantity": 50
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Placement confirmed for SKU 1002-AX in slot B-12"
}
```

---

### 6. Get Task Route
**GET** `/tasks/{task_id}/route`

Get optimized route/path for a task.

**Headers:**
```
Authorization: Bearer <token>
```

**Path Parameters:**
- `task_id` (string) - Task UUID

**Response (200 OK):**
```json
{
  "id": "route-uuid",
  "total_distance_meters": 125.5,
  "path_nodes": [
    {"x": 10, "y": 5, "floor_level": 3},
    {"x": 12, "y": 5, "floor_level": 3},
    {"x": 15, "y": 5, "floor_level": 3}
  ],
  "estimated_time_minutes": 8
}
```

---

## Issue Reporting Endpoints

### 1. Get Issue Types
**GET** `/tasks/issues/types`

Get available issue categories for reporting.

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200 OK):**
```json
{
  "operational_categories": [
    {
      "id": "damaged_products",
      "name": "Damaged Products",
      "description": "Physical damage to items or packaging",
      "category": "DAMAGED_PRODUCTS"
    },
    {
      "id": "wrong_quantity",
      "name": "Wrong Quantity Delivered",
      "description": "Received count doesn't match manifest",
      "category": "WRONG_QUANTITY"
    },
    {
      "id": "wrong_sku",
      "name": "Wrong SKU Delivered",
      "description": "Incorrect item variant or product code",
      "category": "WRONG_SKU"
    },
    {
      "id": "storage_error",
      "name": "Storage Assignment Error",
      "description": "Item placed in wrong bin or zone",
      "category": "STORAGE_ASSIGNMENT_ERROR"
    },
    {
      "id": "workflow_bottleneck",
      "name": "Workflow Bottleneck",
      "description": "Processing delay or equipment failure",
      "category": "WORKFLOW_BOTTLENECK"
    },
    {
      "id": "stock_availability",
      "name": "Stock Availability Problem",
      "description": "Discrepancy in digital vs physical inventory",
      "category": "STOCK_AVAILABILITY"
    }
  ]
}
```

---

### 2. Report Issue
**POST** `/tasks/{task_id}/report-issue`

Report an issue for a specific task.

**Headers:**
```
Authorization: Bearer <token>
```

**Path Parameters:**
- `task_id` (string) - Task UUID

**Request Body:**
```json
{
  "task_id": "task-uuid-1",
  "order_id": "order-uuid-1",
  "category": "DAMAGED_PRODUCTS",
  "description": "We got a 10 damaged product in the Order #ING34-12345. due to transfer."
}
```

**Response (200 OK):**
```json
{
  "id": "issue-uuid",
  "task_id": "task-uuid-1",
  "order_id": "order-uuid-1",
  "category": "DAMAGED_PRODUCTS",
  "description": "We got a 10 damaged product in the Order #ING34-12345. due to transfer.",
  "reported_by": "Alex Johnson",
  "created_at": "2026-02-13T11:30:00Z",
  "status": "PENDING"
}
```

**Errors:**
- `404 Not Found` - Task not found
- `403 Forbidden` - Not authorized to report issue for this task
- `400 Bad Request` - Description too short (min 10 characters)

---

## Health Check Endpoints

### 1. Root
**GET** `/`

Basic health check.

**Response (200 OK):**
```json
{
  "name": "MobAI WMS - Mobile Backend",
  "version": "1.0.0",
  "status": "running"
}
```

---

### 2. Health Check
**GET** `/health`

Detailed health status.

**Response (200 OK):**
```json
{
  "status": "healthy",
  "service": "mobile-backend",
  "version": "1.0.0"
}
```

---

## Error Responses

All endpoints may return these common error responses:

### 401 Unauthorized
```json
{
  "detail": "Could not validate credentials"
}
```

### 403 Forbidden
```json
{
  "detail": "Access forbidden: Employee role required"
}
```

### 404 Not Found
```json
{
  "detail": "Task not found"
}
```

### 422 Unprocessable Entity
```json
{
  "detail": [
    {
      "loc": ["body", "email"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```

---

## Authentication

All endpoints except `/auth/login`, `/`, and `/health` require authentication.

Include the access token in the Authorization header:

```
Authorization: Bearer <your-access-token>
```

Tokens expire after 24 hours. After expiration, users must log in again.

---

## Rate Limiting

Currently not implemented. Consider adding rate limiting in production.

---

## CORS

CORS is enabled for all origins in development. Configure `cors_origins` in production.
