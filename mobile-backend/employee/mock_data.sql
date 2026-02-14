-- =====================================================
-- Mock Data for Employee Backend Testing
-- Employee ID: 30c64ceb-a1f3-43b9-8407-d6ceacbca7a8
-- =====================================================

-- =====================================================
-- 1. USER (Employee)
-- =====================================================
-- Note: Using existing Supabase Auth user
-- Email: employee@test.com
-- ID: 30c64ceb-a1f3-43b9-8407-d6ceacbca7a8

INSERT INTO public.users (id, name, email, status, role)
VALUES 
('30c64ceb-a1f3-43b9-8407-d6ceacbca7a8', 'Alex Johnson', 'employee@test.com', 'ACTIVE', 'EMPLOYEE')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  status = EXCLUDED.status,
  role = EXCLUDED.role;

-- Another employee for testing
INSERT INTO public.users (id, name, email, status, role)
VALUES 
('b3d4e5f6-1234-5678-90ab-cdef12345678', 'Sarah Martinez', 'employee2@mobai.com', 'ACTIVE', 'EMPLOYEE'),
('c4e5f6a7-2345-6789-01bc-def123456789', 'Michael Chen', 'supervisor1@mobai.com', 'ACTIVE', 'SUPERVISOR')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 2. WAREHOUSES & STRUCTURE
-- =====================================================
INSERT INTO public.warehouses (id, code, name)
VALUES 
('a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', 'WH-A1', 'Warehouse A1 - Main Distribution Center')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.floors (id, warehouse_id, level)
VALUES 
('f1a2b3c4-d5e6-4f7a-9b8c-0d1e2f3a4b5c', 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', 1),
('f2a3b4c5-d6e7-4f8a-9b0c-1d2e3f4a5b6c', 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', 2),
('f3a4b5c6-d7e8-4f9a-9b1c-2d3e4f5a6b7c', 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', 3)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 3. LOCATIONS (Storage, Picking, Reception, Expedition)
-- =====================================================
INSERT INTO public.locations (id, floor_id, code, type, is_active)
VALUES 
-- Reception zones
('d1e2f3a4-b5c6-4d7e-8f9a-0b1c2d3e4f5a', 'f1a2b3c4-d5e6-4f7a-9b8c-0d1e2f3a4b5c', 'Reception-A', 'RECEPTION', true),
-- Storage locations (Floor 3)
('d2e3f4a5-b6c7-4d8e-9f0a-1b2c3d4e5f6a', 'f3a4b5c6-d7e8-4f9a-9b1c-2d3e4f5a6b7c', 'Floor 3, Row B', 'STORAGE', true),
('d3e4f5a6-b7c8-4d9e-0f1a-2b3c4d5e6f7a', 'f3a4b5c6-d7e8-4f9a-9b1c-2d3e4f5a6b7c', 'Floor 3, Row C', 'STORAGE', true),
('d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a', 'f3a4b5c6-d7e8-4f9a-9b1c-2d3e4f5a6b7c', 'Storage-3A-14', 'STORAGE', true),
-- Picking locations
('d5e6f7a8-b9c0-4d1e-2f3a-4b5c6d7e8f9a', 'f2a3b4c5-d6e7-4f8a-9b0c-1d2e3f4a5b6c', 'Pick-Zone-A', 'PICKING', true),
('d6e7f8a9-b0c1-4d2e-3f4a-5b6c7d8e9f0a', 'f2a3b4c5-d6e7-4f8a-9b0c-1d2e3f4a5b6c', 'Pick-Zone-B', 'PICKING', true),
-- Expedition zone
('d7e8f9a0-b1c2-4d3e-4f5a-6b7c8d9e0f1a', 'f1a2b3c4-d5e6-4f7a-9b8c-0d1e2f3a4b5c', 'Ground Floor - Expedition Zone', 'EXPEDITION', true)
ON CONFLICT (id) DO NOTHING;

-- Storage location details
INSERT INTO public.storage_locations (location_id, level, slot_code, area_m2, is_available)
VALUES 
('d2e3f4a5-b6c7-4d8e-9f0a-1b2c3d4e5f6a', 3, 'B-12', 15.5, true),
('d3e4f5a6-b7c8-4d9e-0f1a-2b3c4d5e6f7a', 3, 'C-08', 12.0, true),
('d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a', 3, 'A-14', 18.2, true)
ON CONFLICT (location_id) DO NOTHING;

-- Picking location details
INSERT INTO public.picking_locations (location_id, row, col)
VALUES 
('d5e6f7a8-b9c0-4d1e-2f3a-4b5c6d7e8f9a', 1, 5),
('d6e7f8a9-b0c1-4d2e-3f4a-5b6c7d8e9f0a', 2, 8)
ON CONFLICT (location_id) DO NOTHING;

-- =====================================================
-- 4. SKUS (Products)
-- =====================================================
INSERT INTO public.skus (id, sku_code, name, weight_kg)
VALUES 
('e1f2a3b4-c5d6-4e7f-8a9b-0c1d2e3f4a5b', '1002-AX', 'Electronics - Smart Watch Pro', 0.250),
('e2f3a4b5-c6d7-4e8f-9a0b-1c2d3e4f5a6b', '2045-BX', 'Home Appliance - Coffee Maker', 2.500),
('e3f4a5b6-c7d8-4e9f-0a1b-2c3d4e5f6a7b', '3087-CX', 'Furniture - Office Chair', 12.800),
('e4f5a6b7-c8d9-4e0f-1a2b-3c4d5e6f7a8b', '4012-DX', 'Clothing - Winter Jacket L', 0.850),
('e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8a9b', '5099-EX', 'Books - Technical Manual Set', 1.200),
('e6f7a8b9-c0d1-4e2f-3a4b-5c6d7e8f9a0b', '6034-FX', 'Sports - Yoga Mat Premium', 2.100),
('e7f8a9b0-c1d2-4e3f-4a5b-6c7d8e9f0a1b', '7088-GX', 'Kitchen - Utensils Set 12pc', 3.400),
('e8f9a0b1-c2d3-4e4f-5a6b-7c8d9e0f1a2b', '8021-HX', 'Tools - Power Drill Kit', 4.500)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 5. STOCK BALANCES
-- =====================================================
INSERT INTO public.stock_balances (sku_id, location_id, qty, version)
VALUES 
-- Storage locations
('e1f2a3b4-c5d6-4e7f-8a9b-0c1d2e3f4a5b', 'd2e3f4a5-b6c7-4d8e-9f0a-1b2c3d4e5f6a', 150, 1),
('e2f3a4b5-c6d7-4e8f-9a0b-1c2d3e4f5a6b', 'd2e3f4a5-b6c7-4d8e-9f0a-1b2c3d4e5f6a', 75, 1),
('e3f4a5b6-c7d8-4e9f-0a1b-2c3d4e5f6a7b', 'd3e4f5a6-b7c8-4d9e-0f1a-2b3c4d5e6f7a', 30, 1),
('e4f5a6b7-c8d9-4e0f-1a2b-3c4d5e6f7a8b', 'd3e4f5a6-b7c8-4d9e-0f1a-2b3c4d5e6f7a', 200, 1),
('e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8a9b', 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a', 95, 1),
-- Picking locations
('e1f2a3b4-c5d6-4e7f-8a9b-0c1d2e3f4a5b', 'd5e6f7a8-b9c0-4d1e-2f3a-4b5c6d7e8f9a', 25, 1),
('e2f3a4b5-c6d7-4e8f-9a0b-1c2d3e4f5a6b', 'd5e6f7a8-b9c0-4d1e-2f3a-4b5c6d7e8f9a', 15, 1)
ON CONFLICT (sku_id, location_id) DO UPDATE SET
  qty = EXCLUDED.qty,
  version = stock_balances.version + 1;

-- =====================================================
-- 6. CHARIOTS
-- =====================================================
INSERT INTO public.chariots (id, code, is_active, capacity)
VALUES 
('c1a2b3c4-d5e6-4f7a-8b9c-0d1e2f3a4b5c', 'C-04', true, 150),
('c2a3b4c5-d6e7-4f8a-9b0c-1d2e3f4a5b6c', 'C-09', true, 200),
('c3a4b5c6-d7e8-4f9a-0b1c-2d3e4f5a6b7c', 'C-12', true, 180)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 7. ROUTE PLANS
-- =====================================================
INSERT INTO public.route_plans (id, created_at, total_distance_meters, path_nodes_json)
VALUES 
('51a2b3c4-d5e6-4f7a-8b9c-0d1e2f3a4b5c', NOW(), 125.5, 
 '[
   {"x": 10, "y": 5, "floor_level": 1},
   {"x": 12, "y": 5, "floor_level": 1},
   {"x": 12, "y": 8, "floor_level": 2},
   {"x": 15, "y": 8, "floor_level": 3}
 ]'::jsonb),
('52a3b4c5-d6e7-4f8a-9b0c-1d2e3f4a5b6c', NOW(), 89.3,
 '[
   {"x": 5, "y": 3, "floor_level": 1},
   {"x": 8, "y": 6, "floor_level": 2},
   {"x": 10, "y": 8, "floor_level": 2}
 ]'::jsonb),
('53a4b5c6-d7e8-4f9a-0b1c-2d3e4f5a6b7c', NOW(), 156.8,
 '[
   {"x": 8, "y": 4, "floor_level": 3},
   {"x": 10, "y": 6, "floor_level": 2},
   {"x": 12, "y": 8, "floor_level": 1}
 ]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 8. DELIVERIES
-- =====================================================
INSERT INTO public.deliveries (delivery_id, status, created_at, updated_at)
VALUES 
(99283, 'IN_PROGRESS', NOW() - INTERVAL '2 hours', NOW()),
(99284, 'IDLE', NOW() - INTERVAL '1 hour', NOW()),
(99285, 'IDLE', NOW() - INTERVAL '30 minutes', NOW())
ON CONFLICT (delivery_id) DO NOTHING;

-- =====================================================
-- 9. ORDERS
-- =====================================================

-- Command Order (Receipt/Ingoing - INGOING ORDER #ING-9932)
INSERT INTO public.orders (id, type, status, created_at, created_by, validated_by, source, delivery_id)
VALUES 
('a1a1a1a1-9932-4000-8000-000000000001', 'COMMAND', 'VALIDATED', NOW() - INTERVAL '3 hours', 
 'c4e5f6a7-2345-6789-01bc-def123456789', 'c4e5f6a7-2345-6789-01bc-def123456789', 'AI', 99283)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.command_orders (order_id, reception_at)
VALUES 
('a1a1a1a1-9932-4000-8000-000000000001', NOW() - INTERVAL '2 hours')
ON CONFLICT (order_id) DO NOTHING;

-- Preparation Order (Outgoing)
INSERT INTO public.orders (id, type, status, created_at, created_by, source, delivery_id)
VALUES 
('b2b2b2b2-8845-4000-8000-000000000002', 'PREPARATION', 'VALIDATED', NOW() - INTERVAL '2 hours',
 'c4e5f6a7-2345-6789-01bc-def123456789', 'AI', 99284)
ON CONFLICT (id) DO NOTHING;

-- Picking Order (Outgoing)
INSERT INTO public.orders (id, type, status, created_at, created_by, source, delivery_id)
VALUES 
('c3c3c3c3-8851-4000-8000-000000000003', 'PICKING', 'VALIDATED', NOW() - INTERVAL '1 hour',
 'c4e5f6a7-2345-6789-01bc-def123456789', 'AI', 99284)
ON CONFLICT (id) DO NOTHING;

-- Delivery Order (Outgoing)
INSERT INTO public.orders (id, type, status, created_at, created_by, source, delivery_id)
VALUES 
('d4d4d4d4-8860-4000-8000-000000000004', 'DELIVERY', 'VALIDATED', NOW() - INTERVAL '30 minutes',
 'c4e5f6a7-2345-6789-01bc-def123456789', 'AI', 99285)
ON CONFLICT (id) DO NOTHING;

-- Another pending ingoing order
INSERT INTO public.orders (id, type, status, created_at, created_by, source)
VALUES 
('e5e5e5e5-8842-4000-8000-000000000005', 'COMMAND', 'VALIDATED', NOW() - INTERVAL '4 hours',
 'c4e5f6a7-2345-6789-01bc-def123456789', 'Manual')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.command_orders (order_id, reception_at)
VALUES 
('e5e5e5e5-8842-4000-8000-000000000005', NOW() - INTERVAL '3.5 hours')
ON CONFLICT (order_id) DO NOTHING;

-- =====================================================
-- 10. ORDER LINE ITEMS
-- =====================================================

-- Command Order #ING-9932 lines (12 items total)
INSERT INTO public.command_order_lines (id, command_order_id, sku_id, qty_received)
VALUES 
('11a2b3c4-d5e6-4f7a-8b9c-0d1e2f3a4b5c', 'a1a1a1a1-9932-4000-8000-000000000001', 'e1f2a3b4-c5d6-4e7f-8a9b-0c1d2e3f4a5b', 50),
('12a3b4c5-d6e7-4f8a-9b0c-1d2e3f4a5b6c', 'a1a1a1a1-9932-4000-8000-000000000001', 'e2f3a4b5-c6d7-4e8f-9a0b-1c2d3e4f5a6b', 30),
('13a4b5c6-d7e8-4f9a-0b1c-2d3e4f5a6b7c', 'a1a1a1a1-9932-4000-8000-000000000001', 'e3f4a5b6-c7d8-4e9f-0a1b-2c3d4e5f6a7b', 15),
('14a5b6c7-d8e9-4f0a-1b2c-3d4e5f6a7b8c', 'a1a1a1a1-9932-4000-8000-000000000001', 'e4f5a6b7-c8d9-4e0f-1a2b-3c4d5e6f7a8b', 75),
('15a6b7c8-d9e0-4f1a-2b3c-4d5e6f7a8b9c', 'a1a1a1a1-9932-4000-8000-000000000001', 'e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8a9b', 40),
('16a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c', 'a1a1a1a1-9932-4000-8000-000000000001', 'e6f7a8b9-c0d1-4e2f-3a4b-5c6d7e8f9a0b', 25),
('17a8b9c0-d1e2-4f3a-4b5c-6d7e8f9a0b1c', 'a1a1a1a1-9932-4000-8000-000000000001', 'e7f8a9b0-c1d2-4e3f-4a5b-6c7d8e9f0a1b', 35),
('18a9b0c1-d2e3-4f4a-5b6c-7d8e9f0a1b2c', 'a1a1a1a1-9932-4000-8000-000000000001', 'e8f9a0b1-c2d3-4e4f-5a6b-7c8d9e0f1a2b', 20),
('19a0b1c2-d3e4-4f5a-6b7c-8d9e0f1a2b3c', 'a1a1a1a1-9932-4000-8000-000000000001', 'e1f2a3b4-c5d6-4e7f-8a9b-0c1d2e3f4a5b', 45),
('10a1b2c3-d4e5-4f6a-7b8c-9d0e1f2a3b4c', 'a1a1a1a1-9932-4000-8000-000000000001', 'e2f3a4b5-c6d7-4e8f-9a0b-1c2d3e4f5a6b', 28),
('1aa2b3c4-d5e6-4f7a-8b9c-0d1e2f3a4b5d', 'a1a1a1a1-9932-4000-8000-000000000001', 'e4f5a6b7-c8d9-4e0f-1a2b-3c4d5e6f7a8b', 65),
('1ba3b4c5-d6e7-4f8a-9b0c-1d2e3f4a5b6d', 'a1a1a1a1-9932-4000-8000-000000000001', 'e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8a9b', 32)
ON CONFLICT (id) DO NOTHING;

-- Second ingoing order lines (4 items)
INSERT INTO public.command_order_lines (id, command_order_id, sku_id, qty_received)
VALUES 
('1ca4b5c6-d7e8-4f9a-0b1c-2d3e4f5a6b7d', 'e5e5e5e5-8842-4000-8000-000000000005', 'e1f2a3b4-c5d6-4e7f-8a9b-0c1d2e3f4a5b', 100),
('1da5b6c7-d8e9-4f0a-1b2c-3d4e5f6a7b8d', 'e5e5e5e5-8842-4000-8000-000000000005', 'e2f3a4b5-c6d7-4e8f-9a0b-1c2d3e4f5a6b', 85),
('1ea6b7c8-d9e0-4f1a-2b3c-4d5e6f7a8b9d', 'e5e5e5e5-8842-4000-8000-000000000005', 'e3f4a5b6-c7d8-4e9f-0a1b-2c3d4e5f6a7b', 60),
('1fa7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0d', 'e5e5e5e5-8842-4000-8000-000000000005', 'e4f5a6b7-c8d9-4e0f-1a2b-3c4d5e6f7a8b', 120)
ON CONFLICT (id) DO NOTHING;

-- Preparation order lines
INSERT INTO public.preparation_order_lines (id, preparation_order_id, sku_id, qty_to_deliver, current_storage_location_id)
VALUES 
('21a2b3c4-d5e6-4f7a-8b9c-0d1e2f3a4b5c', 'b2b2b2b2-8845-4000-8000-000000000002', 'e1f2a3b4-c5d6-4e7f-8a9b-0c1d2e3f4a5b', 30, 'd2e3f4a5-b6c7-4d8e-9f0a-1b2c3d4e5f6a'),
('22a3b4c5-d6e7-4f8a-9b0c-1d2e3f4a5b6c', 'b2b2b2b2-8845-4000-8000-000000000002', 'e2f3a4b5-c6d7-4e8f-9a0b-1c2d3e4f5a6b', 20, 'd2e3f4a5-b6c7-4d8e-9f0a-1b2c3d4e5f6a'),
('23a4b5c6-d7e8-4f9a-0b1c-2d3e4f5a6b7c', 'b2b2b2b2-8845-4000-8000-000000000002', 'e3f4a5b6-c7d8-4e9f-0a1b-2c3d4e5f6a7b', 10, 'd3e4f5a6-b7c8-4d9e-0f1a-2b3c4d5e6f7a')
ON CONFLICT (id) DO NOTHING;

-- Picking order lines
INSERT INTO public.picking_order_lines (id, picking_order_id, sku_id, qty_to_pick, source_storage_location_id, destination_picking_location_id)
VALUES 
('31a2b3c4-d5e6-4f7a-8b9c-0d1e2f3a4b5c', 'c3c3c3c3-8851-4000-8000-000000000003', 'e1f2a3b4-c5d6-4e7f-8a9b-0c1d2e3f4a5b', 25, 'd2e3f4a5-b6c7-4d8e-9f0a-1b2c3d4e5f6a', 'd5e6f7a8-b9c0-4d1e-2f3a-4b5c6d7e8f9a'),
('32a3b4c5-d6e7-4f8a-9b0c-1d2e3f4a5b6c', 'c3c3c3c3-8851-4000-8000-000000000003', 'e2f3a4b5-c6d7-4e8f-9a0b-1c2d3e4f5a6b', 15, 'd2e3f4a5-b6c7-4d8e-9f0a-1b2c3d4e5f6a', 'd5e6f7a8-b9c0-4d1e-2f3a-4b5c6d7e8f9a')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 11. OPERATION TASKS (Assigned to Employee)
-- =====================================================

-- INGOING TASK 1: Receipt Operation (Order #ING-9932) - IN PROGRESS
INSERT INTO public.operation_tasks 
(id, operation_type, status, order_id, delivery_id, assigned_to_user_id, chariot_id, planned_route_id, validated, created_at, completed_at)
VALUES 
('41a2b3c4-d5e6-4f7a-8b9c-0d1e2f3a4b5c', 'RECEIPT', 'IN_PROGRESS', 
 'a1a1a1a1-9932-4000-8000-000000000001', 99283, '30c64ceb-a1f3-43b9-8407-d6ceacbca7a8',
 'c1a2b3c4-d5e6-4f7a-8b9c-0d1e2f3a4b5c', '51a2b3c4-d5e6-4f7a-8b9c-0d1e2f3a4b5c', false,
 NOW() - INTERVAL '1 hour', NULL)
ON CONFLICT (id) DO NOTHING;

-- INGOING TASK 2: Another Receipt (PENDING)
INSERT INTO public.operation_tasks 
(id, operation_type, status, order_id, assigned_to_user_id, chariot_id, validated, created_at)
VALUES 
('42a3b4c5-d6e7-4f8a-9b0c-1d2e3f4a5b6c', 'RECEIPT', 'PENDING',
 'e5e5e5e5-8842-4000-8000-000000000005', '30c64ceb-a1f3-43b9-8407-d6ceacbca7a8',
 'c2a3b4c5-d6e7-4f8a-9b0c-1d2e3f4a5b6c', false, NOW() - INTERVAL '30 minutes')
ON CONFLICT (id) DO NOTHING;

-- OUTGOING TASK 1: Preparation (VALIDATED - DONE)
INSERT INTO public.operation_tasks 
(id, operation_type, status, order_id, delivery_id, assigned_to_user_id, chariot_id, planned_route_id, validated, created_at, completed_at)
VALUES 
('43a4b5c6-d7e8-4f9a-0b1c-2d3e4f5a6b7c', 'TRANSFER', 'DONE',
 'b2b2b2b2-8845-4000-8000-000000000002', 99284, '30c64ceb-a1f3-43b9-8407-d6ceacbca7a8',
 'c1a2b3c4-d5e6-4f7a-8b9c-0d1e2f3a4b5c', '52a3b4c5-d6e7-4f8a-9b0c-1d2e3f4a5b6c', true,
 NOW() - INTERVAL '3 hours', NOW() - INTERVAL '1 hour')
ON CONFLICT (id) DO NOTHING;

-- OUTGOING TASK 2: Picking (ASSIGNED)
INSERT INTO public.operation_tasks 
(id, operation_type, status, order_id, delivery_id, assigned_to_user_id, chariot_id, planned_route_id, validated, created_at)
VALUES 
('44a5b6c7-d8e9-4f0a-1b2c-3d4e5f6a7b8c', 'PICKING', 'ASSIGNED',
 'c3c3c3c3-8851-4000-8000-000000000003', 99284, '30c64ceb-a1f3-43b9-8407-d6ceacbca7a8',
 'c3a4b5c6-d7e8-4f9a-0b1c-2d3e4f5a6b7c', '53a4b5c6-d7e8-4f9a-0b1c-2d3e4f5a6b7c', false,
 NOW() - INTERVAL '45 minutes')
ON CONFLICT (id) DO NOTHING;

-- OUTGOING TASK 3: Delivery (IN_PROGRESS)
INSERT INTO public.operation_tasks 
(id, operation_type, status, order_id, delivery_id, assigned_to_user_id, validated, created_at)
VALUES 
('45a6b7c8-d9e0-4f1a-2b3c-4d5e6f7a8b9c', 'DELIVERY', 'IN_PROGRESS',
 'd4d4d4d4-8860-4000-8000-000000000004', 99285, '30c64ceb-a1f3-43b9-8407-d6ceacbca7a8',
 false, NOW() - INTERVAL '20 minutes')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 12. AUDIT LOGS (Issue Reports History)
-- =====================================================
INSERT INTO public.audit_logs (id, ts, actor_user_id, action_type, entity_type, entity_id, details)
VALUES 
('a1a2b3c4-d5e6-4f7a-8b9c-0d1e2f3a4b5c', NOW() - INTERVAL '2 days', 
 '30c64ceb-a1f3-43b9-8407-d6ceacbca7a8', 'ISSUE_REPORT', 'TASK', '41a2b3c4-d5e6-4f7a-8b9c-0d1e2f3a4b5c',
 '{"category": "DAMAGED_PRODUCTS", "description": "Found 5 damaged items during inspection", "status": "RESOLVED"}'::jsonb),
('a2a3b4c5-d6e7-4f8a-9b0c-1d2e3f4a5b6c', NOW() - INTERVAL '1 day',
 '30c64ceb-a1f3-43b9-8407-d6ceacbca7a8', 'TASK_COMPLETED', 'TASK', '43a4b5c6-d7e8-4f9a-0b1c-2d3e4f5a6b7c',
 '{"completion_time": "45 minutes", "items_processed": 60}'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- Summary of Generated Data
-- =====================================================
-- 
-- Employee: Alex Johnson (30c64ceb-a1f3-43b9-8407-d6ceacbca7a8)
-- Email: employee@test.com
-- 
-- TASKS ASSIGNED:
-- 1. INGOING (Receipt):
--    - Order #ING-9932 (IN_PROGRESS) - 12 items
--    - Order #ORD-8842 (PENDING) - 24 items
--
-- 2. OUTGOING:
--    - Preparation #8845 (DONE/VALIDATED) - 8 items
--    - Picking #8851 (ASSIGNED) - 24 items  
--    - Delivery #8860 (IN_PROGRESS) - 5 items
--
-- Total: 5 tasks (2 ingoing, 3 outgoing)
-- Completed: 1 task (20% completion rate)
-- =====================================================

-- ✅ User already exists in Supabase Auth
-- Email: employee@test.com
-- ID: 30c64ceb-a1f3-43b9-8407-d6ceacbca7a8
--
-- To use: Simply run this SQL script in Supabase SQL Editor
