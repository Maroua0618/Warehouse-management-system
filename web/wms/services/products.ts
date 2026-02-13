import { createClient } from "@/lib/supabase/server";

// ═════════════════════════════════════════════════════════
//  TYPES
// ═════════════════════════════════════════════════════════

export interface Product {
  id: string;
  sku_code: string;
  name: string;
  weight_kg: number;
}

export interface ProductWithStock extends Product {
  total_stock: number;       // SUM(qty) across all locations
  location_count: number;    // number of distinct locations holding this SKU
}

export interface CreateProductInput {
  skuCode: string;
  name: string;
  weightKg?: number;
}

export interface UpdateProductInput {
  skuCode?: string;
  name?: string;
  weightKg?: number;
}

// ─── Pagination ──────────────────────────────────────────

export interface PaginationOpts {
  page?: number;
  pageSize?: number;
}

export interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

// ─── ServiceResult ───────────────────────────────────────

type ServiceResult<T> =
  | { success: true; data: T }
  | { success: false; error: string };

// ═════════════════════════════════════════════════════════
//  1) LIST PRODUCTS  (paginated + search)
// ═════════════════════════════════════════════════════════

export async function listProducts(
  filters?: { q?: string },
  pagination?: PaginationOpts
): Promise<ServiceResult<PaginatedResult<Product>>> {
  try {
    const supabase = await createClient();
    const page = pagination?.page ?? 1;
    const pageSize = pagination?.pageSize ?? 25;
    const from = (page - 1) * pageSize;
    const to = from + pageSize - 1;

    let query = supabase
      .from("skus")
      .select("id, sku_code, name, weight_kg", { count: "exact" });

    // ── Search by sku_code OR name (case-insensitive) ──
    if (filters?.q?.trim()) {
      const term = `%${filters.q.trim()}%`;
      query = query.or(`sku_code.ilike.${term},name.ilike.${term}`);
    }

    query = query.order("sku_code", { ascending: true }).range(from, to);

    const { data, error, count } = await query;

    if (error) {
      return { success: false, error: error.message };
    }

    const total = count ?? 0;

    return {
      success: true,
      data: {
        data: (data ?? []) as Product[],
        total,
        page,
        pageSize,
        totalPages: Math.ceil(total / pageSize),
      },
    };
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Unknown error";
    return { success: false, error: msg };
  }
}

// ═════════════════════════════════════════════════════════
//  2) CREATE PRODUCT
// ═════════════════════════════════════════════════════════

export async function createProduct(
  input: CreateProductInput
): Promise<ServiceResult<Product>> {
  try {
    const { skuCode, name, weightKg } = input;

    // ── Validation ───────────────────────────────────
    if (!skuCode?.trim()) {
      return { success: false, error: "SKU code is required" };
    }
    if (!name?.trim()) {
      return { success: false, error: "Name is required" };
    }
    if (weightKg !== undefined && weightKg < 0) {
      return { success: false, error: "Weight cannot be negative" };
    }

    const supabase = await createClient();

    // ── Unique check on sku_code ─────────────────────
    const { data: existing } = await supabase
      .from("skus")
      .select("id")
      .eq("sku_code", skuCode.trim())
      .maybeSingle();

    if (existing) {
      return { success: false, error: `SKU code "${skuCode.trim()}" already exists` };
    }

    // ── Insert ───────────────────────────────────────
    const { data, error } = await supabase
      .from("skus")
      .insert({
        sku_code: skuCode.trim(),
        name: name.trim(),
        weight_kg: weightKg ?? 0,
      })
      .select()
      .single();

    if (error || !data) {
      return { success: false, error: `Failed to create product: ${error?.message}` };
    }

    return { success: true, data: data as Product };
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Unknown error";
    return { success: false, error: msg };
  }
}

// ═════════════════════════════════════════════════════════
//  3) GET PRODUCT BY ID  (with stock summary)
// ═════════════════════════════════════════════════════════

export async function getProduct(
  id: string
): Promise<ServiceResult<ProductWithStock>> {
  try {
    const supabase = await createClient();

    // ── Fetch SKU ────────────────────────────────────
    const { data: sku, error: skuErr } = await supabase
      .from("skus")
      .select("id, sku_code, name, weight_kg")
      .eq("id", id)
      .single();

    if (skuErr || !sku) {
      return { success: false, error: "Product not found" };
    }

    // ── Stock summary from stock_balances ────────────
    const { data: balances } = await supabase
      .from("stock_balances")
      .select("qty, location_id")
      .eq("sku_id", id);

    const rows = balances ?? [];
    const totalStock = rows.reduce((sum, r) => sum + (r.qty ?? 0), 0);
    const locationCount = new Set(rows.map((r) => r.location_id)).size;

    return {
      success: true,
      data: {
        ...(sku as Product),
        total_stock: totalStock,
        location_count: locationCount,
      },
    };
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Unknown error";
    return { success: false, error: msg };
  }
}

/** Lightweight version without stock summary (for forms / quick lookups). */
export async function getProductById(
  id: string
): Promise<ServiceResult<Product>> {
  try {
    const supabase = await createClient();

    const { data, error } = await supabase
      .from("skus")
      .select("id, sku_code, name, weight_kg")
      .eq("id", id)
      .single();

    if (error || !data) {
      return { success: false, error: "Product not found" };
    }

    return { success: true, data: data as Product };
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Unknown error";
    return { success: false, error: msg };
  }
}

// ═════════════════════════════════════════════════════════
//  4) UPDATE PRODUCT
// ═════════════════════════════════════════════════════════

