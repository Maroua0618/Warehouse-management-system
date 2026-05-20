"""
Bon de Préparation Router - Preparation orders for deliveries
Uses existing tables: orders (type='PREPARATION'), deliveries, stock_ledger_entries
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from supabase import Client
from app.supabase_client import get_supabase
from app.schemas.bon_de_preparation import (
    BonDePreparationCreate,
    BonDePreparationUpdate,
    BonDePreparationResponse,
    PreparationItemCreate,
    PreparationItemResponse,
)
from typing import List, Optional
from datetime import datetime
import uuid

router = APIRouter()


@router.get("/preparations", response_model=List[BonDePreparationResponse])
async def get_preparation_orders(
    status: Optional[str] = Query(None),
    delivery_id: Optional[str] = Query(None),
    supabase: Client = Depends(get_supabase),
):
    """Fetch all preparation orders with optional filtering"""
    try:
        # Query orders with type='PREPARATION'
        query = supabase.table("orders").select(
            "*, "
            "delivery:deliveries!orders_delivery_id_fkey(id, delivery_code, delivery_date, customer_name, address), "
            "preparer:users!orders_assigned_to_user_id_fkey(id, name)"
        ).eq("type", "PREPARATION")

        if status:
            query = query.eq("status", status)
        
        if delivery_id:
            query = query.eq("delivery_id", delivery_id)

        result = query.order("created_at", desc=True).execute()
        
        transformed_data = []
        for order in result.data:
            # Count items (preparation lines from stock_ledger_entries)
            items_result = supabase.table("stock_ledger_entries").select(
                "id"
            ).eq("order_id", order["id"]).eq("operation_type", "PREPARATION").execute()
            
            item_count = len(items_result.data) if items_result.data else 0
            
            delivery = order.get("delivery", {})
            preparer = order.get("preparer", {})
            
            transformed_order = {
                "id": order["id"],
                "order_code": order.get("source"),
                "delivery_id": order.get("delivery_id"),
                "delivery_code": delivery.get("delivery_code"),
                "delivery_date": delivery.get("delivery_date"),
                "customer_name": delivery.get("customer_name"),
                "status": order["status"],
                "priority": "MEDIUM",  # Can be derived from metadata
                "assigned_to_user_id": order.get("assigned_to_user_id"),
                "assigned_user_name": preparer.get("name"),
                "item_count": item_count,
                "created_at": order["created_at"],
                "completed_at": order.get("completed_at"),
            }
            transformed_data.append(transformed_order)
        
        return transformed_data
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error fetching preparation orders: {str(e)}"
        )


@router.get("/preparations/{order_id}", response_model=BonDePreparationResponse)
async def get_preparation_order_details(
    order_id: str,
    supabase: Client = Depends(get_supabase),
):
    """Fetch a specific preparation order with all items"""
    try:
        # Get order
        result = supabase.table("orders").select(
            "*, "
            "delivery:deliveries!orders_delivery_id_fkey(id, delivery_code, delivery_date, customer_name, address), "
            "preparer:users!orders_assigned_to_user_id_fkey(id, name)"
        ).eq("id", order_id).eq("type", "PREPARATION").execute()

        if not result.data:
            raise HTTPException(status_code=404, detail="Preparation order not found")

        order = result.data[0]

        # Get preparation items (from stock_ledger_entries)
        items_result = supabase.table("stock_ledger_entries").select(
            "*, "
            "sku:skus!stock_ledger_entries_sku_id_fkey(id, sku_code, name), "
            "location:locations!stock_ledger_entries_from_location_id_fkey(id, code)"
        ).eq("order_id", order_id).eq("operation_type", "PREPARATION").execute()

        items = []
        for item in items_result.data:
            sku = item.get("sku", {})
            location = item.get("location", {})
            items.append({
                "id": item["id"],
                "preparation_id": order_id,
                "sku_id": item["sku_id"],
                "sku_code": sku.get("sku_code"),
                "sku_name": sku.get("name"),
                "quantity_requested": abs(item["qty_delta"]),
                "quantity_prepared": abs(item["qty_delta"]) if item.get("picking_status") == "COMPLETED" else 0,
                "location_id": item.get("from_location_id"),
                "location_code": location.get("code"),
                "status": item.get("picking_status", "PENDING"),
            })

        delivery = order.get("delivery", {})
        preparer = order.get("preparer", {})

        return {
            "id": order["id"],
            "order_code": order.get("source"),
            "delivery_id": order.get("delivery_id"),
            "delivery_code": delivery.get("delivery_code"),
            "delivery_date": delivery.get("delivery_date"),
            "customer_name": delivery.get("customer_name"),
            "status": order["status"],
            "priority": "MEDIUM",
            "assigned_to_user_id": order.get("assigned_to_user_id"),
            "assigned_user_name": preparer.get("name"),
            "item_count": len(items),
            "items": items,
            "created_at": order["created_at"],
            "completed_at": order.get("completed_at"),
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error fetching preparation order: {str(e)}"
        )


@router.post("/preparations", response_model=BonDePreparationResponse)
async def create_preparation_order(
    prep_data: BonDePreparationCreate,
    user_id: str = Query(..., description="User creating the preparation"),
    supabase: Client = Depends(get_supabase),
):
    """Create a new preparation order"""
    try:
        order_id = str(uuid.uuid4())
        
        # Create order
        new_order = {
            "id": order_id,
            "type": "PREPARATION",
            "source": f"PREP-{datetime.utcnow().strftime('%Y%m%d')}-{order_id[:8]}",
            "status": "PENDING",
            "delivery_id": prep_data.delivery_id,
            "created_at": datetime.utcnow().isoformat(),
        }

        order_result = supabase.table("orders").insert(new_order).execute()

        if not order_result.data:
            raise HTTPException(status_code=500, detail="Failed to create preparation order")

        # Log audit trail
        audit_log = {
            "id": str(uuid.uuid4()),
            "actor_user_id": user_id,
            "action_type": "CREATE",
            "entity_type": "orders",
            "entity_id": order_id,
            "details": {"type": "PREPARATION", "delivery_id": prep_data.delivery_id},
            "ts": datetime.utcnow().isoformat(),
        }
        supabase.table("audit_logs").insert(audit_log).execute()

        # Get delivery details
        delivery_result = supabase.table("deliveries").select("*").eq("id", prep_data.delivery_id).execute()
        delivery = delivery_result.data[0] if delivery_result.data else {}

        return {
            "id": order_id,
            "order_code": new_order["source"],
            "delivery_id": prep_data.delivery_id,
            "delivery_code": delivery.get("delivery_code"),
            "delivery_date": delivery.get("delivery_date"),
            "customer_name": delivery.get("customer_name"),
            "status": "PENDING",
            "priority": prep_data.priority.value if hasattr(prep_data, 'priority') else "MEDIUM",
            "assigned_to_user_id": None,
            "assigned_user_name": None,
            "item_count": 0,
            "items": [],
            "created_at": new_order["created_at"],
            "completed_at": None,
        }
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error creating preparation order: {str(e)}"
        )


@router.post("/preparations/{order_id}/items", response_model=PreparationItemResponse)
async def add_preparation_item(
    order_id: str,
    item_data: PreparationItemCreate,
    user_id: str = Query(..., description="User adding the item"),
    supabase: Client = Depends(get_supabase),
):
    """Add a product to a preparation order"""
    try:
        # Verify order exists
        order_check = supabase.table("orders").select("id").eq("id", order_id).eq("type", "PREPARATION").execute()
        if not order_check.data:
            raise HTTPException(status_code=404, detail="Preparation order not found")

        # Create stock ledger entry (negative qty_delta for preparation)
        ledger_id = str(uuid.uuid4())
        ledger_entry = {
            "id": ledger_id,
            "sku_id": item_data.sku_id,
            "from_location_id": item_data.location_id,
            "qty_delta": -abs(item_data.quantity),  # Negative for outbound
            "operation_type": "PREPARATION",
            "order_id": order_id,
            "user_id": user_id,
            "picking_status": "PENDING",
            "idempotency_key": f"prep-{order_id}-{item_data.sku_id}-{datetime.utcnow().timestamp()}",
            "ts": datetime.utcnow().isoformat(),
        }

        result = supabase.table("stock_ledger_entries").insert(ledger_entry).execute()

        if not result.data:
            raise HTTPException(status_code=500, detail="Failed to add preparation item")

        # Get SKU and location details
        sku_result = supabase.table("skus").select("*").eq("id", item_data.sku_id).execute()
        location_result = supabase.table("locations").select("*").eq("id", item_data.location_id).execute()

        sku = sku_result.data[0] if sku_result.data else {}
        location = location_result.data[0] if location_result.data else {}

        return {
            "id": ledger_id,
            "preparation_id": order_id,
            "sku_id": item_data.sku_id,
            "sku_code": sku.get("sku_code"),
            "sku_name": sku.get("name"),
            "quantity_requested": item_data.quantity,
            "quantity_prepared": 0,
            "location_id": item_data.location_id,
            "location_code": location.get("code"),
            "status": "PENDING",
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error adding preparation item: {str(e)}"
        )


@router.put("/preparations/{order_id}", response_model=BonDePreparationResponse)
async def update_preparation_order(
    order_id: str,
    update_data: BonDePreparationUpdate,
    user_id: str = Query(..., description="User updating the preparation"),
    supabase: Client = Depends(get_supabase),
):
    """Update a preparation order (status, assignment, etc.)"""
    try:
        update_dict = {}
        
        if update_data.status:
            update_dict["status"] = update_data.status.value
            if update_data.status.value == "COMPLETED":
                update_dict["completed_at"] = datetime.utcnow().isoformat()
        
        if update_data.assigned_to_user_id:
            update_dict["assigned_to_user_id"] = update_data.assigned_to_user_id

        result = supabase.table("orders").update(update_dict).eq("id", order_id).eq("type", "PREPARATION").execute()

        if not result.data:
            raise HTTPException(status_code=404, detail="Preparation order not found")

        # Log audit trail
        audit_log = {
            "id": str(uuid.uuid4()),
            "actor_user_id": user_id,
            "action_type": "UPDATE",
            "entity_type": "orders",
            "entity_id": order_id,
            "details": update_dict,
            "ts": datetime.utcnow().isoformat(),
        }
        supabase.table("audit_logs").insert(audit_log).execute()

        # Return updated order (simplified response)
        order = result.data[0]
        
        return {
            "id": order["id"],
            "order_code": order.get("source"),
            "delivery_id": order.get("delivery_id"),
            "delivery_code": None,
            "delivery_date": None,
            "customer_name": None,
            "status": order["status"],
            "priority": "MEDIUM",
            "assigned_to_user_id": order.get("assigned_to_user_id"),
            "assigned_user_name": None,
            "item_count": 0,
            "items": [],
            "created_at": order["created_at"],
            "completed_at": order.get("completed_at"),
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error updating preparation order: {str(e)}"
        )


@router.delete("/preparations/{order_id}")
async def delete_preparation_order(
    order_id: str,
    user_id: str = Query(..., description="User deleting the preparation"),
    supabase: Client = Depends(get_supabase),
):
    """Delete a preparation order"""
    try:
        # Delete associated stock ledger entries first
        supabase.table("stock_ledger_entries").delete().eq("order_id", order_id).eq("operation_type", "PREPARATION").execute()

        # Delete order
        result = supabase.table("orders").delete().eq("id", order_id).eq("type", "PREPARATION").execute()

        if not result.data:
            raise HTTPException(status_code=404, detail="Preparation order not found")

        # Log audit trail
        audit_log = {
            "id": str(uuid.uuid4()),
            "actor_user_id": user_id,
            "action_type": "DELETE",
            "entity_type": "orders",
            "entity_id": order_id,
            "details": {"type": "PREPARATION"},
            "ts": datetime.utcnow().isoformat(),
        }
        supabase.table("audit_logs").insert(audit_log).execute()

        return {"success": True, "message": "Preparation order deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error deleting preparation order: {str(e)}"
        )
