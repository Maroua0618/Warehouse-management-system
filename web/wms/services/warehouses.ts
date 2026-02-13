import { createClient } from "@/lib/supabase/server";
import type { Tables, TablesInsert, TablesUpdate } from "@/types/database";

// ─── Types ───────────────────────────────────────────────
export type Warehouse = Tables<"warehouses">;
export type WarehouseInsert = TablesInsert<"warehouses">;
export type WarehouseUpdate = TablesUpdate<"warehouses">;

// ─── Warehouse with hierarchy summary ────────────────────
export type WarehouseWithSummary = Warehouse & {
  floors_count: number;
  locations_count: number;
};

// ═════════════════════════════════════════════════════════
//  CRUD OPERATIONS
// ═════════════════════════════════════════════════════════

// ─── CREATE ──────────────────────────────────────────────
// POST /admin/warehouses
export async function createWarehouse(code: string, name: string) {
  const supabase = await createClient();

  // Validate: code must be unique
  const { data: existing } = await supabase
    .from("warehouses")
    .select("id")
    .eq("code", code)
    .maybeSingle();

  if (existing) {
    throw new Error(`Warehouse code "${code}" already exists`);
  }

  // Validate: name required
  if (!name.trim()) {
    throw new Error("Warehouse name is required");
  }

  const { data, error } = await supabase
    .from("warehouses")
    .insert({ code: code.toUpperCase(), name: name.trim() })
    .select()
    .single();

  if (error) throw error;
  return data;
}

// ─── LIST ────────────────────────────────────────────────
// GET /admin/warehouses
export async function listWarehouses(filters?: {
  search?: string;
  page?: number;
  pageSize?: number;
}) {
  const supabase = await createClient();
  const page = filters?.page ?? 1;
  const pageSize = filters?.pageSize ?? 20;
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  let query = supabase
    .from("warehouses")
    .select("*", { count: "exact" });

  if (filters?.search) {
    query = query.or(
      `name.ilike.%${filters.search}%,code.ilike.%${filters.search}%`
    );
  }

  const { data, error, count } = await query
    .order("name", { ascending: true })
    .range(from, to);

  if (error) throw error;

  return {
    data: data ?? [],
    total: count ?? 0,
    page,
    pageSize,
  };
}

// ─── GET BY ID ───────────────────────────────────────────
// GET /admin/warehouses/:id
export async function getWarehouseById(id: string) {
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("warehouses")
    .select("*")
    .eq("id", id)
    .single();

  if (error) throw error;
  return data;
}

// ─── GET BY CODE ─────────────────────────────────────────
export async function getWarehouseByCode(code: string) {
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("warehouses")
    .select("*")
    .eq("code", code.toUpperCase())
    .single();

  if (error) throw error;
  return data;
}

// ─── UPDATE ──────────────────────────────────────────────
// PATCH /admin/warehouses/:id
export async function updateWarehouse(
  id: string,
  patch: { code?: string; name?: string }
) {
  const supabase = await createClient();

  // Validate: if updating code, check uniqueness
  if (patch.code) {
    const { data: existing } = await supabase
      .from("warehouses")
      .select("id")
      .eq("code", patch.code.toUpperCase())
      .neq("id", id)
      .maybeSingle();

    if (existing) {
      throw new Error(`Warehouse code "${patch.code}" already exists`);
    }
  }

  // Validate: name cannot be empty
  if (patch.name !== undefined && !patch.name.trim()) {
    throw new Error("Warehouse name cannot be empty");
  }

  const updates: WarehouseUpdate = {};
  if (patch.code) updates.code = patch.code.toUpperCase();
  if (patch.name) updates.name = patch.name.trim();

  const { data, error } = await supabase
    .from("warehouses")
    .update(updates)
    .eq("id", id)
    .select()
    .single();

  if (error) throw error;
  return data;
}

// ─── DELETE ──────────────────────────────────────────────
// DELETE /admin/warehouses/:id
// ⚠ Cascades: deletes all floors + locations under this warehouse
export async function deleteWarehouse(id: string) {
  const supabase = await createClient();

  // Safety check: count floors to warn about cascade
  const { count } = await supabase
    .from("floors")
    .select("*", { count: "exact", head: true })
    .eq("warehouse_id", id);

  if (count && count > 0) {
    throw new Error(
      `Cannot delete warehouse: it has ${count} floor(s). Remove all floors first.`
    );
  }

  const { error } = await supabase
    .from("warehouses")
    .delete()
    .eq("id", id);

  if (error) throw error;
}

// ═════════════════════════════════════════════════════════
//  HIERARCHY / SUMMARY
// ═════════════════════════════════════════════════════════

// ─── GET WAREHOUSE WITH SUMMARY ──────────────────────────
// Returns warehouse + counts of floors and locations
export async function getWarehouseWithSummary(
  id: string
): Promise<WarehouseWithSummary> {
  const supabase = await createClient();

  // Fetch warehouse
  const { data: warehouse, error: whError } = await supabase
    .from("warehouses")
    .select("*")
    .eq("id", id)
    .single();

  if (whError) throw whError;

  // Count floors
  const { count: floorsCount } = await supabase
    .from("floors")
    .select("*", { count: "exact", head: true })
    .eq("warehouse_id", id);

  // Count locations across all floors of this warehouse
  const { data: floorIds } = await supabase
    .from("floors")
    .select("id")
    .eq("warehouse_id", id);

  let locationsCount = 0;
  if (floorIds && floorIds.length > 0) {
    const ids = floorIds.map((f) => f.id);
    const { count } = await supabase
      .from("locations")
      .select("*", { count: "exact", head: true })
      .in("floor_id", ids);
    locationsCount = count ?? 0;
  }

  return {
    ...warehouse,
    floors_count: floorsCount ?? 0,
    locations_count: locationsCount,
  };
}

// ─── LIST WAREHOUSES WITH SUMMARY ────────────────────────
// Returns all warehouses with floor/location counts
export async function listWarehousesWithSummary(): Promise<
  WarehouseWithSummary[]
> {
  const supabase = await createClient();

  const { data: warehouses, error } = await supabase
    .from("warehouses")
    .select("*")
    .order("name", { ascending: true });

  if (error) throw error;
  if (!warehouses || warehouses.length === 0) return [];

  // Fetch all floors grouped by warehouse
  const { data: floors } = await supabase
    .from("floors")
    .select("id, warehouse_id");

  // Fetch all locations
  const { data: locations } = await supabase
    .from("locations")
    .select("floor_id");

  // Build lookup maps
  const floorsByWarehouse = new Map<string, string[]>();
  const locationsByFloor = new Map<string, number>();

  for (const floor of floors ?? []) {
    const list = floorsByWarehouse.get(floor.warehouse_id) ?? [];
    list.push(floor.id);
    floorsByWarehouse.set(floor.warehouse_id, list);
  }

  for (const loc of locations ?? []) {
    locationsByFloor.set(
      loc.floor_id,
      (locationsByFloor.get(loc.floor_id) ?? 0) + 1
    );
  }

  return warehouses.map((wh) => {
    const whFloors = floorsByWarehouse.get(wh.id) ?? [];
    const locsCount = whFloors.reduce(
      (sum, fid) => sum + (locationsByFloor.get(fid) ?? 0),
      0
    );

    return {
      ...wh,
      floors_count: whFloors.length,
      locations_count: locsCount,
    };
  });
}