export async function updateProduct(
  id: string,
  patch: UpdateProductInput
): Promise<ServiceResult<Product>> {
  try {
    const supabase = await createClient();

    // ── Verify exists ────────────────────────────────
    const { data: current, error: fetchErr } = await supabase
      .from("skus")
      .select("id, sku_code")
      .eq("id", id)
      .single();

    if (fetchErr || !current) {
      return { success: false, error: "Product not found" };
    }

    // ── Validate ─────────────────────────────────────
    if (patch.name !== undefined && !patch.name.trim()) {
      return { success: false, error: "Name cannot be empty" };
    }
    if (patch.weightKg !== undefined && patch.weightKg < 0) {
      return { success: false, error: "Weight cannot be negative" };
    }

    // ── Unique check if sku_code is changing ─────────
    if (patch.skuCode !== undefined) {
      const trimmed = patch.skuCode.trim();
      if (!trimmed) {
        return { success: false, error: "SKU code cannot be empty" };
      }
      if (trimmed !== current.sku_code) {
        const { data: dup } = await supabase
          .from("skus")
          .select("id")
          .eq("sku_code", trimmed)
          .neq("id", id)
          .maybeSingle();

        if (dup) {
          return { success: false, error: `SKU code "${trimmed}" already exists` };
        }
      }
    }

    // ── Build update payload ─────────────────────────
    const updatePayload: Record<string, unknown> = {};
    if (patch.skuCode !== undefined) updatePayload.sku_code = patch.skuCode.trim();
    if (patch.name !== undefined) updatePayload.name = patch.name.trim();
    if (patch.weightKg !== undefined) updatePayload.weight_kg = patch.weightKg;

    if (Object.keys(updatePayload).length === 0) {
      return { success: false, error: "No fields to update" };
    }

    const { data, error } = await supabase
      .from("skus")
      .update(updatePayload)
      .eq("id", id)
      .select()
      .single();

    if (error || !data) {
      return { success: false, error: `Failed to update: ${error?.message}` };
    }

    return { success: true, data: data as Product };
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Unknown error";
    return { success: false, error: msg };
  }
}

// ═════════════════════════════════════════════════════════
//  5) DELETE PRODUCT  (safe — only if no references)
// ═════════════════════════════════════════════════════════

export async function deleteProduct(
  id: string
): Promise<ServiceResult<{ id: string }>> {
  try {
    const supabase = await createClient();

    // ── Verify exists ────────────────────────────────
    const { data: sku, error: fetchErr } = await supabase
      .from("skus")
      .select("id, sku_code")
      .eq("id", id)
      .single();

    if (fetchErr || !sku) {
      return { success: false, error: "Product not found" };
    }

    // ── Check stock_balances ─────────────────────────
    const { count: stockCount } = await supabase
      .from("stock_balances")
      .select("*", { count: "exact", head: true })
      .eq("sku_id", id);

    if (stockCount && stockCount > 0) {
      return {
        success: false,
        error: `Cannot delete: ${stockCount} stock balance(s) reference this SKU`,
      };
    }

    // ── Check stock_ledger_entries ────────────────────
    const { count: ledgerCount } = await supabase
      .from("stock_ledger_entries")
      .select("*", { count: "exact", head: true })
      .eq("sku_id", id);

    if (ledgerCount && ledgerCount > 0) {
      return {
        success: false,
        error: `Cannot delete: ${ledgerCount} ledger entry/entries reference this SKU`,
      };
    }

    // ── Safe to delete ───────────────────────────────
    const { error: delErr } = await supabase
      .from("skus")
      .delete()
      .eq("id", id);

    if (delErr) {
      return { success: false, error: `Failed to delete: ${delErr.message}` };
    }

    return { success: true, data: { id } };
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Unknown error";
    return { success: false, error: msg };
  }
}

// ═════════════════════════════════════════════════════════
//  6) HELPERS  (look-ups, bulk)
// ═════════════════════════════════════════════════════════

/** Look up a product by its sku_code (e.g. from barcode scan). */
export async function getProductByCode(
  skuCode: string
): Promise<ServiceResult<Product>> {
  try {
    const supabase = await createClient();

    const { data, error } = await supabase
      .from("skus")
      .select("id, sku_code, name, weight_kg")
      .eq("sku_code", skuCode.trim())
      .single();

    if (error || !data) {
      return { success: false, error: "Product not found" };
    }

    return { success: true, data: data as Product };
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Unknown error";
    return { success: false, error: msg };
  }
}

/** Stock breakdown per location for a given SKU. */
export async function getStockByProduct(
  skuId: string
): Promise<
  ServiceResult<
    { location_id: string; location_code: string; qty: number; version: number }[]
  >
> {
  try {
    const supabase = await createClient();

    const { data, error } = await supabase
      .from("stock_balances")
      .select(
        `
        location_id,
        qty,
        version,
        locations!stock_balances_location_id_fkey ( code )
        `
      )
      .eq("sku_id", skuId)
      .order("qty", { ascending: false });

    if (error) {
      return { success: false, error: error.message };
    }

    const rows = (data ?? []).map((r: Record<string, unknown>) => {
      const loc = r.locations as { code: string } | null;
      return {
        location_id: r.location_id as string,
        location_code: loc?.code ?? "",
        qty: r.qty as number,
        version: r.version as number,
      };
    });

    return { success: true, data: rows };
  } catch (err) {
    const msg = err instanceof Error ? err.message : "Unknown error";
    return { success: false, error: msg };
  }
}
