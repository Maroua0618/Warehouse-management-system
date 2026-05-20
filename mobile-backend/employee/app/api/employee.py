"""Employee-specific routes."""
from fastapi import APIRouter, Depends
from supabase import Client
from app.database import get_db
from app.dependencies import get_current_active_employee
from app.schemas.auth import UserInfo
from app.schemas.employee import EmployeeProfileResponse, EmployeeProfile, PerformanceStats
from datetime import datetime

router = APIRouter(prefix="/employee", tags=["Employee"])


@router.get("/profile", response_model=EmployeeProfile)
async def get_employee_profile(
    current_user: UserInfo = Depends(get_current_active_employee),
    db: Client = Depends(get_db)
):
    """
    Get employee profile information.
    
    Returns:
    - Employee information (name, role, email, status)
    """
    # Return simple profile
    return EmployeeProfile(
        id=current_user.id,
        name=current_user.name,
        email=current_user.email,
        role=current_user.role.value,
        status=current_user.status,
        zone="North Zone",  # TODO: Get from database
        shift_start="08:00",
        shift_end="16:00",
        duty_status=True
    )


@router.get("/stats")
async def get_employee_stats(
    current_user: UserInfo = Depends(get_current_active_employee),
    db: Client = Depends(get_db)
):
    """
    Get employee performance statistics.
    
    Returns:
    - Task counts (total, completed, in progress, pending)
    - Completion rate
    - Total items handled
    """
    # Get completed tasks count
    completed_response = db.table("operation_tasks")\
        .select("id", count="exact")\
        .eq("assigned_to_user_id", current_user.id)\
        .eq("status", "DONE")\
        .execute()
    
    completed_tasks = completed_response.count if completed_response.count else 0
    
    # Get in progress tasks
    in_progress_response = db.table("operation_tasks")\
        .select("id", count="exact")\
        .eq("assigned_to_user_id", current_user.id)\
        .eq("status", "IN_PROGRESS")\
        .execute()
    
    in_progress_tasks = in_progress_response.count if in_progress_response.count else 0
    
    # Get pending tasks (PENDING + ASSIGNED)
    pending_response = db.table("operation_tasks")\
        .select("id", count="exact")\
        .eq("assigned_to_user_id", current_user.id)\
        .in_("status", ["PENDING", "ASSIGNED"])\
        .execute()
    
    pending_tasks = pending_response.count if pending_response.count else 0
    
    # Get total assigned tasks
    total_response = db.table("operation_tasks")\
        .select("id", count="exact")\
        .eq("assigned_to_user_id", current_user.id)\
        .execute()
    
    total_tasks = total_response.count if total_response.count else 0
    
    # Get total items handled from order line items
    items_response = db.table("operation_tasks")\
        .select("order_line_items!operation_tasks_order_line_items_fkey(quantity)")\
        .eq("assigned_to_user_id", current_user.id)\
        .eq("status", "DONE")\
        .execute()
    
    total_items_handled = 0
    if items_response.data:
        for task in items_response.data:
            if task.get('order_line_items'):
                for item in task['order_line_items']:
                    total_items_handled += item.get('quantity', 0)
    
    # Calculate completion rate
    completion_rate = (completed_tasks / total_tasks * 100) if total_tasks > 0 else 0.0
    
    return {
        "total_tasks": total_tasks,
        "completed_tasks": completed_tasks,
        "in_progress_tasks": in_progress_tasks,
        "pending_tasks": pending_tasks,
        "completion_rate": round(completion_rate, 1),
        "total_items_handled": total_items_handled
    }


@router.get("/tasks")
async def get_employee_tasks(
    type: str = None,  # Optional task type filter (RECEIPT, DELIVERY, PICKING)
    current_user: UserInfo = Depends(get_current_active_employee),
    db: Client = Depends(get_db)
):
    """
    Get employee tasks/commands.
    
    Query Parameters:
    - type: Task type filter (RECEIPT, DELIVERY, PICKING)
    
    Returns:
    - List of tasks/commands assigned to the employee
    """
    query = db.table("operation_tasks")\
        .select(
            "id,"
            "operation_id,"
            "status,"
            "task_type,"
            "priority,"
            "created_at,"
            "updated_at,"
            "orders!operation_tasks_order_id_fkey(id, external_id, status, location_id, total_quantity, created_at),"
            "order_line_items!operation_tasks_order_line_item_id_fkey(id, product_id, quantity, location_id)"
        )\
        .eq("assigned_to_user_id", current_user.id)
    
    # Filter by task type if provided
    if type:
        query = query.eq("task_type", type.upper())
    
    # Get tasks
    response = query.limit(50).execute()
    
    # Format tasks for mobile app
    formatted_tasks = []
    if response.data:
        for task in response.data:
            order = task.get('orders', {})
            line_items = task.get('order_line_items', [])
            
            # Calculate total items
            total_items = sum(item.get('quantity', 0) for item in line_items)
            
            # Determine task status in French
            task_status = task.get('status', 'PENDING')
            french_status = {
                'PENDING': 'EN ATTENTE',
                'ASSIGNED': 'EN ATTENTE', 
                'IN_PROGRESS': 'EN COURS',
                'DONE': 'VALIDÉ',
                'CANCELLED': 'ANNULÉ'
            }.get(task_status, 'EN ATTENTE')
            
            # Create display order ID
            display_order_id = f"ORD-{order.get('external_id', order.get('id', 'UNKNOWN'))}"
            
            # Format location
            location_id = order.get('location_id') or (line_items[0].get('location_id') if line_items else None)
            display_location = f"Zone-{location_id}" if location_id else "A-14"
            
            formatted_task = {
                "id": task['id'],
                "orderId": task['id'],
                "displayOrderId": display_order_id,
                "displayLocation": display_location,
                "totalItems": total_items,
                "frenchStatus": french_status,
                "displayTime": task.get('created_at', ''),
                "isValidated": task_status == 'DONE',
                "type": task.get('task_type', 'UNKNOWN'),
                "status": task_status,
                "priority": task.get('priority', 'NORMAL'),
                "createdAt": task.get('created_at'),
                "updatedAt": task.get('updated_at')
            }
            
            formatted_tasks.append(formatted_task)
    
    return formatted_tasks
