"""Helper utilities."""
from datetime import datetime
from typing import Optional
import uuid


def generate_uuid() -> str:
    """Generate a new UUID string."""
    return str(uuid.uuid4())


def format_datetime(dt: Optional[datetime]) -> Optional[str]:
    """Format datetime to ISO string."""
    if dt is None:
        return None
    return dt.isoformat()


def parse_uuid(value: str) -> Optional[uuid.UUID]:
    """Parse UUID string safely."""
    try:
        return uuid.UUID(value)
    except (ValueError, AttributeError):
        return None
