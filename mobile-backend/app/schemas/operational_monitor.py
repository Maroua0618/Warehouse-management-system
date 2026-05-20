"""
Operational Monitor - Real-time tracking and alerts
Uses existing tables: users, operation_tasks, ai_recommendations, override_decisions
"""
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class EmployeeStatus(str, Enum):
    ACTIVE = "ACTIVE"
    IDLE = "IDLE"
    BREAK = "BREAK"
    OFFLINE = "OFFLINE"


class AlertType(str, Enum):
    LOW_STOCK = "LOW_STOCK"
    TASK_DELAY = "TASK_DELAY"
    EQUIPMENT_ISSUE = "EQUIPMENT_ISSUE"
    PERFORMANCE_WARNING = "PERFORMANCE_WARNING"
    OVERRIDE_PENDING = "OVERRIDE_PENDING"


# Employee Tracking (from users table + operation_tasks)
class EmployeeTrackingBase(BaseModel):
    id: str
    name: str
    email: str
    role: str
    status: EmployeeStatus
    current_zone: Optional[str] = None


class EmployeeTrackingResponse(EmployeeTrackingBase):
    # Active tasks
    active_tasks: int = 0
    completed_tasks_today: int = 0
    
    # Current task (if any)
    current_task_id: Optional[str] = None
    current_task_type: Optional[str] = None
    current_task_status: Optional[str] = None
    
    # Last activity
    last_active: Optional[datetime] = None

    class Config:
        from_attributes = True


# Operational Alert (from ai_recommendations with type='ALERT_*')
class OperationalAlertBase(BaseModel):
    alert_type: str  # matches recommendation_type
    priority: str  # LOW, MEDIUM, HIGH
    title: str
    description: str


class OperationalAlertResponse(OperationalAlertBase):
    id: str  # ai_recommendations.id
    created_at: datetime
    status: str  # ACTIVE, RESOLVED
    
    # Related entities
    order_id: Optional[str] = None
    task_id: Optional[str] = None
    delivery_id: Optional[int] = None
    
    # Full payload
    payload_json: Dict[str, Any]
    
    # Can be resolved?
    can_resolve: bool = True

    class Config:
        from_attributes = True


# Execution Progress (aggregated from operation_tasks)
class ExecutionProgressBase(BaseModel):
    label: str  # e.g., "Storage", "Picking", "Preparation"
    completed: int
    total: int
    percentage: float


# Operational Stats (aggregated queries)
class OperationalStatsResponse(BaseModel):
    # Employee metrics
    active_employees: int
    idle_employees: int
    
    # Task metrics
    pending_tasks: int
    in_progress_tasks: int
    completed_tasks_today: int
    
    # Alert metrics
    active_alerts: int
    pending_overrides: int
    
    # Execution progress by operation type
    execution_progress: List[ExecutionProgressBase] = []
    
    # Performance metrics
    avg_task_completion_time_minutes: Optional[float] = None
    delayed_tasks: int = 0

    class Config:
        from_attributes = True
