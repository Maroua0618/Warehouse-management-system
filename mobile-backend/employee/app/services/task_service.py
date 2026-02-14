"""Task management service."""
from typing import List, Optional
from supabase import Client
from fastapi import HTTPException, status
from app.schemas.task import (
    TaskSummary, TaskDetail, TaskListResponse, OrderLineItem, 
    SKUInfo, LocationInfo, ChariotInfo, RoutePlan, RouteNode,
    ProductValidationItem, UpdateTaskStatusRequest, ValidateTaskRequest,
    ConfirmPlacementRequest
)
from app.schemas.common import TaskStatus, OrderType, OperationType
from datetime import datetime


class TaskService:
    """Task management service."""
    
    def __init__(self, db: Client):
        self.db = db
    
    async def get_employee_tasks(self, user_id: str) -> TaskListResponse:
        """Get all tasks assigned to an employee."""
        try:
            print(f"\n🔍 DEBUG: Fetching tasks for user_id: {user_id}")
            
            # Get tasks assigned to the user - include all statuses except CANCELLED
            tasks_response = self.db.table("operation_tasks")\
                .select("*")\
                .eq("assigned_to_user_id", user_id)\
                .in_("status", ["PENDING", "ASSIGNED", "IN_PROGRESS", "DONE"])\
                .order("created_at", desc=True)\
                .execute()
            
            print(f"📋 DEBUG: Found {len(tasks_response.data)} tasks in database")
            
            if tasks_response.data:
                print(f"📋 DEBUG: First task: {tasks_response.data[0]}")
            
            ingoing_tasks = []
            outgoing_tasks = []
        except Exception as e:
            print(f"❌ ERROR in get_employee_tasks: {e}")
            import traceback
            traceback.print_exc()
            raise
        
        for task in tasks_response.data:
            # Get order info separately
            order_response = self.db.table("orders")\
                .select("id, type, status, created_at")\
                .eq("id", task["order_id"])\
                .execute()
            
            if not order_response.data:
                continue
            
            order = order_response.data[0]
            
            # Count items based on operation type
            item_count = await self._get_task_item_count(task["order_id"], task["operation_type"])
            
            # Get storage location
            storage_location_info = await self._get_task_storage_location(task, order["type"])
            
            task_summary = TaskSummary(
                id=task["id"],
                order_id=task["order_id"],
                order_type=OrderType(order["type"]),
                status=TaskStatus(task["status"]),
                operation_type=OperationType(task["operation_type"]),
                created_at=datetime.fromisoformat(task["created_at"]),
                item_count=item_count,
                delivery_id=task.get("delivery_id"),
                storage_location=storage_location_info
            )
            
            # Categorize as ingoing or outgoing
            if task["operation_type"] in ["RECEIPT", "TRANSFER"]:
                ingoing_tasks.append(task_summary)
            else:
                outgoing_tasks.append(task_summary)
        
        print(f"✅ DEBUG: Returning {len(ingoing_tasks)} ingoing, {len(outgoing_tasks)} outgoing tasks")
        
        return TaskListResponse(
            ingoing_tasks=ingoing_tasks,
            outgoing_tasks=outgoing_tasks
        )
    
    async def get_task_detail(self, task_id: str, user_id: str) -> TaskDetail:
        """Get detailed task information."""
        # Get task
        task_response = self.db.table("operation_tasks")\
            .select("*")\
            .eq("id", task_id)\
            .execute()
        
        if not task_response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Task not found"
            )
        
        task = task_response.data[0]
        
        # Verify task is assigned to this user
        if task["assigned_to_user_id"] != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to view this task"
            )
        
        # Get order info
        order_response = self.db.table("orders")\
            .select("*")\
            .eq("id", task["order_id"])\
            .execute()
        
        if not order_response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Order not found"
            )
        
        order = order_response.data[0]
        
        # Get order items based on order type
        items = await self._get_order_items(order["id"], order["type"])
        
        # Get product validation checklist
        validations = await self._get_product_validations(order["id"])
        
        # Build chariot info
        chariot_info = None
        if task.get("chariot_id"):
            chariot_response = self.db.table("chariots")\
                .select("*")\
                .eq("id", task["chariot_id"])\
                .execute()
            
            if chariot_response.data:
                chariot = chariot_response.data[0]
                chariot_info = ChariotInfo(
                    id=chariot["id"],
                    code=chariot["code"],
                    is_active=chariot["is_active"],
                    capacity=chariot.get("capacity")
                )
        
        # Build route info
        route_info = None
        if task.get("planned_route_id"):
            route_response = self.db.table("route_plans")\
                .select("*")\
                .eq("id", task["planned_route_id"])\
                .execute()
            
            if route_response.data:
                route_data = route_response.data[0]
                path_nodes = [RouteNode(**node) for node in route_data.get("path_nodes_json", [])]
                route_info = RoutePlan(
                    id=route_data["id"],
                    total_distance_meters=float(route_data["total_distance_meters"]),
                    path_nodes=path_nodes,
                    estimated_time_minutes=self._calculate_estimated_time(
                        float(route_data["total_distance_meters"])
                    )
                )
        
        # Build storage location info based on operation type
        storage_location_info = None
        if task["operation_type"] in ["PICKING", "DELIVERY"]:
            # For outgoing operations, get the expedition zone location
            expedition_response = self.db.table("locations")\
                .select("*")\
                .eq("type", "EXPEDITION")\
                .eq("is_active", True)\
                .limit(1)\
                .execute()
            
            if expedition_response.data:
                loc = expedition_response.data[0]
                storage_location_info = LocationInfo(
                    id=loc["id"],
                    code=loc["code"],
                    type=loc["type"],
                    floor_level=loc.get("floor_level"),
                    row=loc.get("row_num"),
                    col=loc.get("col_num")
                )
        elif task["operation_type"] == "RECEIPT":
            # For RECEIPT, get a target storage location for the items
            # Try to get a specific storage location from the database
            storage_response = self.db.table("locations")\
                .select("*")\
                .eq("type", "STORAGE")\
                .eq("is_active", True)\
                .limit(1)\
                .execute()
            
            if storage_response.data:
                loc = storage_response.data[0]
                storage_location_info = LocationInfo(
                    id=loc["id"],
                    code=loc["code"],
                    type=loc["type"],
                    floor_level=loc.get("floor_level"),
                    row=loc.get("row_num"),
                    col=loc.get("col_num")
                )
        elif task["operation_type"] == "TRANSFER":
            # For TRANSFER, get destination from preparation order
            prep_response = self.db.table("preparation_orders")\
                .select("*, location:locations!destination_storage_location_id(*)")\
                .eq("id", order["id"])\
                .execute()
            
            if prep_response.data and prep_response.data[0].get("location"):
                loc = prep_response.data[0]["location"]
                storage_location_info = LocationInfo(
                    id=loc["id"],
                    code=loc["code"],
                    type=loc["type"],
                    floor_level=loc.get("floor_level"),
                    row=loc.get("row_num"),
                    col=loc.get("col_num")
                )
        
        return TaskDetail(
            id=task["id"],
            order_id=order["id"],
            order_code=self._generate_order_code(order),
            order_type=OrderType(order["type"]),
            order_status=order["status"],
            status=TaskStatus(task["status"]),
            operation_type=OperationType(task["operation_type"]),
            created_at=datetime.fromisoformat(task["created_at"]),
            completed_at=datetime.fromisoformat(task["completed_at"]) if task.get("completed_at") else None,
            validated=task["validated"],
            chariot=chariot_info,
            route=route_info,
            delivery_id=task.get("delivery_id"),
            storage_location=storage_location_info,
            items=items,
            product_validations=validations
        )
    
    async def update_task_status(
        self, 
        task_id: str, 
        user_id: str, 
        request: UpdateTaskStatusRequest
    ) -> TaskDetail:
        """Update task status."""
        # Verify task belongs to user
        task_check = self.db.table("operation_tasks")\
            .select("assigned_to_user_id")\
            .eq("id", task_id)\
            .execute()
        
        if not task_check.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Task not found"
            )
        
        if task_check.data[0]["assigned_to_user_id"] != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to update this task"
            )
        
        # Update status
        update_data = {"status": request.status.value}
        
        if request.status == TaskStatus.DONE:
            update_data["completed_at"] = datetime.utcnow().isoformat()
        
        self.db.table("operation_tasks")\
            .update(update_data)\
            .eq("id", task_id)\
            .execute()
        
        # Return updated task
        return await self.get_task_detail(task_id, user_id)
    
    async def validate_task(
        self, 
        task_id: str, 
        user_id: str, 
        request: ValidateTaskRequest
    ) -> TaskDetail:
        """Validate task completion."""
        # Verify task belongs to user
        task_check = self.db.table("operation_tasks")\
            .select("assigned_to_user_id, status")\
            .eq("id", task_id)\
            .execute()
        
        if not task_check.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Task not found"
            )
        
        task = task_check.data[0]
        
        if task["assigned_to_user_id"] != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to validate this task"
            )
        
        # Update validation status
        update_data = {
            "validated": request.validated,
            "status": TaskStatus.DONE.value,
            "completed_at": datetime.utcnow().isoformat()
        }
        
        self.db.table("operation_tasks")\
            .update(update_data)\
            .eq("id", task_id)\
            .execute()
        
        # Return updated task
        return await self.get_task_detail(task_id, user_id)
    
    async def confirm_placement(
        self, 
        task_id: str, 
        user_id: str, 
        request: ConfirmPlacementRequest
    ) -> dict:
        """Confirm product placement in storage/picking location."""
        # This would create a stock ledger entry
        # For now, return success
        return {
            "success": True,
            "message": f"Placement confirmed for SKU {request.sku_code} in slot {request.target_slot}"
        }
    
    async def _get_task_item_count(self, order_id: str, operation_type: str) -> int:
        """Get count of items in a task."""
        if operation_type == "RECEIPT":
            response = self.db.table("command_order_lines")\
                .select("id", count="exact")\
                .eq("command_order_id", order_id)\
                .execute()
        elif operation_type == "TRANSFER":
            response = self.db.table("preparation_order_lines")\
                .select("id", count="exact")\
                .eq("preparation_order_id", order_id)\
                .execute()
        elif operation_type == "PICKING":
            response = self.db.table("picking_order_lines")\
                .select("id", count="exact")\
                .eq("picking_order_id", order_id)\
                .execute()
        else:
            return 0
        
        return response.count if response.count else 0
    
    async def _get_order_items(self, order_id: str, order_type: str) -> List[OrderLineItem]:
        """Get order line items based on order type."""
        items = []
        
        if order_type == "COMMAND":
            response = self.db.table("command_order_lines")\
                .select("*, sku:skus(*)")\
                .eq("command_order_id", order_id)\
                .execute()
            
            for item in response.data:
                items.append(OrderLineItem(
                    id=item["id"],
                    sku=SKUInfo(
                        id=item["sku"]["id"],
                        sku_code=item["sku"]["sku_code"],
                        name=item["sku"]["name"],
                        weight_kg=float(item["sku"]["weight_kg"])
                    ),
                    quantity=item["qty_received"]
                ))
        
        elif order_type == "PREPARATION":
            response = self.db.table("preparation_order_lines")\
                .select("*, sku:skus(*), location:locations!current_storage_location_id(*)")\
                .eq("preparation_order_id", order_id)\
                .execute()
            
            for item in response.data:
                items.append(OrderLineItem(
                    id=item["id"],
                    sku=SKUInfo(
                        id=item["sku"]["id"],
                        sku_code=item["sku"]["sku_code"],
                        name=item["sku"]["name"],
                        weight_kg=float(item["sku"]["weight_kg"])
                    ),
                    quantity=item["qty_to_deliver"],
                    source_location=LocationInfo(
                        id=item["location"]["id"],
                        code=item["location"]["code"],
                        type=item["location"]["type"]
                    ) if item.get("location") else None
                ))
        
        elif order_type == "PICKING":
            response = self.db.table("picking_order_lines")\
                .select("""
                    *, 
                    sku:skus(*),
                    source:locations!source_storage_location_id(*),
                    dest:locations!destination_picking_location_id(*)
                """)\
                .eq("picking_order_id", order_id)\
                .execute()
            
            for item in response.data:
                items.append(OrderLineItem(
                    id=item["id"],
                    sku=SKUInfo(
                        id=item["sku"]["id"],
                        sku_code=item["sku"]["sku_code"],
                        name=item["sku"]["name"],
                        weight_kg=float(item["sku"]["weight_kg"])
                    ),
                    quantity=item["qty_to_pick"],
                    source_location=LocationInfo(
                        id=item["source"]["id"],
                        code=item["source"]["code"],
                        type=item["source"]["type"]
                    ) if item.get("source") else None,
                    destination_location=LocationInfo(
                        id=item["dest"]["id"],
                        code=item["dest"]["code"],
                        type=item["dest"]["type"]
                    ) if item.get("dest") else None
                ))
        
        return items
    
    async def _get_product_validations(self, order_id: str) -> List[ProductValidationItem]:
        """Get product validation checklist for an order."""
        # This would be stored in a separate table or generated based on order type
        # For now, return sample validations
        return [
            ProductValidationItem(
                description="Quantity verified",
                validated=False
            ),
            ProductValidationItem(
                description="Product type verified",
                validated=False
            )
        ]
    
    def _generate_order_code(self, order: dict) -> str:
        """Generate order code for display."""
        if order["type"] == "COMMAND":
            prefix = "CMD"
        elif order["type"] == "PREPARATION":
            prefix = "PREP"
        elif order["type"] == "PICKING":
            prefix = "PICK"
        elif order["type"] == "DELIVERY":
            prefix = "DEL"
        else:
            prefix = "ORD"
        
        # Extract last 6 chars of UUID
        id_suffix = order["id"][-6:].upper()
        return f"{prefix}-{id_suffix}"
    
    async def _get_task_storage_location(self, task: dict, order_type: str) -> Optional[LocationInfo]:
        """Get storage location for a task based on operation type."""
        try:
            if task["operation_type"] in ["PICKING", "DELIVERY"]:
                # For outgoing operations, get the expedition zone location
                expedition_response = self.db.table("locations")\
                    .select("*")\
                    .eq("type", "EXPEDITION")\
                    .eq("is_active", True)\
                    .limit(1)\
                    .execute()
                
                if expedition_response.data:
                    loc = expedition_response.data[0]
                    return LocationInfo(
                        id=loc["id"],
                        code=loc["code"],
                        type=loc["type"],
                        floor_level=loc.get("floor_level"),
                        row=loc.get("row_num"),
                        col=loc.get("col_num")
                    )
            
            elif task["operation_type"] == "RECEIPT":
                # For RECEIPT, get a target storage location
                storage_response = self.db.table("locations")\
                    .select("*")\
                    .eq("type", "STORAGE")\
                    .eq("is_active", True)\
                    .limit(1)\
                    .execute()
                
                if storage_response.data:
                    loc = storage_response.data[0]
                    return LocationInfo(
                        id=loc["id"],
                        code=loc["code"],
                        type=loc["type"],
                        floor_level=loc.get("floor_level"),
                        row=loc.get("row_num"),
                        col=loc.get("col_num")
                    )
            
            elif task["operation_type"] == "TRANSFER":
                # For TRANSFER, get destination from preparation order
                prep_response = self.db.table("preparation_orders")\
                    .select("*, location:locations!destination_storage_location_id(*)")\
                    .eq("id", task["order_id"])\
                    .execute()
                
                if prep_response.data and prep_response.data[0].get("location"):
                    loc = prep_response.data[0]["location"]
                    return LocationInfo(
                        id=loc["id"],
                        code=loc["code"],
                        type=loc["type"],
                        floor_level=loc.get("floor_level"),
                        row=loc.get("row_num"),
                        col=loc.get("col_num")
                    )
        except Exception as e:
            print(f"⚠️ Warning: Could not get storage location for task {task['id']}: {e}")
        
        return None
    
    def _calculate_estimated_time(self, distance_meters: float) -> int:
        """Calculate estimated time in minutes based on distance."""
        # Assume average walking speed of 1.2 m/s
        time_seconds = distance_meters / 1.2
        return int(time_seconds / 60) + 1  # Round up

