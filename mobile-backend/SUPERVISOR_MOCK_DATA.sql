-- =====================================================
-- MOCK DATA FOR SUPERVISOR FEATURE  
-- USES ONLY EXISTING TABLES - NO NEW TABLES CREATED!
-- =====================================================

-- Run this in Supabase SQL Editor to populate test data
-- All data uses existing table structure

-- =====================================================
-- 1. Deliveries (Bon de Livraison)
-- =====================================================
DO $$
DECLARE
    v_delivery_id_1 bigint;
    v_delivery_id_2 bigint;
    v_delivery_id_3 bigint;
BEGIN
    INSERT INTO deliveries (status) VALUES ('IDLE') RETURNING delivery_id INTO v_delivery_id_1;
    INSERT INTO deliveries (status) VALUES ('IN_PROGRESS') RETURNING delivery_id INTO v_delivery_id_2;
    INSERT INTO deliveries (status) VALUES ('DONE') RETURNING delivery_id INTO v_delivery_id_3;
    
    RAISE NOTICE 'Created deliveries: %, %, %', v_delivery_id_1, v_delivery_id_2, v_delivery_id_3;
END $$;

-- =====================================================
-- 2. Command Orders (Bon de Commande) - Reception
-- =====================================================
DO $$
DECLARE
    v_user_id uuid;
    v_order_id_1 uuid;
    v_order_id_2 uuid;
    v_sku_id_1 uuid;
    v_sku_id_2 uuid;
    v_sku_id_3 uuid;
    v_reception_loc uuid;
BEGIN
    -- Get first user
    SELECT id INTO v_user_id FROM users LIMIT 1;
    
    -- Get first 3 SKUs
    SELECT id INTO v_sku_id_1 FROM skus LIMIT 1 OFFSET 0;
    SELECT id INTO v_sku_id_2 FROM skus LIMIT 1 OFFSET 1;
    SELECT id INTO v_sku_id_3 FROM skus LIMIT 1 OFFSET 2;
    
    -- Get reception location (any location)
    SELECT id INTO v_reception_loc FROM locations ORDER BY code LIMIT 1;
    
    IF v_user_id IS NOT NULL AND v_sku_id_1 IS NOT NULL AND v_reception_loc IS NOT NULL THEN
        -- Create command orders
        INSERT INTO orders (type, status, source, created_by)
        VALUES ('COMMAND', 'VALIDATED', 'Supplier ABC', v_user_id)
        RETURNING id INTO v_order_id_1;
        
        INSERT INTO orders (type, status, source, created_by)
        VALUES ('COMMAND', 'DRAFT', 'Supplier XYZ', v_user_id)
        RETURNING id INTO v_order_id_2;
        
        -- Link to command_orders table
        INSERT INTO command_orders (order_id, reception_at)
        VALUES 
            (v_order_id_1, NOW() - INTERVAL '2 hours'),
            (v_order_id_2, NOW() - INTERVAL '1 hour');
        
        -- Product lines (stock_ledger_entries with operation_type='RECEIPT')
        INSERT INTO stock_ledger_entries 
        (sku_id, to_location_id, qty_delta, operation_type, order_id, user_id, idempotency_key, ts)
        VALUES
            (v_sku_id_1, v_reception_loc, 50, 'RECEIPT', v_order_id_1, v_user_id, 
             'cmd-line-' || gen_random_uuid()::text, NOW() - INTERVAL '2 hours'),
            (v_sku_id_2, v_reception_loc, 30, 'RECEIPT', v_order_id_1, v_user_id,
             'cmd-line-' || gen_random_uuid()::text, NOW() - INTERVAL '2 hours'),
            (v_sku_id_3, v_reception_loc, 75, 'RECEIPT', v_order_id_2, v_user_id,
             'cmd-line-' || gen_random_uuid()::text, NOW() - INTERVAL '1 hour');
        
        RAISE NOTICE 'Created command orders: %, %', v_order_id_1, v_order_id_2;
    END IF;
END $$;

-- =====================================================
-- 3. Storage Tasks (operation_tasks with operation_type='TRANSFER')
-- =====================================================
DO $$
DECLARE
    v_order_id uuid;
    v_sku_id uuid;
    v_user_id uuid;
    v_chariot_id uuid;
    v_reception_loc uuid;
    v_storage_loc uuid;
    v_task_id_1 uuid;
    v_task_id_2 uuid;
    v_task_id_3 uuid;
