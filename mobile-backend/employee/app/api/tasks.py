"""Task management routes."""
from fastapi import APIRouter, Depends, Path
from supabase import Client
from app.database import get_db
from app.dependencies import get_current_active_employee
from app.schemas.auth import UserInfo
from app.schemas.task import (
    TaskListResponse, TaskDetail, UpdateTaskStatusRequest, 
    ValidateTaskRequest, ConfirmPlacementRequest
)
from app.schemas.issue import CreateIssueRequest, IssueResponse, IssueTypesResponse
from app.services.task_service import TaskService
from app.services.issue_service import IssueService

router = APIRouter(prefix="/tasks", tags=["Tasks"])


@router.get("", response_model=TaskListResponse)
async def get_employee_tasks(
    current_user: UserInfo = Depends(get_current_active_employee),
    db: Client = Depends(get_db)
):
    """
    Get all tasks assigned to the current employee.
    
    Returns tasks categorized as:
    - Ingoing orders (RECEIPT, TRANSFER)
    - Outgoing orders (PICKING, DELIVERY)
    """
    task_service = TaskService(db)
    return await task_service.get_employee_tasks(current_user.id)


@router.get("/{task_id}", response_model=TaskDetail)
async def get_task_detail(
    task_id: str = Path(..., description="Task ID"),
    current_user: UserInfo = Depends(get_current_active_employee),
    db: Client = Depends(get_db)
):
    """
    Get detailed information for a specific task.
    
    Includes:
    - Order details and line items
    - Route/path information
    - Chariot assignment
    - Product validation checklist
    - Storage/picking locations
    """
    task_service = TaskService(db)
    return await task_service.get_task_detail(task_id, current_user.id)


@router.put("/{task_id}/status", response_model=TaskDetail)
async def update_task_status(
    request: UpdateTaskStatusRequest,
    task_id: str = Path(..., description="Task ID"),
    current_user: UserInfo = Depends(get_current_active_employee),
    db: Client = Depends(get_db)
):
    """
    Update task status.
    
    Status transitions:
    - ASSIGNED -> IN_PROGRESS (when employee starts task)
    - IN_PROGRESS -> DONE (when employee completes task)
    """
    task_service = TaskService(db)
    return await task_service.update_task_status(task_id, current_user.id, request)


@router.post("/{task_id}/validate", response_model=TaskDetail)
async def validate_task(
    request: ValidateTaskRequest,
    task_id: str = Path(..., description="Task ID"),
    current_user: UserInfo = Depends(get_current_active_employee),
    db: Client = Depends(get_db)
):
    """
    Validate and complete a task.
    
    This endpoint is called when employee confirms all validations
    and completes the task (e.g., "Validate & Complete" button).
    """
    task_service = TaskService(db)
    return await task_service.validate_task(task_id, current_user.id, request)


@router.post("/{task_id}/confirm-placement")
async def confirm_placement(
    request: ConfirmPlacementRequest,
    task_id: str = Path(..., description="Task ID"),
    current_user: UserInfo = Depends(get_current_active_employee),
    db: Client = Depends(get_db)
):
    """
    Confirm product placement in storage or picking location.
    
    Used for:
    - Storage assignment (confirming SKU placed in target slot)
    - Delivery placement (confirming products at expedition track)
    """
    task_service = TaskService(db)
    return await task_service.confirm_placement(task_id, current_user.id, request)


@router.get("/{task_id}/route")
async def get_task_route(
    task_id: str = Path(..., description="Task ID"),
    current_user: UserInfo = Depends(get_current_active_employee),
    db: Client = Depends(get_db)
):
    """
    Get route/path information for a task.
    
    Returns optimized path from current location to destination.
    """
    task_service = TaskService(db)
    task_detail = await task_service.get_task_detail(task_id, current_user.id)
    
    if not task_detail.route:
        return {"message": "No route available for this task"}
    
    return task_detail.route


# Issue Reporting Routes
@router.get("/issues/types", response_model=IssueTypesResponse, tags=["Issues"])
async def get_issue_types(
    current_user: UserInfo = Depends(get_current_active_employee),
    db: Client = Depends(get_db)
):
    """
    Get available issue types/categories for reporting.
    
    Returns operational issue categories like:
    - Damaged Products
    - Wrong Quantity Delivered
    - Wrong SKU Delivered
    - Storage Assignment Error
    - Workflow Bottleneck
    - Stock Availability Problem
    """
    issue_service = IssueService(db)
    return await issue_service.get_issue_types()


@router.post("/{task_id}/report-issue", response_model=IssueResponse, tags=["Issues"])
async def report_issue(
    request: CreateIssueRequest,
    task_id: str = Path(..., description="Task ID"),
    current_user: UserInfo = Depends(get_current_active_employee),
    db: Client = Depends(get_db)
):
    """
    Report an issue for a specific task.
    
    The report is sent to the floor supervisor for review.
    Employee will be notified once the issue is reviewed.
    """
    # Ensure task_id in request matches path parameter
    request.task_id = task_id
    
    issue_service = IssueService(db)
    return await issue_service.create_issue(current_user.id, request)
