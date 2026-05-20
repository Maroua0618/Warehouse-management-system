"""
Picking Tasks Router - Picking tasks with AI route optimization
Uses existing tables: operation_tasks (operation_type='PICKING'), route_plans, ai_recommendations
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from supabase import Client
from app.supabase_client import get_supabase
from app.schemas.picking_tasks import (
    PickingTaskCreate,
    PickingTaskUpdate,
    PickingTaskResponse,
    PickingRouteOptimizationRequest,
    PickingRouteOptimizationResponse,
)
from typing import List, Optional
from datetime import datetime
import uuid

router = APIRouter()


@router.get("/picking-tasks", response_model=List[PickingTaskResponse])
async def get_picking_tasks(
    status: Optional[str] = Query(None),
    assigned_to: Optional[str] = Query(None),
    supabase: Client = Depends(get_supabase),
):
    """Fetch all picking tasks with optional filtering"""
    try:
        # Query operation_tasks with operation_type='PICKING'
        query = supabase.table("operation_tasks").select(
            "*, "
            "order:orders!operation_tasks_order_id_fkey(id, source), "
            "user:users!operation_tasks_assigned_to_user_id_fkey(id, name), "
            "chariot:chariots!operation_tasks_chariot_id_fkey(id, code), "
            "route:route_plans!operation_tasks_planned_route_id_fkey(id, total_distance_meters, estimated_time_seconds, status)"
        ).eq("operation_type", "PICKING")

        if status:
            query = query.eq("status", status)
        
        if assigned_to:
            query = query.eq("assigned_to_user_id", assigned_to)

        result = query.order("created_at", desc=True).execute()
        
        transformed_data = []
        for task in result.data:
            # Count items (picking lines from stock_ledger_entries)
            items_result = supabase.table("stock_ledger_entries").select(
                "id"
            ).eq("task_id", task["id"]).eq("operation_type", "PICKING").execute()
            
            item_count = len(items_result.data) if items_result.data else 0
            
            order = task.get("order", {})
            user = task.get("user", {})
            chariot = task.get("chariot", {})
            route = task.get("route", {})
            
            transformed_task = {
                "id": task["id"],
                "order_id": task.get("order_id"),
                "order_code": order.get("source"),
                "status": task["status"],
                "priority": "MEDIUM",
                "assigned_to_user_id": task.get("assigned_to_user_id"),
                "assigned_user_name": user.get("name"),
                "chariot_id": task.get("chariot_id"),
                "chariot_code": chariot.get("code"),
                "planned_route_id": task.get("planned_route_id"),
                "route_distance_meters": route.get("total_distance_meters"),
                "route_time_seconds": route.get("estimated_time_seconds"),
                "item_count": item_count,
                "created_at": task["created_at"],
                "completed_at": task.get("completed_at"),
            }
            transformed_data.append(transformed_task)
        
        return transformed_data
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error fetching picking tasks: {str(e)}"
        )


@router.get("/picking-tasks/{task_id}", response_model=PickingTaskResponse)
async def get_picking_task_details(
    task_id: str,
    supabase: Client = Depends(get_supabase),
):
    """Fetch a specific picking task with all items and route"""
    try:
        # Get task
        result = supabase.table("operation_tasks").select(
            "*, "
            "order:orders!operation_tasks_order_id_fkey(id, source), "
            "user:users!operation_tasks_assigned_to_user_id_fkey(id, name), "
            "chariot:chariots!operation_tasks_chariot_id_fkey(id, code), "
            "route:route_plans!operation_tasks_planned_route_id_fkey(id, total_distance_meters, estimated_time_seconds, status, stops_json)"
        ).eq("id", task_id).eq("operation_type", "PICKING").execute()

        if not result.data:
            raise HTTPException(status_code=404, detail="Picking task not found")

        task = result.data[0]

        # Get picking items (from stock_ledger_entries)
        items_result = supabase.table("stock_ledger_entries").select(
            "*, "
            "sku:skus!stock_ledger_entries_sku_id_fkey(id, sku_code, name), "
            "location:locations!stock_ledger_entries_from_location_id_fkey(id, code, floor, zone)"
        ).eq("task_id", task_id).eq("operation_type", "PICKING").execute()

        items = []
        for item in items_result.data:
            sku = item.get("sku", {})
            location = item.get("location", {})
            items.append({
                "id": item["id"],
                "picking_task_id": task_id,
                "sku_id": item["sku_id"],
                "sku_code": sku.get("sku_code"),
                "sku_name": sku.get("name"),
                "quantity": abs(item["qty_delta"]),
                "location_id": item.get("from_location_id"),
                "location_code": location.get("code"),
                "floor": location.get("floor"),
                "zone": location.get("zone"),
                "status": item.get("picking_status", "PENDING"),
            })

        # Get route steps
        route = task.get("route", {})
        route_steps = []
        if route and route.get("stops_json"):
            stops = route["stops_json"]
            if isinstance(stops, list):
                for i, stop in enumerate(stops):
                    route_steps.append({
                        "sequence_number": i + 1,
                        "location_id": stop.get("location_id"),
                        "location_code": stop.get("location_code"),
                        "floor": stop.get("floor"),
                        "zone": stop.get("zone"),
                        "distance_from_previous": stop.get("distance_meters", 0),
                        "sku_codes": stop.get("sku_codes", []),
                    })

        order = task.get("order", {})
        user = task.get("user", {})
        chariot = task.get("chariot", {})

        return {
            "id": task["id"],
            "order_id": task.get("order_id"),
            "order_code": order.get("source"),
            "status": task["status"],
            "priority": "MEDIUM",
            "assigned_to_user_id": task.get("assigned_to_user_id"),
            "assigned_user_name": user.get("name"),
            "chariot_id": task.get("chariot_id"),
            "chariot_code": chariot.get("code"),
            "planned_route_id": task.get("planned_route_id"),
            "route_distance_meters": route.get("total_distance_meters"),
            "route_time_seconds": route.get("estimated_time_seconds"),
            "item_count": len(items),
            "items": items,
            "route_steps": route_steps,
            "created_at": task["created_at"],
            "completed_at": task.get("completed_at"),
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error fetching picking task: {str(e)}"
        )


@router.post("/picking-tasks", response_model=PickingTaskResponse)
async def create_picking_task(
    task_data: PickingTaskCreate,
    user_id: str = Query(..., description="User creating the task"),
    supabase: Client = Depends(get_supabase),
):
    """Create a new picking task"""
    try:
        task_id = str(uuid.uuid4())
        
        # Create operation_task
        new_task = {
            "id": task_id,
            "operation_type": "PICKING",
            "status": "PENDING",
            "order_id": task_data.order_id,
            "created_at": datetime.utcnow().isoformat(),
        }

        task_result = supabase.table("operation_tasks").insert(new_task).execute()

        if not task_result.data:
            raise HTTPException(status_code=500, detail="Failed to create picking task")

        # Log audit trail
        audit_log = {
            "id": str(uuid.uuid4()),
            "actor_user_id": user_id,
            "action_type": "CREATE",
            "entity_type": "operation_tasks",
            "entity_id": task_id,
            "details": {"operation_type": "PICKING", "order_id": task_data.order_id},
            "ts": datetime.utcnow().isoformat(),
        }
        supabase.table("audit_logs").insert(audit_log).execute()

        # Get order details
        order_result = supabase.table("orders").select("*").eq("id", task_data.order_id).execute()
        order = order_result.data[0] if order_result.data else {}

        return {
            "id": task_id,
            "order_id": task_data.order_id,
            "order_code": order.get("source"),
            "status": "PENDING",
            "priority": task_data.priority.value if hasattr(task_data, 'priority') else "MEDIUM",
            "assigned_to_user_id": None,
            "assigned_user_name": None,
            "chariot_id": None,
            "chariot_code": None,
            "planned_route_id": None,
            "route_distance_meters": None,
            "route_time_seconds": None,
            "item_count": 0,
            "items": [],
            "route_steps": [],
            "created_at": new_task["created_at"],
            "completed_at": None,
        }
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error creating picking task: {str(e)}"
        )


@router.put("/picking-tasks/{task_id}", response_model=PickingTaskResponse)
async def update_picking_task(
    task_id: str,
    update_data: PickingTaskUpdate,
    user_id: str = Query(..., description="User updating the task"),
    supabase: Client = Depends(get_supabase),
):
    """Update a picking task (status, assignment, etc.)"""
    try:
        update_dict = {}
        
        if update_data.status:
            update_dict["status"] = update_data.status.value
            if update_data.status.value == "COMPLETED":
                update_dict["completed_at"] = datetime.utcnow().isoformat()
        
        if update_data.assigned_to_user_id:
            update_dict["assigned_to_user_id"] = update_data.assigned_to_user_id
        
        if update_data.chariot_id:
            update_dict["chariot_id"] = update_data.chariot_id

        result = supabase.table("operation_tasks").update(update_dict).eq("id", task_id).execute()

        if not result.data:
            raise HTTPException(status_code=404, detail="Picking task not found")

        # Log audit trail
        audit_log = {
            "id": str(uuid4()),
            "actor_user_id": user_id,
            "action_type": "UPDATE",
            "entity_type": "operation_tasks",
            "entity_id": task_id,
            "details": update_dict,
            "ts": datetime.utcnow().isoformat(),
        }
        supabase.table("audit_logs").insert(audit_log).execute()

        # Return simplified response
        task = result.data[0]
        
        return {
            "id": task["id"],
            "order_id": task.get("order_id"),
            "order_code": None,
            "status": task["status"],
            "priority": "MEDIUM",
            "assigned_to_user_id": task.get("assigned_to_user_id"),
            "assigned_user_name": None,
            "chariot_id": task.get("chariot_id"),
            "chariot_code": None,
            "planned_route_id": task.get("planned_route_id"),
            "route_distance_meters": None,
            "route_time_seconds": None,
            "item_count": 0,
            "items": [],
            "route_steps": [],
            "created_at": task["created_at"],
            "completed_at": task.get("completed_at"),
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error updating picking task: {str(e)}"
        )


@router.post("/picking-tasks/ai/optimize-route", response_model=PickingRouteOptimizationResponse)
async def optimize_picking_route(
    request: PickingRouteOptimizationRequest,
    user_id: str = Query(..., description="User requesting optimization"),
    supabase: Client = Depends(get_supabase),
):
    """Get AI-optimized picking route"""
    try:
        # TODO: Call AI optimization engine (from Optimization_Agents.ipynb)
        # For now, return mock optimization
        
        route_id = str(uuid.uuid4())
        recommendation_id = str(uuid.uuid4())
        
        # Mock route optimization
        mock_stops = []
        total_distance = 0
        for i, item in enumerate(request.items):
            distance = 25.0 + (i * 10)
            total_distance += distance
            mock_stops.append({
                "location_id": item.location_id,
                "location_code": f"A0{i+1}-N1-B02",
                "floor": 1,
                "zone": "A",
                "distance_meters": distance,
                "sku_codes": [item.sku_code],
            })
        
        # Create route plan
        route_plan = {
            "id": route_id,
            "status": "PLANNED",
            "total_distance_meters": total_distance,
            "estimated_time_seconds": int(total_distance * 2.5),
            "stops_json": mock_stops,
            "created_at": datetime.utcnow().isoformat(),
        }
        
        supabase.table("route_plans").insert(route_plan).execute()
        
        # Link route to task
        if request.picking_task_id:
            supabase.table("operation_tasks").update({
                "planned_route_id": route_id
            }).eq("id", request.picking_task_id).execute()
        
        # Save AI recommendation
        ai_payload = {
            "route_id": route_id,
            "total_distance_meters": total_distance,
            "estimated_time_seconds": route_plan["estimated_time_seconds"],
            "path": [[i, i+1] for i in range(len(mock_stops))],
            "stops": mock_stops,
        }
        
        ai_recommendation = {
            "id": recommendation_id,
            "type": "PICKING_ROUTE_OPTIMIZATION",
            "payload_json": ai_payload,
            "created_at": datetime.utcnow().isoformat(),
        }
        
        supabase.table("ai_recommendations").insert(ai_recommendation).execute()
        
        # Transform to response format
        route_steps = []
        for i, stop in enumerate(mock_stops):
            route_steps.append({
                "sequence_number": i + 1,
                "location_id": stop["location_id"],
                "location_code": stop["location_code"],
                "floor": stop["floor"],
                "zone": stop["zone"],
                "distance_from_previous": stop["distance_meters"],
                "sku_codes": stop["sku_codes"],
            })
        
        return {
            "route_id": route_id,
            "recommendation_id": recommendation_id,
            "total_distance_meters": total_distance,
            "estimated_time_seconds": route_plan["estimated_time_seconds"],
            "route_steps": route_steps,
            "payload_json": ai_payload,
        }
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error optimizing picking route: {str(e)}"
        )


@router.delete("/picking-tasks/{task_id}")
async def delete_picking_task(
    task_id: str,
    user_id: str = Query(..., description="User deleting the task"),
    supabase: Client = Depends(get_supabase),
):
    """Delete a picking task"""
    try:
        # Delete associated stock ledger entries
        supabase.table("stock_ledger_entries").delete().eq("task_id", task_id).eq("operation_type", "PICKING").execute()

        # Delete task
        result = supabase.table("operation_tasks").delete().eq("id", task_id).eq("operation_type", "PICKING").execute()

        if not result.data:
            raise HTTPException(status_code=404, detail="Picking task not found")

        # Log audit trail
        audit_log = {
            "id": str(uuid.uuid4()),
            "actor_user_id": user_id,
            "action_type": "DELETE",
            "entity_type": "operation_tasks",
            "entity_id": task_id,
            "details": {"operation_type": "PICKING"},
            "ts": datetime.utcnow().isoformat(),
        }
        supabase.table("audit_logs").insert(audit_log).execute()

        return {"success": True, "message": "Picking task deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error deleting picking task: {str(e)}"
        )