BEGIN
    SELECT id INTO v_order_id FROM orders WHERE type = 'COMMAND' LIMIT 1;
    SELECT id INTO v_sku_id FROM skus LIMIT 1;
    SELECT id INTO v_user_id FROM users LIMIT 1;
    SELECT id INTO v_chariot_id FROM chariots WHERE is_active = true LIMIT 1;
    SELECT id INTO v_reception_loc FROM locations ORDER BY code LIMIT 1 OFFSET 0;
    SELECT id INTO v_storage_loc FROM locations ORDER BY code LIMIT 1 OFFSET 1;
    
    IF v_order_id IS NOT NULL AND v_storage_loc IS NOT NULL THEN
        -- Create storage tasks
        INSERT INTO operation_tasks 
        (operation_type, status, order_id, assigned_to_user_id, chariot_id, created_at)
        VALUES 
            ('TRANSFER', 'PENDING', v_order_id, NULL, NULL, NOW() - INTERVAL '30 minutes')
        RETURNING id INTO v_task_id_1;
        
        INSERT INTO operation_tasks
        (operation_type, status, order_id, assigned_to_user_id, chariot_id, created_at)
        VALUES
            ('TRANSFER', 'IN_PROGRESS', v_order_id, v_user_id, v_chariot_id, NOW() - INTERVAL '15 minutes')
        RETURNING id INTO v_task_id_2;
        
        INSERT INTO operation_tasks
        (operation_type, status, order_id, assigned_to_user_id, chariot_id, created_at, completed_at)
        VALUES
            ('TRANSFER', 'DONE', v_order_id, v_user_id, v_chariot_id, 
             NOW() - INTERVAL '1 hour', NOW() - INTERVAL '30 minutes')
        RETURNING id INTO v_task_id_3;
        
        -- Create stock movement for completed task
        INSERT INTO stock_ledger_entries
        (sku_id, from_location_id, to_location_id, qty_delta, operation_type, task_id, user_id, idempotency_key, ts)
        VALUES
            (v_sku_id, v_reception_loc, v_storage_loc, 20, 'TRANSFER', v_task_id_3, v_user_id,
             'storage-move-' || gen_random_uuid()::text, NOW() - INTERVAL '30 minutes');
        
        RAISE NOTICE 'Created storage tasks: %, %, %', v_task_id_1, v_task_id_2, v_task_id_3;
    END IF;
END $$;

-- =====================================================
-- 4. AI Recommendations (storage optimization)
-- =====================================================
DO $$
DECLARE
    v_order_id uuid;
    v_storage_loc uuid;
BEGIN
    SELECT id INTO v_order_id FROM orders WHERE type = 'COMMAND' LIMIT 1;
    SELECT id INTO v_storage_loc FROM locations ORDER BY code LIMIT 1 OFFSET 2;
    
    IF v_order_id IS NOT NULL AND v_storage_loc IS NOT NULL THEN
        INSERT INTO ai_recommendations (type, payload_json, order_id, created_at)
        VALUES (
            'STORAGE_ASSIGNMENT',
            jsonb_build_object(
                'assigned_slot', 'B01-N2-A05',
                'location_id', v_storage_loc,
                'floor', 2,
                'zone', 'A',
                'abc_class', 'A',
                'score', 0.92,
                'distance_meters', 45.5,
                'estimated_time_seconds', 90,
                'path', jsonb_build_array(
                    jsonb_build_array(8, 8),
                    jsonb_build_array(9, 8),
                    jsonb_build_array(10, 8)
                )
            ),
            v_order_id,
            NOW() - INTERVAL '45 minutes'
        );
        
        RAISE NOTICE 'Created AI storage recommendation';
    END IF;
END $$;

-- =====================================================
-- 5. Preparation Orders (Bon de Préparation)
-- =====================================================
DO $$
DECLARE
    v_delivery_id bigint;
    v_user_id uuid;
    v_prep_order_id_1 uuid;
    v_prep_order_id_2 uuid;
    v_sku_id_1 uuid;
    v_sku_id_2 uuid;
    v_storage_loc uuid;
    v_picking_loc uuid;
