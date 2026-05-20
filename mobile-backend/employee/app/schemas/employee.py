"""Employee-specific schemas."""
from pydantic import BaseModel
from typing import Optional
from datetime import datetime, time


class EmployeeProfile(BaseModel):
    """Employee profile information."""
    id: str
    name: str
    email: str
    role: str
    status: str
    zone: Optional[str] = None
    shift_start: Optional[str] = None
    shift_end: Optional[str] = None
    duty_status: bool = True


class PerformanceStats(BaseModel):
    """Employee performance statistics."""
    tasks_completed: int
    total_tasks: int
    accuracy: float  # percentage
    efficiency: float  # percentage


class EmployeeProfileResponse(BaseModel):
    """Complete employee profile with stats."""
    profile: EmployeeProfile
    performance: PerformanceStats


class ShiftInfo(BaseModel):
    """Shift information."""
    zone: str
    shift_start: str
    shift_end: str
    duty_status: bool


class UpdateDutyStatusRequest(BaseModel):
    """Update duty status request."""
    duty_status: bool
