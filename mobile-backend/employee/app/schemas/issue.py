"""Issue reporting schemas."""
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from enum import Enum


class IssueCategory(str, Enum):
    """Issue category types."""
    DAMAGED_PRODUCTS = "DAMAGED_PRODUCTS"
    WRONG_QUANTITY = "WRONG_QUANTITY"
    WRONG_SKU = "WRONG_SKU"
    STORAGE_ASSIGNMENT_ERROR = "STORAGE_ASSIGNMENT_ERROR"
    WORKFLOW_BOTTLENECK = "WORKFLOW_BOTTLENECK"
    STOCK_AVAILABILITY = "STOCK_AVAILABILITY"
    EQUIPMENT_FAILURE = "EQUIPMENT_FAILURE"
    OTHER = "OTHER"


class IssueType(BaseModel):
    """Issue type definition."""
    id: str
    name: str
    description: str
    category: IssueCategory


class CreateIssueRequest(BaseModel):
    """Create issue report request."""
    task_id: str
    order_id: Optional[str] = None
    category: IssueCategory
    description: str = Field(..., min_length=10, max_length=1000)


class IssueResponse(BaseModel):
    """Issue report response."""
    id: str
    task_id: str
    order_id: Optional[str] = None
    category: IssueCategory
    description: str
    reported_by: str
    created_at: datetime
    status: str = "PENDING"


class IssueTypesResponse(BaseModel):
    """Available issue types response."""
    operational_categories: list[IssueType]
