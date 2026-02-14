"""
Bon de Préparation - Preparation slips for delivery
Uses existing tables: orders (type='PREPARATION'), deliveries, stock_ledger_entries
"""
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime, date


# Bon de Préparation (uses orders table with type='PREPARATION')
class BonDePreparationBase(BaseModel):
    client_name: str  # stored in source field
    delivery_id: Optional[int] = None
    dispatch_date: Optional[date] = None
    status: Optional[str] = "DRAFT"  # DRAFT, VALIDATED, IN_PROGRESS, COMPLETED


class BonDePreparationCreate(BonDePreparationBase):
    pass


class BonDePreparationUpdate(BaseModel):
    status: Optional[str] = None
    assigned_to_user_id: Optional[str] = None
    dispatch_date: Optional[date] = None


class BonDePreparationResponse(BonDePreparationBase):
    id: str  # orders.id
    bon_number: str  # generated (e.g., BDP-2026-001)
    created_at: datetime
    created_by: Optional[str] = None
    assigned_to_user_id: Optional[str] = None
    assigned_user_name: Optional[str] = None  # joined from users
    
    # Delivery info
    delivery_status: Optional[str] = None  # from deliveries table

    class Config:
        from_attributes = True


# Preparation Item (from stock_ledger_entries with operation_type='PREPARATION')  
class PreparationItemBase(BaseModel):
    sku_id: str
    from_location_id: str  # storage location
    to_location_id: str  # picking zone location
    quantity: int


class PreparationItemCreate(PreparationItemBase):
    bon_id: str  # orders.id


class PreparationItemResponse(PreparationItemBase):
    id: str  # stock_ledger_entries.id
    bon_id: str
    order_id: str  # same as bon_id
    ts: datetime
    user_id: Optional[str] = None
    
    # Joined SKU info
    sku_code: Optional[str] = None
    sku_name: Optional[str] = None
    sku_weight: Optional[float] = None
    
    # Joined location info  
    from_location_code: Optional[str] = None  # storage
    to_location_code: Optional[str] = None  # picking zone
    
    # Picked status (derived from ledger entry existence)
    picked: bool = False

    class Config:
        from_attributes = True


# Full bon with items
class BonDePreparationWithItemsResponse(BonDePreparationResponse):
    items: List[PreparationItemResponse] = []
    total_items: int = 0
    picked_items: int = 0

    class Config:
        from_attributes = True


# Assign employee to bon
class AssignBonDePreparationRequest(BaseModel):
    employee_id: str
    equipment_id: Optional[str] = None  # chariot_id
