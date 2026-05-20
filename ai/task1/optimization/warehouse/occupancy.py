"""
warehouse/occupancy.py
──────────────────────
Helpers to query and mutate dynamic cell state (occupied / blocked).

These are intentionally thin wrappers so that future integration
with the Supabase ``stock_balances`` table is straightforward.
"""

from __future__ import annotations

from warehouse.grid import WarehouseBuilding, WarehouseFloorGrid
from warehouse.types import Kind


def set_occupied(
    building: WarehouseBuilding,
    floor: int,
    r: int,
    c: int,
    occupied: bool = True,
) -> None:
    """Mark a single cell as occupied (pallet placed) or empty."""
    grid = building.floors[floor]
    cell = grid[r, c]
    if cell.kind != Kind.STORAGE:
        raise ValueError(
            f"Cell ({floor},{r},{c}) is {cell.kind.value}, not STORAGE"
        )
    cell.occupied = occupied


def set_blocked(
    building: WarehouseBuilding,
    floor: int,
    r: int,
    c: int,
    blocked: bool = True,
) -> None:
    """Mark a cell as temporarily blocked (maintenance)."""
    building.floors[floor][r, c].blocked = blocked


def bulk_set_occupied(
    building: WarehouseBuilding,
    positions: list[tuple[int, int, int]],
    occupied: bool = True,
) -> None:
    """
    Set occupied state for many cells at once.

    Parameters
    ----------
    positions : list of (floor, row, col)
    """
    for fl, r, c in positions:
        set_occupied(building, fl, r, c, occupied)


def get_free_cells_in_region(
    grid: WarehouseFloorGrid,
    slot_code: str,
) -> list[tuple[int, int]]:
    """
    Return all (row, col) of STORAGE cells with the given ``slot_code``
    that are currently **empty** (not occupied and not blocked).

    Useful for finding the nearest free cell in a named region.
    """
    results: list[tuple[int, int]] = []
    for r in range(grid.rows):
        for c in range(grid.cols):
            cell = grid[r, c]
            if (
                cell.kind == Kind.STORAGE
                and cell.slot_code == slot_code
                and not cell.occupied
                and not cell.blocked
            ):
                results.append((r, c))
    return results