BEGIN
    SELECT delivery_id INTO v_delivery_id FROM deliveries WHERE status = 'IN_PROGRESS' LIMIT 1;
    SELECT id INTO v_user_id FROM users LIMIT 1;
    SELECT id INTO v_sku_id_1 FROM skus LIMIT 1 OFFSET 0;
    SELECT id INTO v_sku_id_2 FROM skus LIMIT 1 OFFSET 1;
    SELECT id INTO v_storage_loc FROM locations ORDER BY code LIMIT 1 OFFSET 3;
    SELECT id INTO v_picking_loc FROM locations ORDER BY code LIMIT 1 OFFSET 4;
    
    IF v_delivery_id IS NOT NULL AND v_picking_loc IS NOT NULL THEN
        -- Create preparation orders
        INSERT INTO orders (type, status, source, delivery_id, created_by, created_at)
        VALUES ('PREPARATION', 'IN_PROGRESS', 'Client Test A', v_delivery_id, v_user_id, NOW() - INTERVAL '3 hours')
        RETURNING id INTO v_prep_order_id_1;
        
        INSERT INTO orders (type, status, source, delivery_id, created_by, created_at)
        VALUES ('PREPARATION', 'DRAFT', 'Client Test B', v_delivery_id, v_user_id, NOW() - INTERVAL '1 hour')
        RETURNING id INTO v_prep_order_id_2;
        
        -- Preparation items (stock movements from storage to picking zone)
        INSERT INTO stock_ledger_entries
        (sku_id, from_location_id, to_location_id, qty_delta, operation_type, order_id, user_id, idempotency_key, ts)
        VALUES
            (v_sku_id_1, v_storage_loc, v_picking_loc, 15, 'PICKING', v_prep_order_id_1, v_user_id,
             'prep-item-' || gen_random_uuid()::text, NOW() - INTERVAL '2 hours 30 minutes'),
            (v_sku_id_2, v_storage_loc, v_picking_loc, 20, 'PICKING', v_prep_order_id_1, v_user_id,
             'prep-item-' || gen_random_uuid()::text, NOW() - INTERVAL '2 hours 15 minutes'),
            (v_sku_id_1, v_storage_loc, v_picking_loc, 10, 'PICKING', v_prep_order_id_2, v_user_id,
             'prep-item-' || gen_random_uuid()::text, NOW() - INTERVAL '45 minutes');
        
        RAISE NOTICE 'Created preparation orders: %, %', v_prep_order_id_1, v_prep_order_id_2;
    END IF;
END $$;

-- =====================================================
-- 6. Picking Tasks (Bon de Picking)
-- =====================================================
DO $$
DECLARE
    v_delivery_id bigint;
    v_user_id uuid;
    v_chariot_id uuid;
    v_picking_loc uuid;
    v_expedition_loc uuid;
    v_task_id_1 uuid;
    v_task_id_2 uuid;
    v_route_id uuid;
    v_sku_id uuid;
