"""
Command Orders (Bon de Commande) - Reception of products
Uses existing tables: orders, command_orders, stock_ledger_entries
"""
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


# Command Order (uses orders table with type='COMMAND')
class CommandOrderBase(BaseModel):
    source: str  # supplier name
    status: Optional[str] = "DRAFT"  # DRAFT, VALIDATED, COMPLETED


class CommandOrderCreate(CommandOrderBase):
    pass


class CommandOrderResponse(CommandOrderBase):
    id: str
    order_id: str  # from command_orders table
    reception_at: datetime
    created_at: datetime
    created_by: Optional[str] = None
    validated_by: Optional[str] = None

    class Config:
        from_attributes = True


# Product Lines (uses stock_ledger_entries with operation_type='RECEPTION')
class CommandOrderLineBase(BaseModel):
    sku_id: str
    to_location_id: str  # reception location
    quantity: int  # qty_delta in ledger


class CommandOrderLineCreate(CommandOrderLineBase):
    order_id: str


class CommandOrderLineResponse(CommandOrderLineBase):
    id: str
    order_id: str
    sku_code: Optional[str] = None  # joined from skus table
    sku_name: Optional[str] = None
    location_code: Optional[str] = None  # joined from locations table
    ts: datetime  # timestamp from stock_ledger_entries
    user_id: Optional[str] = None
    user_name: Optional[str] = None

    class Config:
        from_attributes = True


# Full command order with lines
class CommandOrderWithLinesResponse(CommandOrderResponse):
    lines: List[CommandOrderLineResponse] = []

    class Config:
        from_attributes = True
