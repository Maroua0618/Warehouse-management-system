# Supervisor Feature → Existing Database Tables Mapping

## ✅ Database Strategy: USE ONLY EXISTING TABLES

### 1. **Bon de Commande (Command Orders)** → Reception of Products

**Tables Used:**

- `orders` (type = 'COMMAND')
- `command_orders` (tracks reception_at timestamp)
- `stock_ledger_entries` (operation_type = 'RECEPTION', tracks product lines)

**Structure:**

```sql
-- Order header
INSERT INTO orders (type, status, source, created_by)
VALUES ('COMMAND', 'DRAFT', 'supplier_X', user_id);

-- Command order metadata
INSERT INTO command_orders (order_id, reception_at)
VALUES (order_id, NOW());

-- Product lines (each SKU received)
INSERT INTO stock_ledger_entries
(sku_id, to_location_id, qty_delta, operation_type, order_id, idempotency_key)
VALUES (sku_id, reception_location_id, quantity_received, 'RECEPTION', order_id, unique_key);
```

**API Endpoints:**

- `GET /command-orders` - List all command orders
- `GET /command-orders/{id}/lines` - Get product lines from stock_ledger_entries
- `POST /command-orders` - Create new command order

---

### 2. **Storage Moves** → Move products from reception to storage

**Tables Used:**

- `operation_tasks` (operation_type = 'STORAGE')
- `stock_ledger_entries` (tracks the movement)
- `ai_recommendations` (AI suggests best location)

**Structure:**

```sql
-- AI recommendation for storage location
INSERT INTO ai_recommendations (type, payload_json, order_id)
VALUES ('STORAGE_OPTIMIZATION',
        '{"assigned_slot": "B01-N2-A05", "floor": 2, "zone": "A", "abc_class": "A", "score": 0.95}'::jsonb,
        order_id);

-- Storage task
INSERT INTO operation_tasks
(operation_type, status, order_id, assigned_to_user_id, chariot_id, planned_route_id)
VALUES ('STORAGE', 'PENDING', order_id, user_id, chariot_id, route_plan_id);

-- Execute movement (when completed)
INSERT INTO stock_ledger_entries
(sku_id, from_location_id, to_location_id, qty_delta, operation_type, task_id, idempotency_key)
VALUES (sku_id, reception_loc, storage_loc, quantity, 'STORAGE', task_id, unique_key);
```

**API Endpoints:**

- `GET /storage-moves` - List storage tasks from operation_tasks
- `POST /storage-moves` - Create storage task
- `PUT /storage-moves/{id}` - Update task status
- `DELETE /storage-moves/{id}` - Cancel task

---

### 3. **Bon de Préparation** → Preparation slips for deliveries

**Tables Used:**

- `orders` (type = 'PREPARATION', linked to delivery_id)
- `deliveries` (tracks delivery status)
- `stock_ledger_entries` (operation_type = 'PREPARATION', tracks items picked from storage to picking zone)

**Structure:**

```sql
-- Delivery
INSERT INTO deliveries (status) VALUES ('IDLE');

-- Preparation order
INSERT INTO orders (type, status, source, delivery_id, created_by)
VALUES ('PREPARATION', 'DRAFT', 'client_X', delivery_id, user_id);

-- Items to prepare (track via ledger entries when moved to picking zone)
INSERT INTO stock_ledger_entries
(sku_id, from_location_id, to_location_id, qty_delta, operation_type, order_id, idempotency_key)
VALUES (sku_id, storage_loc, picking_loc, quantity, 'PREPARATION', order_id, unique_key);
```

**API Endpoints:**

- `GET /bon-de-preparation` - List preparation orders
- `POST /bon-de-preparation` - Create preparation slip
- `GET /bon-de-preparation/{id}/items` - Get items from stock_ledger_entries

---

### 4. **Bon de Picking (Picking Tasks)** → Picking routes

**Tables Used:**

