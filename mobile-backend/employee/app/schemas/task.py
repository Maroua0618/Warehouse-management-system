"""Task-related schemas."""
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from app.schemas.common import TaskStatus, OrderType, OrderStatus, OperationType, LocationType


class LocationInfo(BaseModel):
    """Location information."""
    id: str
    code: str
    type: LocationType
    floor_level: Optional[int] = None
    row: Optional[int] = None
    col: Optional[int] = None


class SKUInfo(BaseModel):
    """SKU information."""
    id: str
    sku_code: str
    name: str
    weight_kg: float


class OrderLineItem(BaseModel):
    """Order line item details."""
    id: str
    sku: SKUInfo
    quantity: int
    source_location: Optional[LocationInfo] = None
    destination_location: Optional[LocationInfo] = None


class ChariotInfo(BaseModel):
    """Chariot information."""
    id: str
    code: str
    is_active: bool


class RouteNode(BaseModel):
    """Route path node."""
    x: int
    y: int
    floor_level: int


class RoutePlan(BaseModel):
    """Route plan information."""
    id: str
    total_distance_meters: float
    path_nodes: List[RouteNode]
    estimated_time_minutes: Optional[int] = None


class ProductValidationItem(BaseModel):
    """Product validation checklist item."""
    description: str
    validated: bool


class TaskSummary(BaseModel):
    """Task summary for list view."""
    id: str
    order_id: str
    order_type: OrderType
    status: TaskStatus
    operation_type: OperationType
    created_at: datetime
    item_count: int
    delivery_id: Optional[str] = None


class TaskDetail(BaseModel):
    """Detailed task information."""
    id: str
    order_id: str
    order_code: str
    order_type: OrderType
    order_status: OrderStatus
    status: TaskStatus
    operation_type: OperationType
    created_at: datetime
    completed_at: Optional[datetime] = None
    validated: bool
    
    # Assignment info
    chariot: Optional[ChariotInfo] = None
    route: Optional[RoutePlan] = None
    
    # Order details
    delivery_id: Optional[str] = None
    storage_location: Optional[LocationInfo] = None
    items: List[OrderLineItem] = []
    
    # Validation checklist
    product_validations: List[ProductValidationItem] = []


class TaskListResponse(BaseModel):
    """Task list response."""
    ingoing_tasks: List[TaskSummary]
    outgoing_tasks: List[TaskSummary]


class UpdateTaskStatusRequest(BaseModel):
    """Update task status request."""
    status: TaskStatus
    notes: Optional[str] = None


class ValidateTaskRequest(BaseModel):
    """Validate task completion request."""
    validated: bool = True
    notes: Optional[str] = None


class ProductValidationRequest(BaseModel):
    """Product validation request."""
    validation_items: List[ProductValidationItem]


class ConfirmPlacementRequest(BaseModel):
    """Confirm placement request."""
    sku_code: str
    target_slot: str
    quantity: int
