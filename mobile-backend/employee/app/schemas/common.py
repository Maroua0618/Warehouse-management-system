"""Common schemas and base models."""
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from enum import Enum


class RoleType(str, Enum):
    """User role types."""
    ADMIN = "ADMIN"
    SUPERVISOR = "SUPERVISOR"
    EMPLOYEE = "EMPLOYEE"


class OrderType(str, Enum):
    """Order types."""
    COMMAND = "COMMAND"
    PREPARATION = "PREPARATION"
    PICKING = "PICKING"
    DELIVERY = "DELIVERY"


class OrderStatus(str, Enum):
    """Order status."""
    DRAFT = "DRAFT"
    GENERATED = "GENERATED"
    VALIDATED = "VALIDATED"
    IN_PROGRESS = "IN_PROGRESS"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"
    CANCELLED = "CANCELLED"


class TaskStatus(str, Enum):
    """Task status."""
    PENDING = "PENDING"
    ASSIGNED = "ASSIGNED"
    IN_PROGRESS = "IN_PROGRESS"
    DONE = "DONE"
    BLOCKED = "BLOCKED"
    CANCELLED = "CANCELLED"


class OperationType(str, Enum):
    """Operation types."""
    RECEIPT = "RECEIPT"
    TRANSFER = "TRANSFER"
    PICKING = "PICKING"
    DELIVERY = "DELIVERY"


class DeliveryStatus(str, Enum):
    """Delivery status."""
    IDLE = "IDLE"
    IN_PROGRESS = "IN_PROGRESS"
    DONE = "DONE"
    FAILED = "FAILED"


class LocationType(str, Enum):
    """Location types."""
    PICKING = "PICKING"
    STORAGE = "STORAGE"
    EXPEDITION = "EXPEDITION"
    RECEPTION = "RECEPTION"
    OTHER = "OTHER"


class ResponseMessage(BaseModel):
    """Generic response message."""
    message: str
    success: bool = True


class PaginationParams(BaseModel):
    """Pagination parameters."""
    page: int = 1
    page_size: int = 20
    
    @property
    def offset(self) -> int:
        return (self.page - 1) * self.page_size
