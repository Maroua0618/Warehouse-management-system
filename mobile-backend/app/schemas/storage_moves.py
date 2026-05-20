"""
Storage Moves - Move products from reception to storage
Uses existing tables: operation_tasks, stock_ledger_entries, ai_recommendations
"""
from pydantic import BaseModel
from typing import Optional, Dict, Any
from datetime import datetime
from enum import Enum


class TaskStatus(str, Enum):
    PENDING = "PENDING"
    IN_PROGRESS = "IN_PROGRESS"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"


class PriorityLevel(str, Enum):
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"


class OverrideStatus(str, Enum):
    PENDING = "PENDING"
    APPROVED = "APPROVED"
    REJECTED = "REJECTED"


# Storage Move Task (uses operation_tasks table with operation_type='STORAGE')
class StorageMoveBase(BaseModel):
    order_id: Optional[str] = None  # link to command order
    sku_id: str  # which product to move
    from_location_id: str  # source (usually reception)
    to_location_id: Optional[str] = None  # destination (storage) - can be AI-suggested
    quantity: int
    priority: Optional[PriorityLevel] = PriorityLevel.MEDIUM


class StorageMoveCreate(StorageMoveBase):
    pass


class StorageMoveUpdate(BaseModel):
    status: Optional[TaskStatus] = None
    assigned_to_user_id: Optional[str] = None
    to_location_id: Optional[str] = None  # can update destination
    chariot_id: Optional[str] = None


class StorageMoveResponse(StorageMoveBase):
    id: str  # operation_tasks.id
    status: TaskStatus
    assigned_to_user_id: Optional[str] = None
    assigned_user_name: Optional[str] = None  # joined from users
    chariot_id: Optional[str] = None
    chariot_code: Optional[str] = None  # joined from chariots
    planned_route_id: Optional[str] = None
    created_at: datetime
    completed_at: Optional[datetime] = None
    
    # Joined SKU info
    sku_code: Optional[str] = None
    sku_name: Optional[str] = None
    
    # Joined location info
    from_location_code: Optional[str] = None
    to_location_code: Optional[str] = None
    
    # AI recommendation (if available)
    ai_recommendation: Optional[Dict[str, Any]] = None

    class Config:
        from_attributes = True


# AI Storage Recommendation Request
class StorageRecommendationRequest(BaseModel):
    sku_id: str
    sku_weight: float
    quantity: int
    from_location_id: str  # current location (reception)


# AI Storage Recommendation Response (from ai_recommendations table)
class StorageRecommendationResponse(BaseModel):
    recommendation_id: str
    assigned_slot: str  # location code
    location_id: str
    floor: int
    zone: str
    abc_class: str  # A, B, or C
    score: float  # 0-1 optimization score
    distance_meters: Optional[float] = None
    estimated_time_seconds: Optional[int] = None
    
    # Full AI payload
    payload_json: Dict[str, Any]

    class Config:
        from_attributes = True


# Assignment Schemas
class AssignStorageMoveRequest(BaseModel):
    employee_id: str
    chariot_id: Optional[str] = None


# Override Schemas (uses override_decisions table)
class OverrideRecommendationRequest(BaseModel):
    recommendation_id: str
    new_destination_id: str
    justification: str
    user_id: str


class OverrideDecisionResponse(BaseModel):
    id: str
    recommendation_id: str
    status: OverrideStatus
    overridden_by_user_id: str
    overridden_by_user_name: Optional[str] = None  # joined from users
    justification: str
    final_payload_json: Dict[str, Any]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# Shared SKU/Location response models
class SKUResponse(BaseModel):
    id: str
    sku_code: str
    name: str
    weight_kg: float

    class Config:
        from_attributes = True


class LocationResponse(BaseModel):
    id: str
    code: str
    type: str
    is_active: bool
    floor_id: Optional[str] = None

    class Config:
        from_attributes = True