BEGIN
    SELECT delivery_id INTO v_delivery_id FROM deliveries WHERE status = 'IN_PROGRESS' LIMIT 1;
    SELECT id INTO v_user_id FROM users LIMIT 1;
    SELECT id INTO v_chariot_id FROM chariots WHERE is_active = true LIMIT 1;
    SELECT id INTO v_picking_loc FROM locations ORDER BY code LIMIT 1 OFFSET 5;
    SELECT id INTO v_expedition_loc FROM locations ORDER BY code LIMIT 1 OFFSET 6;
    SELECT id INTO v_sku_id FROM skus LIMIT 1;
    
    IF v_delivery_id IS NOT NULL AND v_expedition_loc IS NOT NULL THEN
        -- Create route plan
        INSERT INTO route_plans (total_distance_meters, path_nodes_json, created_at)
        VALUES (
            287.5,
            jsonb_build_array(
                jsonb_build_object('floor', 1, 'x', 10, 'y', 20, 'location_id', v_picking_loc),
                jsonb_build_object('floor', 1, 'x', 15, 'y', 25, 'location_id', v_picking_loc),
                jsonb_build_object('floor', 1, 'x', 20, 'y', 30, 'location_id', v_expedition_loc)
            ),
            NOW() - INTERVAL '1 hour'
        )
        RETURNING id INTO v_route_id;
        
        -- Create picking tasks
        INSERT INTO operation_tasks
        (operation_type, status, delivery_id, assigned_to_user_id, chariot_id, planned_route_id, created_at)
        VALUES
            ('PICKING', 'IN_PROGRESS', v_delivery_id, v_user_id, v_chariot_id, v_route_id, NOW() - INTERVAL '45 minutes')
        RETURNING id INTO v_task_id_1;
        
        INSERT INTO operation_tasks
        (operation_type, status, delivery_id, planned_route_id, created_at)
        VALUES
            ('PICKING', 'PENDING', v_delivery_id, v_route_id, NOW() - INTERVAL '20 minutes')
        RETURNING id INTO v_task_id_2;
        
        -- Picking movements (from picking zone to expedition)
        INSERT INTO stock_ledger_entries
        (sku_id, from_location_id, to_location_id, qty_delta, operation_type, task_id, user_id, idempotency_key, ts)
        VALUES
            (v_sku_id, v_picking_loc, v_expedition_loc, 15, 'PICKING', v_task_id_1, v_user_id,
             'pick-item-' || gen_random_uuid()::text, NOW() - INTERVAL '30 minutes');
        
        RAISE NOTICE 'Created picking tasks: %, %', v_task_id_1, v_task_id_2;
    END IF;
END $$;

-- =====================================================
-- 7. AI Picking Route Recommendations
-- =====================================================
DO $$
DECLARE
    v_delivery_id bigint;
BEGIN
    SELECT delivery_id INTO v_delivery_id FROM deliveries WHERE status = 'IDLE' LIMIT 1;
    
    IF v_delivery_id IS NOT NULL THEN
        INSERT INTO ai_recommendations (type, payload_json, delivery_id, created_at)
        VALUES (
            'PICK_ROUTE',
            jsonb_build_object(
                'route', jsonb_build_array(
                    jsonb_build_object('step', 1, 'sku', 'SKU-001', 'location', 'B01-N2-A05', 'quantity', 10),
                    jsonb_build_object('step', 2, 'sku', 'SKU-002', 'location', 'B01-N2-B12', 'quantity', 5),
                    jsonb_build_object('step', 3, 'sku', 'SKU-003', 'location', 'B01-N3-C08', 'quantity', 8)
                ),
                'total_distance_meters', 287.5,
                'estimated_time_seconds', 480,
                'optimization_score', 0.94
            ),
            v_delivery_id,
            NOW() - INTERVAL '30 minutes'
        );
        
        RAISE NOTICE 'Created AI picking route recommendation';
    END IF;
END $$;

-- =====================================================
-- 8. Operational Alerts (ai_recommendations with type='FORECAST' for alerts)
-- =====================================================
DO $$
DECLARE
    v_sku_id uuid;
    v_storage_loc uuid;
    v_task_id uuid;
BEGIN
    SELECT id INTO v_sku_id FROM skus LIMIT 1;
    SELECT id INTO v_storage_loc FROM locations ORDER BY code LIMIT 1 OFFSET 7;
    SELECT id INTO v_task_id FROM operation_tasks WHERE status = 'PENDING' LIMIT 1;
    
    -- Low stock alert
    INSERT INTO ai_recommendations (type, payload_json, created_at)
    VALUES (
        'FORECAST',
        jsonb_build_object(
            'alert_type', 'LOW_STOCK',
            'priority', 'HIGH',
            'title', 'Low Stock Alert',
            'description', 'SKU ABC123 is below minimum threshold (5 units remaining)',
            'sku_id', v_sku_id,
            'location_id', v_storage_loc,
            'current_qty', 5,
            'threshold', 10
        ),
        NOW() - INTERVAL '1 hour'
    );
    
    -- Task delay alert
    IF v_task_id IS NOT NULL THEN
        INSERT INTO ai_recommendations (type, payload_json, task_id, created_at)
        VALUES (
            'FORECAST',
            jsonb_build_object(
                'alert_type', 'TASK_DELAY',
                'priority', 'MEDIUM',
                'title', 'Picking Task Delayed',
                'description', 'Task is 30 minutes overdue',
                'task_id', v_task_id,
                'delay_minutes', 30
            ),
            v_task_id,
            NOW() - INTERVAL '30 minutes'
        );
    END IF;
    
    RAISE NOTICE 'Created operational alerts';