- `operation_tasks` (operation_type = 'PICKING')
- `deliveries` (linked via delivery_id)
- `route_plans` (stores optimized path)
- `stock_ledger_entries` (tracks items picked)
- `ai_recommendations` (AI optimizes picking route)

**Structure:**

```sql
-- AI recommendation for picking route
INSERT INTO ai_recommendations (type, payload_json, delivery_id)
VALUES ('PICKING_ROUTE_OPTIMIZATION',
        '{"route": [{"sku": "SKU1", "location": "B01-N2-A05", "floor": 2}], "total_distance": 287.5}'::jsonb,
        delivery_id);

-- Picking task
INSERT INTO operation_tasks
(operation_type, status, delivery_id, assigned_to_user_id, chariot_id, planned_route_id)
VALUES ('PICKING', 'PENDING', delivery_id, user_id, chariot_id, route_id);

-- Execute picks (when completed)
INSERT INTO stock_ledger_entries
(sku_id, from_location_id, to_location_id, qty_delta, operation_type, task_id, delivery_id, idempotency_key)
VALUES (sku_id, picking_loc, expedition_loc, quantity, 'PICKING', task_id, delivery_id, unique_key);
```

**API Endpoints:**

- `GET /picking-tasks` - List picking tasks
- `POST /picking-tasks` - Create picking task with AI route
- `PUT /picking-tasks/{id}/pick-item` - Mark item picked

---

### 5. **Bon de Livraison** → Delivery tracking

**Tables Used:**

- `deliveries` (primary table)
- `orders` (linked via delivery_id)
- `operation_tasks` (picking/loading tasks)

**Structure:**

```sql
-- Already exists, just update status
UPDATE deliveries SET status = 'IN_PROGRESS', updated_at = NOW()
WHERE delivery_id = ?;

-- Status flow: IDLE → IN_PROGRESS → DONE / FAILED
```

**API Endpoints:**

- `GET /deliveries` - List all deliveries
- `GET /deliveries/{id}` - Get delivery with all related orders/tasks
- `PUT /deliveries/{id}/status` - Update delivery status

---

### 6. **Employee Tracking** → Worker location and status

**Tables Used:**

- `users` (use `status` field: 'ACTIVE', 'BREAK', 'IDLE')
- `operation_tasks` (assigned_to_user_id shows current work)
- `audit_logs` (track all employee actions)

**Structure:**

```sql
-- Query active employees
SELECT u.id, u.name, u.status,
       COUNT(DISTINCT ot.id) as active_tasks,
       MAX(ot.created_at) as last_active
FROM users u
LEFT JOIN operation_tasks ot ON ot.assigned_to_user_id = u.id AND ot.status IN ('PENDING', 'IN_PROGRESS')
WHERE u.status = 'ACTIVE'
GROUP BY u.id, u.name, u.status;

-- Track performance (use audit_logs)
SELECT actor_user_id, COUNT(*) as actions_today
FROM audit_logs
WHERE DATE(ts) = CURRENT_DATE
GROUP BY actor_user_id;
```

**API Endpoints:**

- `GET /employees/active` - List active employees
- `GET /employees/{id}/tasks` - Get employee's current tasks
- `GET /employees/{id}/performance` - Calculate from audit_logs

---

### 7. **Operational Alerts** → Issues and violations

**Tables Used:**

- `ai_recommendations` (use type = 'ALERT\_\*')
- `override_decisions` (track when humans override AI)
- `operation_tasks` (delayed tasks)

**Structure:**

```sql
-- Low stock alert
INSERT INTO ai_recommendations (type, payload_json)
VALUES ('ALERT_LOW_STOCK',
        '{"sku_id": "...", "current_qty": 5, "threshold": 10}'::jsonb);

-- Task delay alert
INSERT INTO ai_recommendations (type, payload_json, task_id)
VALUES ('ALERT_TASK_DELAY',
        '{"task_id": "...", "delay_minutes": 45}'::jsonb,
        task_id);

-- Query overrides (violations)
SELECT * FROM override_decisions WHERE status = 'PENDING';
```

