"""
Picking Tasks (Bon de Picking) - Optimized picking routes for deliveries
Uses existing tables: operation_tasks (operation_type='PICKING'), deliveries, route_plans, ai_recommendations
"""
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class TaskStatus(str, Enum):
    PENDING = "PENDING"
    IN_PROGRESS = "IN_PROGRESS"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"


# Picking Task (uses operation_tasks table with operation_type='PICKING')
class PickingTaskBase(BaseModel):
    delivery_id: int
    bon_de_preparation_id: Optional[str] = None  # link to preparation order
    destination_picking_location_id: Optional[str] = None  # final picking zone


class PickingTaskCreate(PickingTaskBase):
    pass


class PickingTaskUpdate(BaseModel):
    status: Optional[str] = None
    assigned_to_user_id: Optional[str] = None
    chariot_id: Optional[str] = None


class PickingTaskResponse(PickingTaskBase):
    id: str  # operation_tasks.id
    status: str
    assigned_to_user_id: Optional[str] = None
    assigned_user_name: Optional[str] = None  # joined from users
    chariot_id: Optional[str] = None
    chariot_code: Optional[str] = None  # joined from chariots
    planned_route_id: Optional[str] = None
    created_at: datetime
    completed_at: Optional[datetime] = None
    
    # Delivery info
    delivery_status: Optional[str] = None  # from deliveries table
    
    # Route info (from route_plans table)
    total_distance_meters: Optional[float] = None
    path_nodes: Optional[List[Dict[str, Any]]] = None  # path_nodes_json from route_plans
    
    # Destination location info
    destination_location_code: Optional[str] = None

    class Config:
        from_attributes = True


# Picking Step (individual stop in the route)
class PickingStepBase(BaseModel):
    sku_id: str
    from_location_id: str  # where to pick from
    quantity: int
    sequence: int  # order in route


class PickingStepResponse(PickingStepBase):
    sku_code: Optional[str] = None
    sku_name: Optional[str] = None
    location_code: Optional[str] = None
    picked: bool = False

    class Config:
        from_attributes = True


# Full picking task with steps
class PickingTaskWithStepsResponse(PickingTaskResponse):
    steps: List[PickingStepResponse] = []
    total_items: int = 0
    picked_items: int = 0

    class Config:
        from_attributes = True


# AI Picking Route Optimization Request
class PickingRouteOptimizationRequest(BaseModel):
    delivery_id: int
    start_location_id: str  # starting point (e.g., receiving area)
    items: List[Dict[str, Any]]  # list of {sku_id, location_id, quantity}


# AI Picking Route Response (from ai_recommendations table)
class PickingRouteOptimizationResponse(BaseModel):
    recommendation_id: str
    delivery_id: int
    route: List[Dict[str, Any]]  # optimized sequence
    total_distance_meters: float
    estimated_time_seconds: int
    optimization_score: float
    
    # Full AI payload
    payload_json: Dict[str, Any]

    class Config:
        from_attributes = True


# Worker and Equipment responses
class WorkerResponse(BaseModel):
    id: str
    name: str
    email: str
    role: str
    status: str
    is_available: bool = True

    class Config:
        from_attributes = True


class EquipmentResponse(BaseModel):
    id: str  # chariot_id
    code: str
    is_active: bool
    capacity: Optional[int] = None

    class Config:
        from_attributes = True


# Assign worker/equipment to picking task
class AssignPickingTaskRequest(BaseModel):
    worker_id: str
    equipment_id: Optional[str] = None
