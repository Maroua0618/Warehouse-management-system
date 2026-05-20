"""
warehouse/types.py
──────────────────
Core data types for the warehouse grid model.

- Kind   : enum classifying what a cell represents
- Cell   : dataclass holding both static layout and dynamic state
"""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import Optional


class Kind(Enum):
    """Classification of every 1 m × 1 m cell in the warehouse grid."""

    VOID = "VOID"            # Outside the building envelope — not walkable, not usable
    OBSTACLE = "OBSTACLE"    # Structural pillar, wall, rack frame — never walkable
    CORRIDOR = "CORRIDOR"    # Aisle / passage — always walkable (unless blocked)
    STORAGE = "STORAGE"      # Pallet footprint — walkable depends on occupancy + policy
    CONNECTOR = "CONNECTOR"  # Elevator or monte-charge — enables vertical movement


@dataclass
class Cell:
    """
    Represents a single 1 m × 1 m tile on a warehouse floor.

    Attributes
    ──────────
    Static / layout info:
        kind           : what the cell is (see Kind enum)
        connector_id   : only for CONNECTOR cells — e.g. "elevator", "mc1", "mc2"
        slot_code      : region label such as "C7", "E14" (many cells share one code)
        capacity       : how many pallets this cell can hold (1 for STORAGE, else 0)
        base_cost      : movement cost for pathfinding (≥ 1.0)

    Dynamic / runtime info:
        occupied       : True when a pallet is physically present
        blocked        : True when cell is temporarily out of service (maintenance)
        _reserved      : placeholder for future interference / reservation logic
    """

    # ── static ────────────────────────────────────────────
    kind: Kind = Kind.VOID
    connector_id: Optional[str] = None
    slot_code: Optional[str] = None
    capacity: int = 0
    base_cost: float = 1.0

    # ── dynamic ───────────────────────────────────────────
    occupied: bool = False
    blocked: bool = False

    # Future: reservation token / timestamp.  Not used yet.
    _reserved: Optional[str] = field(default=None, repr=False)

    # ── helpers ───────────────────────────────────────────

    def __post_init__(self) -> None:
        """Auto-fix capacity for non-storage cells."""
        if self.kind != Kind.STORAGE:
            self.capacity = 0