**API Endpoints:**

- `GET /operational-alerts` - Get active alerts from ai_recommendations
- `GET /operational-alerts/overrides` - Get pending override decisions

---

### 8. **AI Recommendations** → Storage/Picking optimization

**Tables Used:**

- `ai_recommendations` (stores all AI suggestions)
- `override_decisions` (stores human overrides)
- `recommendation_feedback` (stores feedback for ML)

**AI Result Format (from Optimization_Agents.ipynb):**

```json
{
  "type": "STORAGE_OPTIMIZATION",
  "payload_json": {
    "assigned_slot": "B01-N2-A05",
    "floor": 2,
    "zone": "A",
    "x": 45,
    "y": 23,
    "abc_class": "A",
    "priority": 0.95,
    "score": 0.892,
    "path": [[8,8], [9,8], ...],
    "path_length": 42,
    "estimated_time_seconds": 84
  }
}
```

**API Endpoints:**

- `GET /ai/recommend/storage?sku_id=...&weight=...` - Get AI storage recommendation
- `GET /ai/recommend/picking?delivery_id=...` - Get AI picking route
- `POST /ai/override` - Override AI decision

---

### 9. **Dashboard Stats** → Supervisor overview

**Queries:**

```sql
-- Active employees count
SELECT COUNT(*) FROM users WHERE status = 'ACTIVE';

-- Pending violations (overrides)
SELECT COUNT(*) FROM override_decisions WHERE status = 'PENDING';

-- Today's orders
SELECT COUNT(*) FROM orders WHERE DATE(created_at) = CURRENT_DATE;

-- AI overrides count
SELECT COUNT(*) FROM override_decisions WHERE DATE(created_at) = CURRENT_DATE;

-- Performance metrics (from audit_logs + operation_tasks)
SELECT
  COUNT(CASE WHEN ot.status = 'COMPLETED' THEN 1 END) as completed_tasks,
  COUNT(CASE WHEN ot.created_at < NOW() - INTERVAL '1 hour' AND ot.status = 'PENDING' THEN 1 END) as delayed_tasks
FROM operation_tasks ot
WHERE DATE(ot.created_at) = CURRENT_DATE;
```

---

## 📊 Summary Table

| Feature            | Primary Tables              | Secondary Tables                         | AI Used? |
| ------------------ | --------------------------- | ---------------------------------------- | -------- |
| Bon de Commande    | orders, command_orders      | stock_ledger_entries                     | ❌       |
| Storage Moves      | operation_tasks             | stock_ledger_entries, ai_recommendations | ✅       |
| Bon de Préparation | orders, deliveries          | stock_ledger_entries                     | ❌       |
| Bon de Picking     | operation_tasks, deliveries | route_plans, ai_recommendations          | ✅       |
| Bon de Livraison   | deliveries                  | orders, operation_tasks                  | ❌       |
| Employee Tracking  | users                       | operation_tasks, audit_logs              | ❌       |
| Operational Alerts | ai_recommendations          | override_decisions                       | ✅       |
| Dashboard          | ALL                         | audit_logs                               | ✅       |

---

## 🚀 Benefits of This Approach

1. ✅ **No new tables** - Uses existing database structure
2. ✅ **AI-ready** - `ai_recommendations` table stores all AI suggestions
3. ✅ **Audit trail** - `audit_logs` + `stock_ledger_entries` track everything
4. ✅ **Flexible** - `payload_json` in JSONB allows schema evolution
5. ✅ **Normalized** - Proper foreign keys and relationships
6. ✅ **Scalable** - Indexes on all key columns

---

## 📝 Implementation Steps

1. ✅ Remove all SQL files creating new tables
2. ✅ Update all Pydantic schemas to match existing tables
3. ✅ Refactor all API endpoints to use existing tables
4. ✅ Create mock data using existing table structure
5. ✅ Test all endpoints with real database
