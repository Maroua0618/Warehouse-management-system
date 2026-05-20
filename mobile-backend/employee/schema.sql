-- =====================================================
-- Database Schema for Employee Mobile App
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. USERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'ACTIVE',
    role TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT users_status_check CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    CONSTRAINT users_role_check CHECK (role IN ('EMPLOYEE', 'SUPERVISOR', 'ADMIN'))
);

-- =====================================================
-- 2. WAREHOUSES
-- =====================================================
CREATE TABLE IF NOT EXISTS public.warehouses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 3. FLOORS
-- =====================================================
CREATE TABLE IF NOT EXISTS public.floors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    warehouse_id UUID NOT NULL REFERENCES public.warehouses(id) ON DELETE CASCADE,
    level INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(warehouse_id, level)
);

-- =====================================================
-- 4. LOCATIONS
-- =====================================================
CREATE TABLE IF NOT EXISTS public.locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    floor_id UUID NOT NULL REFERENCES public.floors(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    type TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT locations_type_check CHECK (type IN ('RECEPTION', 'STORAGE', 'PICKING', 'EXPEDITION'))
);

-- =====================================================
-- 5. STORAGE LOCATIONS
-- =====================================================
CREATE TABLE IF NOT EXISTS public.storage_locations (
    location_id UUID PRIMARY KEY REFERENCES public.locations(id) ON DELETE CASCADE,
    level INTEGER NOT NULL,
    slot_code TEXT NOT NULL,
    area_m2 NUMERIC(10, 2),
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 6. PICKING LOCATIONS
-- =====================================================
CREATE TABLE IF NOT EXISTS public.picking_locations (
    location_id UUID PRIMARY KEY REFERENCES public.locations(id) ON DELETE CASCADE,
    row INTEGER NOT NULL,
    col INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 7. SKUS (Products)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.skus (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sku_code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    weight_kg NUMERIC(10, 3),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 8. STOCK BALANCES
-- =====================================================
CREATE TABLE IF NOT EXISTS public.stock_balances (
    sku_id UUID NOT NULL REFERENCES public.skus(id) ON DELETE CASCADE,
    location_id UUID NOT NULL REFERENCES public.locations(id) ON DELETE CASCADE,
    qty INTEGER NOT NULL DEFAULT 0,
    version INTEGER NOT NULL DEFAULT 1,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (sku_id, location_id),
    CONSTRAINT stock_balances_qty_check CHECK (qty >= 0)
);

-- =====================================================
-- 9. CHARIOTS
-- =====================================================
CREATE TABLE IF NOT EXISTS public.chariots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT true,
    capacity INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 10. ROUTE PLANS
-- =====================================================
CREATE TABLE IF NOT EXISTS public.route_plans (
    id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    total_distance_meters NUMERIC(10, 2) NOT NULL,
    path_nodes_json JSONB NOT NULL
);

-- =====================================================
-- 11. DELIVERIES
-- =====================================================
CREATE TABLE IF NOT EXISTS public.deliveries (
    delivery_id INTEGER PRIMARY KEY,
    status TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT deliveries_status_check CHECK (status IN ('IDLE', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'))
);

-- =====================================================
-- 12. ORDERS
-- =====================================================
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type TEXT NOT NULL,
    status TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES public.users(id),
    validated_by UUID REFERENCES public.users(id),
    source TEXT,
    delivery_id INTEGER REFERENCES public.deliveries(delivery_id),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT orders_type_check CHECK (type IN ('COMMAND', 'PREPARATION', 'PICKING', 'DELIVERY')),
    CONSTRAINT orders_status_check CHECK (status IN ('DRAFT', 'PENDING', 'VALIDATED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    CONSTRAINT orders_source_check CHECK (source IN ('Manual', 'AI'))
);

-- =====================================================
-- 13. COMMAND ORDERS (Receipt/Ingoing)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.command_orders (
    order_id UUID PRIMARY KEY REFERENCES public.orders(id) ON DELETE CASCADE,
    reception_at TIMESTAMPTZ NOT NULL
);

-- =====================================================
-- 14. COMMAND ORDER LINES
-- =====================================================
CREATE TABLE IF NOT EXISTS public.command_order_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    command_order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    sku_id UUID NOT NULL REFERENCES public.skus(id),
    qty_received INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT command_order_lines_qty_check CHECK (qty_received > 0)
);

-- =====================================================
-- 15. PREPARATION ORDER LINES
-- =====================================================
CREATE TABLE IF NOT EXISTS public.preparation_order_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    preparation_order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    sku_id UUID NOT NULL REFERENCES public.skus(id),
    qty_to_deliver INTEGER NOT NULL,
    current_storage_location_id UUID REFERENCES public.locations(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT preparation_order_lines_qty_check CHECK (qty_to_deliver > 0)
);

-- =====================================================
-- 16. PICKING ORDER LINES
-- =====================================================
CREATE TABLE IF NOT EXISTS public.picking_order_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    picking_order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    sku_id UUID NOT NULL REFERENCES public.skus(id),
    qty_to_pick INTEGER NOT NULL,
    source_storage_location_id UUID REFERENCES public.locations(id),
    destination_picking_location_id UUID REFERENCES public.locations(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT picking_order_lines_qty_check CHECK (qty_to_pick > 0)
);

-- =====================================================
-- 17. OPERATION TASKS
-- =====================================================
CREATE TABLE IF NOT EXISTS public.operation_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    operation_type TEXT NOT NULL,
    status TEXT NOT NULL,
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    delivery_id INTEGER REFERENCES public.deliveries(delivery_id),
    assigned_to_user_id UUID REFERENCES public.users(id),
    chariot_id UUID REFERENCES public.chariots(id),
    planned_route_id BIGINT REFERENCES public.route_plans(id),
    validated BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT operation_tasks_type_check CHECK (operation_type IN ('RECEIPT', 'TRANSFER', 'PICKING', 'DELIVERY')),
    CONSTRAINT operation_tasks_status_check CHECK (status IN ('PENDING', 'ASSIGNED', 'IN_PROGRESS', 'DONE', 'CANCELLED'))
);

-- =====================================================
-- 18. AUDIT LOGS
-- =====================================================
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ts TIMESTAMPTZ DEFAULT NOW(),
    actor_user_id UUID REFERENCES public.users(id),
    action_type TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    details JSONB,
    CONSTRAINT audit_logs_action_check CHECK (action_type IN ('ISSUE_REPORT', 'TASK_COMPLETED', 'TASK_STARTED', 'STATUS_CHANGED', 'DATA_VALIDATED'))
);

-- =====================================================
-- INDEXES for Performance
-- =====================================================

-- Users
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);

-- Floors
CREATE INDEX IF NOT EXISTS idx_floors_warehouse ON public.floors(warehouse_id);

-- Locations
CREATE INDEX IF NOT EXISTS idx_locations_floor ON public.locations(floor_id);
CREATE INDEX IF NOT EXISTS idx_locations_type ON public.locations(type);

-- Stock Balances
CREATE INDEX IF NOT EXISTS idx_stock_sku ON public.stock_balances(sku_id);
CREATE INDEX IF NOT EXISTS idx_stock_location ON public.stock_balances(location_id);

-- Orders
CREATE INDEX IF NOT EXISTS idx_orders_type ON public.orders(type);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_delivery ON public.orders(delivery_id);

-- Command Order Lines
CREATE INDEX IF NOT EXISTS idx_command_lines_order ON public.command_order_lines(command_order_id);

-- Preparation Order Lines
CREATE INDEX IF NOT EXISTS idx_prep_lines_order ON public.preparation_order_lines(preparation_order_id);

-- Picking Order Lines
CREATE INDEX IF NOT EXISTS idx_pick_lines_order ON public.picking_order_lines(picking_order_id);

-- Operation Tasks
CREATE INDEX IF NOT EXISTS idx_tasks_assigned ON public.operation_tasks(assigned_to_user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON public.operation_tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_order ON public.operation_tasks(order_id);

-- Audit Logs
CREATE INDEX IF NOT EXISTS idx_audit_actor ON public.audit_logs(actor_user_id);
CREATE INDEX IF NOT EXISTS idx_audit_entity ON public.audit_logs(entity_type, entity_id);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) Policies
-- =====================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Authenticated users can view warehouses" ON public.warehouses;
DROP POLICY IF EXISTS "Authenticated users can view floors" ON public.floors;
DROP POLICY IF EXISTS "Authenticated users can view locations" ON public.locations;
DROP POLICY IF EXISTS "Authenticated users can view storage locations" ON public.storage_locations;
DROP POLICY IF EXISTS "Authenticated users can view picking locations" ON public.picking_locations;
DROP POLICY IF EXISTS "Authenticated users can view SKUs" ON public.skus;
DROP POLICY IF EXISTS "Authenticated users can view stock" ON public.stock_balances;
DROP POLICY IF EXISTS "Authenticated users can view chariots" ON public.chariots;
DROP POLICY IF EXISTS "Authenticated users can view routes" ON public.route_plans;
DROP POLICY IF EXISTS "Authenticated users can view deliveries" ON public.deliveries;
DROP POLICY IF EXISTS "Authenticated users can view orders" ON public.orders;
DROP POLICY IF EXISTS "Authenticated users can view command orders" ON public.command_orders;
DROP POLICY IF EXISTS "Authenticated users can view command lines" ON public.command_order_lines;
DROP POLICY IF EXISTS "Authenticated users can view preparation lines" ON public.preparation_order_lines;
DROP POLICY IF EXISTS "Authenticated users can view picking lines" ON public.picking_order_lines;
DROP POLICY IF EXISTS "Users can view assigned tasks" ON public.operation_tasks;
DROP POLICY IF EXISTS "Users can update assigned tasks" ON public.operation_tasks;
DROP POLICY IF EXISTS "Users can view own audit logs" ON public.audit_logs;
DROP POLICY IF EXISTS "Users can insert audit logs" ON public.audit_logs;

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.warehouses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.floors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.storage_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.picking_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.skus ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_balances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chariots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.route_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.command_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.command_order_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.preparation_order_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.picking_order_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.operation_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

-- Users can view all warehouse data (read-only for employees)
CREATE POLICY "Authenticated users can view warehouses" ON public.warehouses
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view floors" ON public.floors
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view locations" ON public.locations
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view storage locations" ON public.storage_locations
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view picking locations" ON public.picking_locations
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view SKUs" ON public.skus
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view stock" ON public.stock_balances
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view chariots" ON public.chariots
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view routes" ON public.route_plans
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view deliveries" ON public.deliveries
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view orders" ON public.orders
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view command orders" ON public.command_orders
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view command lines" ON public.command_order_lines
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view preparation lines" ON public.preparation_order_lines
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view picking lines" ON public.picking_order_lines
    FOR SELECT USING (auth.role() = 'authenticated');

-- Users can view their assigned tasks
CREATE POLICY "Users can view assigned tasks" ON public.operation_tasks
    FOR SELECT USING (auth.uid() = assigned_to_user_id);

-- Users can update their assigned tasks
CREATE POLICY "Users can update assigned tasks" ON public.operation_tasks
    FOR UPDATE USING (auth.uid() = assigned_to_user_id);

-- Users can view their own audit logs
CREATE POLICY "Users can view own audit logs" ON public.audit_logs
    FOR SELECT USING (auth.uid() = actor_user_id);

-- Users can insert their own audit logs
CREATE POLICY "Users can insert audit logs" ON public.audit_logs
    FOR INSERT WITH CHECK (auth.uid() = actor_user_id);

-- =====================================================
-- TRIGGERS for updated_at
-- =====================================================

-- Drop ALL existing triggers (including any old INSERT/UPDATE variants)
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TRIGGER IF EXISTS update_' || r.tablename || '_updated_at ON public.' || r.tablename;
    END LOOP;
END $$;

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Create a defensive trigger function that checks if updated_at exists
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    -- Only update if the column actually exists
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = TG_TABLE_SCHEMA 
        AND table_name = TG_TABLE_NAME 
        AND column_name = 'updated_at'
    ) THEN
        NEW.updated_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Only create triggers for tables that have updated_at column
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_warehouses_updated_at BEFORE UPDATE ON public.warehouses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_locations_updated_at BEFORE UPDATE ON public.locations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_skus_updated_at BEFORE UPDATE ON public.skus
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_stock_balances_updated_at BEFORE UPDATE ON public.stock_balances
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chariots_updated_at BEFORE UPDATE ON public.chariots
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_deliveries_updated_at BEFORE UPDATE ON public.deliveries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_operation_tasks_updated_at BEFORE UPDATE ON public.operation_tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- COMPLETION MESSAGE
-- =====================================================
-- Schema created successfully!
-- Next step: Run mock_data.sql to populate with test data
