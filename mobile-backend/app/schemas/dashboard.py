"""
Dashboard - Supervisor overview statistics
Uses existing tables: users, orders, operation_tasks, audit_logs, override_decisions, ai_recommendations
"""
from pydantic import BaseModel
from typing import Optional
from datetime import datetime


# Dashboard Statistics (aggregated from multiple tables)
class DashboardStats(BaseModel):
    # Employee metrics (from users table)
    active_employees: int
    
    # Violation/Override metrics (from override_decisions table)
    pending_violations: int  # status='PENDING'
    
    # Order metrics (from orders table)
    orders_today: int
    
    # AI metrics (from ai_recommendations + override_decisions)
    ai_overrides: int  # count of override_decisions
    
    # Performance metrics (calculated)
    saved_today_meters: float  # from AI recommendations
    performance_percentage: float  # overall efficiency


# Recent Activity (from audit_logs table)
class RecentActivity(BaseModel):
    id: str  # audit_logs.id
    type: str  # activity type (e.g., MANUAL_OVERRIDE, BULK_RECEIPT, etc.)
    title: str  # human-readable title
    description: str  # activity description
    timestamp: datetime  # when the activity occurred
    status: Optional[str] = None  # optional status
    timestamp: datetime  # audit_logs.ts
    status: Optional[str] = None
    details: Optional[dict] = None  # audit_logs.details

    class Config:
        from_attributes = True


# Operational Issue/Alert (from ai_recommendations with type starting with 'ALERT_')
class OperationalIssueBase(BaseModel):
    issue_type: str  # recommendation_type
    priority: str  # extracted from payload
    title: str
    description: str
    employee_name: Optional[str] = None


class OperationalIssueCreate(OperationalIssueBase):
    order_id: Optional[str] = None
    task_id: Optional[str] = None
    delivery_id: Optional[int] = None
    payload_json: dict = {}


class OperationalIssueResponse(OperationalIssueBase):
    id: str  # ai_recommendations.id
    status: str  # ACTIVE or RESOLVED
    created_at: datetime
    resolved_at: Optional[datetime] = None
    
    # Related entities
    order_id: Optional[str] = None
    task_id: Optional[str] = None
    delivery_id: Optional[int] = None

    class Config:
        from_attributes = True
