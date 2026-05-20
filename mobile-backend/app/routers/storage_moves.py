"""
Storage Moves Router - Move products from reception to storage
Uses existing tables: operation_tasks (operation_type='STORAGE'), ai_recommendations
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from supabase import Client
from app.supabase_client import get_supabase
from app.schemas.storage_moves import (
    StorageMoveCreate,
    StorageMoveUpdate,
    StorageMoveResponse,
    StorageRecommendationRequest,
    StorageRecommendationResponse,
    AssignStorageMoveRequest,
    OverrideRecommendationRequest,
    OverrideDecisionResponse,
    TaskStatus,
)
from typing import List, Optional
from datetime import datetime
import uuid

router = APIRouter()


@router.get("/storage-moves", response_model=List[StorageMoveResponse])
async def get_storage_moves(
    status: Optional[str] = Query(None),
    supabase: Client = Depends(get_supabase),
):
    """Fetch all storage tasks with optional filtering"""
    try:
        # Query operation_tasks with operation_type='STORAGE'
        query = supabase.table("operation_tasks").select(
            "*, "
            "order:orders!operation_tasks_order_id_fkey(id, source, status), "
            "user:users!operation_tasks_assigned_to_user_id_fkey(id, name), "
            "chariot:chariots!operation_tasks_chariot_id_fkey(id, code), "
            "route:route_plans!operation_tasks_planned_route_id_fkey(id, total_distance_meters)"
        ).eq("operation_type", "STORAGE")

        if status:
            query = query.eq("status", status)

        result = query.order("created_at", desc=True).execute()
        
        # For each task, get related stock ledger entry to find SKU and locations
        transformed_data = []
        for task in result.data:
            # Find related ledger entry
            ledger_result = supabase.table("stock_ledger_entries").select(
                "*, "
                "sku:skus!stock_ledger_entries_sku_id_fkey(id, sku_code, name), "
                "from_location:locations!stock_ledger_entries_from_location_id_fkey(id, code), "
                "to_location:locations!stock_ledger_entries_to_location_id_fkey(id, code)"
            ).eq("task_id", task["id"]).execute()

            # Get AI recommendation if exists
            ai_rec = None
            if task.get("order_id"):
                ai_result = supabase.table("ai_recommendations").select("*").eq(
                    "order_id", task["order_id"]
                ).eq("type", "STORAGE_OPTIMIZATION").order("created_at", desc=True).limit(1).execute()
                if ai_result.data:
                    ai_rec = ai_result.data[0]["payload_json"]

            ledger = ledger_result.data[0] if ledger_result.data else {}
            
            transformed_task = {
                "id": task["id"],
                "order_id": task.get("order_id"),
                "sku_id": ledger.get("sku_id"),
                "from_location_id": ledger.get("from_location_id"),
                "to_location_id": ledger.get("to_location_id"),
                "quantity": ledger.get("qty_delta", 0),
                "priority": "MEDIUM",  # Can be derived from payload or defaults
                "status": task["status"],
                "assigned_to_user_id": task.get("assigned_to_user_id"),
                "assigned_user_name": task.get("user", {}).get("name"),
                "chariot_id": task.get("chariot_id"),
                "chariot_code": task.get("chariot", {}).get("code"),
                "planned_route_id": task.get("planned_route_id"),
                "created_at": task["created_at"],
                "completed_at": task.get("completed_at"),
                "sku_code": ledger.get("sku", {}).get("sku_code"),
                "sku_name": ledger.get("sku", {}).get("name"),
                "from_location_code": ledger.get("from_location", {}).get("code"),
                "to_location_code": ledger.get("to_location", {}).get("code"),
                "ai_recommendation": ai_rec,
            }
            transformed_data.append(transformed_task)
        
        return transformed_data
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error fetching storage moves: {str(e)}"
        )


@router.post("/storage-moves", response_model=StorageMoveResponse)
async def create_storage_move(
    move_data: StorageMoveCreate,
    user_id: str = Query(..., description="User creating the task"),
    supabase: Client = Depends(get_supabase),
):
    """Create a new storage task"""
    try:
        task_id = str(uuid.uuid4())
        
        # Create operation_task
        new_task = {
            "id": task_id,
            "operation_type": "STORAGE",
            "status": "PENDING",
            "order_id": move_data.order_id,
            "created_at": datetime.utcnow().isoformat(),
        }

        task_result = supabase.table("operation_tasks").insert(new_task).execute()

        if not task_result.data:
            raise HTTPException(status_code=500, detail="Failed to create storage task")

        # Note: Stock ledger entry will be created when task is completed
        # For now, we just store the task metadata

        # Log audit trail
        audit_log = {
            "id": str(uuid.uuid4()),
            "actor_user_id": user_id,
            "action_type": "CREATE",
            "entity_type": "operation_tasks",
            "entity_id": task_id,
            "details": {"operation_type": "STORAGE", "sku_id": move_data.sku_id},
            "ts": datetime.utcnow().isoformat(),
        }
        supabase.table("audit_logs").insert(audit_log).execute()

        return {
            "id": task_id,
            "order_id": move_data.order_id,
            "sku_id": move_data.sku_id,
            "from_location_id": move_data.from_location_id,
            "to_location_id": move_data.to_location_id,
            "quantity": move_data.quantity,
            "priority": move_data.priority.value,
            "status": "PENDING",
            "assigned_to_user_id": None,
            "assigned_user_name": None,
            "chariot_id": None,
            "chariot_code": None,
            "planned_route_id": None,
            "created_at": new_task["created_at"],
            "completed_at": None,
            "sku_code": None,
            "sku_name": None,
            "from_location_code": None,
            "to_location_code": None,
            "ai_recommendation": None,
        }
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error creating storage move: {str(e)}"
        )


@router.put("/storage-moves/{task_id}", response_model=StorageMoveResponse)
async def update_storage_move(
    task_id: str,
    update_data: StorageMoveUpdate,
    user_id: str = Query(..., description="User updating the task"),
    supabase: Client = Depends(get_supabase),
):
    """Update a storage task (assign, change status, etc.)"""
    try:
        update_dict = {}
        
        if update_data.status:
            update_dict["status"] = update_data.status.value
            if update_data.status == TaskStatus.COMPLETED:
                update_dict["completed_at"] = datetime.utcnow().isoformat()
        
        if update_data.assigned_to_user_id:
            update_dict["assigned_to_user_id"] = update_data.assigned_to_user_id
        
        if update_data.chariot_id:
            update_dict["chariot_id"] = update_data.chariot_id

        result = supabase.table("operation_tasks").update(update_dict).eq("id", task_id).execute()

        if not result.data:
            raise HTTPException(status_code=404, detail="Storage task not found")

        # If task is completed, create stock ledger entry
        if update_data.status == TaskStatus.COMPLETED and update_data.to_location_id:
            # Get task details to create ledger entry
            task = result.data[0]
            
            # Find related SKU from order
            # This is simplified - in real scenario, you'd get SKU from task metadata
            ledger_entry = {
                "id": str(uuid.uuid4()),
                "sku_id": "placeholder",  # Should come from task metadata
                "from_location_id": "placeholder",  # Should come from task
                "to_location_id": update_data.to_location_id,
                "qty_delta": 0,  # Should come from task
                "operation_type": "STORAGE",
                "task_id": task_id,
                "user_id": user_id,
                "idempotency_key": f"storage-{task_id}-{datetime.utcnow().timestamp()}",
                "ts": datetime.utcnow().isoformat(),
            }
            # supabase.table("stock_ledger_entries").insert(ledger_entry).execute()

        # Log audit trail
        audit_log = {
            "id": str(uuid.uuid4()),
            "actor_user_id": user_id,
            "action_type": "UPDATE",
            "entity_type": "operation_tasks",
            "entity_id": task_id,
            "details": update_dict,
            "ts": datetime.utcnow().isoformat(),
        }
        supabase.table("audit_logs").insert(audit_log).execute()

        # Fetch updated task with joins
        updated = supabase.table("operation_tasks").select(
            "*, user:users!operation_tasks_assigned_to_user_id_fkey(name), "
            "chariot:chariots!operation_tasks_chariot_id_fkey(code)"
        ).eq("id", task_id).execute()

        task = updated.data[0] if updated.data else result.data[0]
        
        return {
            "id": task["id"],
            "order_id": task.get("order_id"),
            "sku_id": None,
            "from_location_id": None,
            "to_location_id": update_data.to_location_id,
            "quantity": 0,
            "priority": "MEDIUM",
            "status": task["status"],
            "assigned_to_user_id": task.get("assigned_to_user_id"),
            "assigned_user_name": task.get("user", {}).get("name"),
            "chariot_id": task.get("chariot_id"),
            "chariot_code": task.get("chariot", {}).get("code"),
            "planned_route_id": task.get("planned_route_id"),
            "created_at": task["created_at"],
            "completed_at": task.get("completed_at"),
            "sku_code": None,
            "sku_name": None,
            "from_location_code": None,
            "to_location_code": None,
            "ai_recommendation": None,
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error updating storage move: {str(e)}"
        )


@router.post("/storage-moves/ai/recommend", response_model=StorageRecommendationResponse)
async def get_ai_storage_recommendation(
    request: StorageRecommendationRequest,
    user_id: str = Query(..., description="User requesting recommendation"),
    supabase: Client = Depends(get_supabase),
):
    """Get AI recommendation for optimal storage location"""
    try:
        # TODO: Call AI optimization engine (from Optimization_Agents.ipynb)
        # For now, return mock recommendation
        
        recommendation_id = str(uuid.uuid4())
        
        # Mock AI recommendation payload
        ai_payload = {
            "assigned_slot": "B01-N2-A05",
            "location_id": str(uuid.uuid4()),  # Mock
            "floor": 2,
            "zone": "A",
            "abc_class": "A",
            "score": 0.92,
            "distance_meters": 45.5,
            "estimated_time_seconds": 90,
            "path": [[8, 8], [9, 8], [10, 8]],
        }
        
        # Save recommendation to database
        recommendation = {
            "id": recommendation_id,
            "type": "STORAGE_OPTIMIZATION",
            "payload_json": ai_payload,
            "created_at": datetime.utcnow().isoformat(),
        }
        
        supabase.table("ai_recommendations").insert(recommendation).execute()
        
        return {
            "recommendation_id": recommendation_id,
            "assigned_slot": ai_payload["assigned_slot"],
            "location_id": ai_payload["location_id"],
            "floor": ai_payload["floor"],
            "zone": ai_payload["zone"],
            "abc_class": ai_payload["abc_class"],
            "score": ai_payload["score"],
            "distance_meters": ai_payload.get("distance_meters"),
            "estimated_time_seconds": ai_payload.get("estimated_time_seconds"),
            "payload_json": ai_payload,
        }
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error getting AI recommendation: {str(e)}"
        )


@router.post("/storage-moves/ai/override", response_model=OverrideDecisionResponse)
async def override_ai_recommendation(
    request: OverrideRecommendationRequest,
    supabase: Client = Depends(get_supabase),
):
    """Override an AI recommendation (human decision)"""
    try:
        override_id = str(uuid.uuid4())
        
        override_decision = {
            "id": override_id,
            "recommendation_id": request.recommendation_id,
            "status": "PENDING",
            "overridden_by_user_id": request.user_id,
            "justification": request.justification,
            "final_payload_json": {
                "destination_id": request.new_destination_id,
                "reason": request.justification,
            },
            "created_at": datetime.utcnow().isoformat(),
            "updated_at": datetime.utcnow().isoformat(),
        }
        
        result = supabase.table("override_decisions").insert(override_decision).execute()
        
        if not result.data:
            raise HTTPException(status_code=500, detail="Failed to create override decision")
        
        # Get user name
        user_result = supabase.table("users").select("name").eq("id", request.user_id).execute()
        
        return {
            "id": override_id,
            "recommendation_id": request.recommendation_id,
            "status": "PENDING",
            "overridden_by_user_id": request.user_id,
            "overridden_by_user_name": user_result.data[0]["name"] if user_result.data else None,
            "justification": request.justification,
            "final_payload_json": override_decision["final_payload_json"],
            "created_at": override_decision["created_at"],
            "updated_at": override_decision["updated_at"],
        }
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error creating override: {str(e)}"
        )


@router.post("/storage-moves/{task_id}/assign", response_model=StorageMoveResponse)
async def assign_storage_task(
    task_id: str,
    assignment: AssignStorageMoveRequest,
    supabase: Client = Depends(get_supabase),
):
    """Assign a storage task to an employee and optionally a chariot"""
    try:
        update_data = {
            "assigned_to_user_id": assignment.employee_id,
            "status": "IN_PROGRESS",
        }
        
        if assignment.chariot_id:
            update_data["chariot_id"] = assignment.chariot_id

        result = supabase.table("operation_tasks").update(update_data).eq("id", task_id).execute()

        if not result.data:
            raise HTTPException(status_code=404, detail="Storage task not found")

        # Log assignment
        audit_log = {
            "id": str(uuid.uuid4()),
            "actor_user_id": assignment.employee_id,
            "action_type": "ASSIGN",
            "entity_type": "operation_tasks",
            "entity_id": task_id,
            "details": {"chariot_id": assignment.chariot_id},
            "ts": datetime.utcnow().isoformat(),
        }
        supabase.table("audit_logs").insert(audit_log).execute()

        # Return updated task
        # (Implementation similar to update endpoint)
        return {"id": task_id, "status": "IN_PROGRESS", **update_data}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error assigning storage task: {str(e)}"
        )
