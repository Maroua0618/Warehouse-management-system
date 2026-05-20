"""
Command Orders Router - Reception of products (Bon de Commande)
Uses existing tables: orders (type='COMMAND'), command_orders, stock_ledger_entries
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from supabase import Client
from app.supabase_client import get_supabase
from app.schemas.command_orders import (
    CommandOrderCreate,
    CommandOrderResponse,
    CommandOrderWithLinesResponse,
    CommandOrderLineCreate,
    CommandOrderLineResponse,
)
from typing import List, Optional
from datetime import datetime
import uuid

router = APIRouter()


@router.get("/command-orders", response_model=List[CommandOrderResponse])
async def get_command_orders(
    status: Optional[str] = Query(None),
    supabase: Client = Depends(get_supabase),
):
    """Fetch all command orders (Bon de Commande) with optional status filtering"""
    try:
        # Query orders table with type='COMMAND' and join with command_orders
        query = supabase.table("orders").select(
            "*, "
            "command_order:command_orders!command_orders_order_id_fkey(order_id, reception_at), "
            "creator:users!orders_created_by_fkey(id, name), "
            "validator:users!orders_validated_by_fkey(id, name)"
        ).eq("type", "COMMAND")

        if status:
            query = query.eq("status", status)

        result = query.order("created_at", desc=True).execute()
        
        # Transform data to match schema
        transformed_data = []
        for row in result.data:
            transformed_row = {
                "id": row["id"],
                "order_id": row["id"],
                "source": row["source"],
                "status": row["status"],
                "created_at": row["created_at"],
                "created_by": row.get("created_by"),
                "validated_by": row.get("validated_by"),
                "reception_at": row.get("command_order", {}).get("reception_at") if row.get("command_order") else None,
            }
            transformed_data.append(transformed_row)
        
        return transformed_data
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error fetching command orders: {str(e)}"
        )


@router.get("/command-orders/{order_id}", response_model=CommandOrderWithLinesResponse)
async def get_command_order_with_lines(
    order_id: str,
    supabase: Client = Depends(get_supabase),
):
    """Fetch a command order with all its product lines"""
    try:
        # Get order
        order_result = supabase.table("orders").select(
            "*, command_order:command_orders!command_orders_order_id_fkey(order_id, reception_at)"
        ).eq("id", order_id).eq("type", "COMMAND").execute()

        if not order_result.data:
            raise HTTPException(status_code=404, detail="Command order not found")

        order = order_result.data[0]

        # Get product lines from stock_ledger_entries
        lines_result = supabase.table("stock_ledger_entries").select(
            "*, "
            "sku:skus!stock_ledger_entries_sku_id_fkey(id, sku_code, name), "
            "location:locations!stock_ledger_entries_to_location_id_fkey(id, code), "
            "user:users!stock_ledger_entries_user_id_fkey(id, name)"
        ).eq("order_id", order_id).eq("operation_type", "RECEPTION").execute()

        # Transform lines
        lines = []
        for line in lines_result.data:
            transformed_line = {
                "id": line["id"],
                "order_id": order_id,
                "sku_id": line["sku_id"],
                "to_location_id": line["to_location_id"],
                "quantity": line["qty_delta"],
                "sku_code": line.get("sku", {}).get("sku_code"),
                "sku_name": line.get("sku", {}).get("name"),
                "location_code": line.get("location", {}).get("code"),
                "ts": line["ts"],
                "user_id": line.get("user_id"),
                "user_name": line.get("user", {}).get("name"),
            }
            lines.append(transformed_line)

        # Build response
        response = {
            "id": order["id"],
            "order_id": order["id"],
            "source": order["source"],
            "status": order["status"],
            "created_at": order["created_at"],
            "created_by": order.get("created_by"),
            "validated_by": order.get("validated_by"),
            "reception_at": order.get("command_order", {}).get("reception_at") if order.get("command_order") else None,
            "lines": lines,
        }

        return response
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error fetching command order: {str(e)}"
        )


@router.post("/command-orders", response_model=CommandOrderResponse)
async def create_command_order(
    order_data: CommandOrderCreate,
    user_id: str = Query(..., description="User creating the order"),
    supabase: Client = Depends(get_supabase),
):
    """Create a new command order (Bon de Commande)"""
    try:
        order_id = str(uuid.uuid4())
        
        # Create order in orders table
        new_order = {
            "id": order_id,
            "type": "COMMAND",
            "status": order_data.status or "DRAFT",
            "source": order_data.source,
            "created_by": user_id,
            "created_at": datetime.utcnow().isoformat(),
        }

        order_result = supabase.table("orders").insert(new_order).execute()

        if not order_result.data:
            raise HTTPException(status_code=500, detail="Failed to create command order")

        # Create command_order metadata
        command_order = {
            "order_id": order_id,
            "reception_at": datetime.utcnow().isoformat(),
        }

        supabase.table("command_orders").insert(command_order).execute()

        # Log audit trail
        audit_log = {
            "id": str(uuid.uuid4()),
            "actor_user_id": user_id,
            "action_type": "CREATE",
            "entity_type": "orders",
            "entity_id": order_id,
            "details": {"type": "COMMAND", "source": order_data.source},
            "ts": datetime.utcnow().isoformat(),
        }
        supabase.table("audit_logs").insert(audit_log).execute()

        return {
            "id": order_id,
            "order_id": order_id,
            "source": order_data.source,
            "status": order_data.status or "DRAFT",
            "created_at": new_order["created_at"],
            "created_by": user_id,
            "validated_by": None,
            "reception_at": command_order["reception_at"],
        }
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error creating command order: {str(e)}"
        )


@router.post("/command-orders/{order_id}/lines", response_model=CommandOrderLineResponse)
async def add_product_line(
    order_id: str,
    line_data: CommandOrderLineCreate,
    user_id: str = Query(..., description="User adding the line"),
    supabase: Client = Depends(get_supabase),
):
    """Add a product line to a command order (uses stock_ledger_entries)"""
    try:
        # Create stock ledger entry for RECEPTION
        ledger_entry = {
            "id": str(uuid.uuid4()),
            "sku_id": line_data.sku_id,
            "to_location_id": line_data.to_location_id,
            "qty_delta": line_data.quantity,
            "operation_type": "RECEPTION",
            "order_id": order_id,
            "user_id": user_id,
            "idempotency_key": f"cmd-line-{order_id}-{line_data.sku_id}-{datetime.utcnow().timestamp()}",
            "ts": datetime.utcnow().isoformat(),
        }

        result = supabase.table("stock_ledger_entries").insert(ledger_entry).execute()

        if not result.data:
            raise HTTPException(status_code=500, detail="Failed to add product line")

        # Get SKU and location details
        sku_result = supabase.table("skus").select("sku_code, name").eq("id", line_data.sku_id).execute()
        location_result = supabase.table("locations").select("code").eq("id", line_data.to_location_id).execute()
        user_result = supabase.table("users").select("name").eq("id", user_id).execute()

        return {
            "id": ledger_entry["id"],
            "order_id": order_id,
            "sku_id": line_data.sku_id,
            "to_location_id": line_data.to_location_id,
            "quantity": line_data.quantity,
            "sku_code": sku_result.data[0]["sku_code"] if sku_result.data else None,
            "sku_name": sku_result.data[0]["name"] if sku_result.data else None,
            "location_code": location_result.data[0]["code"] if location_result.data else None,
            "ts": ledger_entry["ts"],
            "user_id": user_id,
            "user_name": user_result.data[0]["name"] if user_result.data else None,
        }
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error adding product line: {str(e)}"
        )


@router.put("/command-orders/{order_id}/validate")
async def validate_command_order(
    order_id: str,
    user_id: str = Query(..., description="User validating the order"),
    supabase: Client = Depends(get_supabase),
):
    """Validate a command order (change status from DRAFT to VALIDATED)"""
    try:
        update_data = {
            "status": "VALIDATED",
            "validated_by": user_id,
        }

        result = supabase.table("orders").update(update_data).eq("id", order_id).execute()

        if not result.data:
            raise HTTPException(status_code=404, detail="Command order not found")

        # Log audit trail
        audit_log = {
            "id": str(uuid.uuid4()),
            "actor_user_id": user_id,
            "action_type": "VALIDATE",
            "entity_type": "orders",
            "entity_id": order_id,
            "details": {"status": "VALIDATED"},
            "ts": datetime.utcnow().isoformat(),
        }
        supabase.table("audit_logs").insert(audit_log).execute()

        return {"message": "Command order validated successfully", "order_id": order_id}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error validating command order: {str(e)}"
        )


@router.delete("/command-orders/{order_id}")
async def delete_command_order(
    order_id: str,
    supabase: Client = Depends(get_supabase),
):
    """Delete a command order (CASCADE will delete related entries)"""
    try:
        result = supabase.table("orders").delete().eq("id", order_id).execute()

        if not result.data:
            raise HTTPException(status_code=404, detail="Command order not found")

        return {"message": "Command order deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error deleting command order: {str(e)}"
        )