END $$;

-- =====================================================
-- 9. Override Decisions (human overrides AI)
-- =====================================================
DO $$
DECLARE
    v_recommendation_id uuid;
    v_user_id uuid;
BEGIN
    SELECT id INTO v_recommendation_id FROM ai_recommendations WHERE type = 'STORAGE_ASSIGNMENT' LIMIT 1;
    SELECT id INTO v_user_id FROM users LIMIT 1;
    
    IF v_recommendation_id IS NOT NULL AND v_user_id IS NOT NULL THEN
        INSERT INTO override_decisions 
        (recommendation_id, status, overridden_by_user_id, justification, final_payload_json, created_at)
        VALUES (
            v_recommendation_id,
            'OVERRIDDEN',
            v_user_id,
            'Storage location is currently blocked for maintenance',
            jsonb_build_object(
                'assigned_slot', 'B01-N2-A12',
                'original_slot', 'B01-N2-A05',
                'reason', 'Maintenance'
            ),
            NOW() - INTERVAL '20 minutes'
        )
        ON CONFLICT (recommendation_id) DO NOTHING;
        
        RAISE NOTICE 'Created override decision';
    END IF;
END $$;

-- =====================================================
-- 10. Audit Logs (track all actions)
-- =====================================================
DO $$
DECLARE
    v_user_id uuid;
    v_order_id uuid;
    v_task_id uuid;
BEGIN
    SELECT id INTO v_user_id FROM users LIMIT 1;
    SELECT id INTO v_order_id FROM orders LIMIT 1;
    SELECT id INTO v_task_id FROM operation_tasks LIMIT 1;
    
    IF v_user_id IS NOT NULL THEN
        INSERT INTO audit_logs (actor_user_id, action_type, entity_type, entity_id, details, ts)
        VALUES
            (v_user_id, 'CREATE', 'orders', v_order_id::text, 
             jsonb_build_object('type', 'COMMAND', 'source', 'Supplier ABC'), NOW() - INTERVAL '2 hours'),
            (v_user_id, 'UPDATE', 'operation_tasks', v_task_id::text,
             jsonb_build_object('status', 'IN_PROGRESS'), NOW() - INTERVAL '1 hour'),
            (v_user_id, 'COMPLETE', 'operation_tasks', v_task_id::text,
             jsonb_build_object('status', 'DONE', 'duration_minutes', 45), NOW() - INTERVAL '30 minutes');
        
        RAISE NOTICE 'Created audit log entries';
    END IF;
END $$;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check deliveries
SELECT COUNT(*) as deliveries FROM deliveries;

-- Check command orders
SELECT COUNT(*) as command_orders FROM orders WHERE type = 'COMMAND';
SELECT COUNT(*) as command_order_lines FROM stock_ledger_entries WHERE operation_type = 'RECEIPT';

-- Check storage tasks
SELECT COUNT(*) as storage_tasks FROM operation_tasks WHERE operation_type = 'TRANSFER';

-- Check preparation orders
SELECT COUNT(*) as preparation_orders FROM orders WHERE type = 'PREPARATION';
SELECT COUNT(*) as preparation_items FROM stock_ledger_entries WHERE operation_type = 'PICKING';

-- Check picking tasks
SELECT COUNT(*) as picking_tasks FROM operation_tasks WHERE operation_type = 'PICKING';

-- Check AI recommendations
SELECT COUNT(*) as ai_recommendations FROM ai_recommendations;
SELECT type, COUNT(*) FROM ai_recommendations GROUP BY type;

-- Check override decisions
SELECT COUNT(*) as override_decisions FROM override_decisions;

-- Check audit logs
SELECT COUNT(*) as audit_logs FROM audit_logs WHERE DATE(ts) = CURRENT_DATE;

-- Sample queries to view data
SELECT * FROM deliveries ORDER BY created_at DESC LIMIT 5;
SELECT * FROM orders WHERE type = 'COMMAND' ORDER BY created_at DESC LIMIT 5;
SELECT * FROM operation_tasks ORDER BY created_at DESC LIMIT 10;
SELECT * FROM ai_recommendations ORDER BY created_at DESC LIMIT 5;
