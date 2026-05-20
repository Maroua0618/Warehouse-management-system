"""Issue reporting service."""
from typing import List
from supabase import Client
from fastapi import HTTPException, status
from app.schemas.issue import (
    CreateIssueRequest, IssueResponse, IssueType, 
    IssueCategory, IssueTypesResponse
)
from datetime import datetime
import uuid


class IssueService:
    """Issue reporting service."""
    
    def __init__(self, db: Client):
        self.db = db
    
    async def get_issue_types(self) -> IssueTypesResponse:
        """Get available issue types/categories."""
        operational_categories = [
            IssueType(
                id="damaged_products",
                name="Damaged Products",
                description="Physical damage to items or packaging",
                category=IssueCategory.DAMAGED_PRODUCTS
            ),
            IssueType(
                id="wrong_quantity",
                name="Wrong Quantity Delivered",
                description="Received count doesn't match manifest",
                category=IssueCategory.WRONG_QUANTITY
            ),
            IssueType(
                id="wrong_sku",
                name="Wrong SKU Delivered",
                description="Incorrect item variant or product code",
                category=IssueCategory.WRONG_SKU
            ),
            IssueType(
                id="storage_error",
                name="Storage Assignment Error",
                description="Item placed in wrong bin or zone",
                category=IssueCategory.STORAGE_ASSIGNMENT_ERROR
            ),
            IssueType(
                id="workflow_bottleneck",
                name="Workflow Bottleneck",
                description="Processing delay or equipment failure",
                category=IssueCategory.WORKFLOW_BOTTLENECK
            ),
            IssueType(
                id="stock_availability",
                name="Stock Availability Problem",
                description="Discrepancy in digital vs physical inventory",
                category=IssueCategory.STOCK_AVAILABILITY
            ),
        ]
        
        return IssueTypesResponse(operational_categories=operational_categories)
    
    async def create_issue(
        self, 
        user_id: str, 
        request: CreateIssueRequest
    ) -> IssueResponse:
        """Create a new issue report."""
        # Verify task exists and belongs to user
        task_response = self.db.table("operation_tasks")\
            .select("id, assigned_to_user_id, order_id")\
            .eq("id", request.task_id)\
            .execute()
        
        if not task_response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Task not found"
            )
        
        task = task_response.data[0]
        
        if task["assigned_to_user_id"] != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to report issues for this task"
            )
        
        # Create issue in audit_logs table (or create a separate issues table)
        issue_id = str(uuid.uuid4())
        issue_data = {
            "id": issue_id,
            "ts": datetime.utcnow().isoformat(),
            "actor_user_id": user_id,
            "action_type": "ISSUE_REPORT",
            "entity_type": "TASK",
            "entity_id": request.task_id,
            "details": {
                "category": request.category.value,
                "description": request.description,
                "order_id": request.order_id or task["order_id"],
                "status": "PENDING"
            }
        }
        
        self.db.table("audit_logs").insert(issue_data).execute()
        
        # Get user name
        user_response = self.db.table("users")\
            .select("name")\
            .eq("id", user_id)\
            .execute()
        
        user_name = user_response.data[0]["name"] if user_response.data else "Unknown"
        
        return IssueResponse(
            id=issue_id,
            task_id=request.task_id,
            order_id=request.order_id or task["order_id"],
            category=request.category,
            description=request.description,
            reported_by=user_name,
            created_at=datetime.utcnow(),
            status="PENDING"
        )
