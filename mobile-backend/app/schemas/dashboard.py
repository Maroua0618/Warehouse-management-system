from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class OperationalIssueBase(BaseModel):
    issue_type: str
    priority: str
    employee_name: str
    title: str
    description: str

class OperationalIssueCreate(OperationalIssueBase):
    pass

class OperationalIssueResponse(OperationalIssueBase):
    id: str
    status: str
    created_at: datetime
    resolved_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True

class DashboardStats(BaseModel):
    active_employees: int
    pending_violations: int
    orders_today: int
    ai_overrides: int
    saved_today_meters: float
    performance_percentage: float

class RecentActivity(BaseModel):
    id: str
    type: str
    title: str
    description: str
    timestamp: datetime
    status: Optional[str] = None
