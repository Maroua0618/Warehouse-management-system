"""Employee-specific routes."""
from fastapi import APIRouter, Depends
from supabase import Client
from app.database import get_db
from app.dependencies import get_current_active_employee
from app.schemas.auth import UserInfo
from app.schemas.employee import EmployeeProfileResponse, EmployeeProfile, PerformanceStats
from datetime import datetime

router = APIRouter(prefix="/employee", tags=["Employee"])


@router.get("/profile", response_model=EmployeeProfileResponse)
async def get_employee_profile(
    current_user: UserInfo = Depends(get_current_active_employee),
    db: Client = Depends(get_db)
):
    """
    Get employee profile with performance statistics.
    
    Returns:
    - Employee information (name, role, zone, shift)
    - Performance metrics (tasks completed, accuracy, efficiency)
    """
    # Get employee profile
    profile = EmployeeProfile(
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
    
    # Calculate performance stats
    # Get completed tasks count
    completed_response = db.table("operation_tasks")\
        .select("id", count="exact")\
        .eq("assigned_to_user_id", current_user.id)\
        .eq("status", "DONE")\
        .execute()
    
    tasks_completed = completed_response.count if completed_response.count else 0
    
    # Get total assigned tasks
    total_response = db.table("operation_tasks")\
        .select("id", count="exact")\
        .eq("assigned_to_user_id", current_user.id)\
        .execute()
    
    total_tasks = total_response.count if total_response.count else 0
    
    # Calculate accuracy and efficiency (simplified for now)
    # In production, these would be calculated from actual task performance data
    accuracy = (tasks_completed / total_tasks * 100) if total_tasks > 0 else 100.0
    efficiency = min(94.0, accuracy)  # Simplified calculation
    
    performance = PerformanceStats(
        tasks_completed=tasks_completed,
        total_tasks=total_tasks,
        accuracy=round(accuracy, 1),
        efficiency=round(efficiency, 1)
    )
    
    return EmployeeProfileResponse(
        profile=profile,
        performance=performance
    )
