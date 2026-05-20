"""
warehouse/export.py
───────────────────
Utilities to visualize / export the grid for debugging.
"""

from __future__ import annotations

from warehouse.grid import WarehouseBuilding, WarehouseFloorGrid
from warehouse.types import Kind


# Symbol used when rendering back to ASCII
_RENDER_MAP: dict[Kind, str] = {
    Kind.VOID: " ",
    Kind.OBSTACLE: "#",
    Kind.CORRIDOR: ".",
    Kind.STORAGE: "S",
    Kind.CONNECTOR: "E",
}


def render_floor_ascii(grid: WarehouseFloorGrid, *, show_occupied: bool = False) -> str:
    """
    Render a floor grid back to an ASCII string.

    If *show_occupied* is True, occupied storage cells are shown as ``X``
    and blocked cells as ``!``.
    """
    lines: list[str] = []
    for r in range(grid.rows):
        chars: list[str] = []
        for c in range(grid.cols):
            cell = grid[r, c]
            if show_occupied and cell.blocked:
                chars.append("!")
            elif show_occupied and cell.occupied:
                chars.append("X")
            else:
                chars.append(_RENDER_MAP.get(cell.kind, "?"))
        lines.append("".join(chars))
    return "\n".join(lines)


def print_building_summary(building: WarehouseBuilding) -> None:
    """Print a quick legend / cell-count summary for every floor."""
    for fl in sorted(building.floors):
        grid = building.floors[fl]
        counts = grid.summary()
        total = grid.rows * grid.cols
        print(f"\n═══ Floor {fl} ({grid.rows}×{grid.cols} = {total} cells) ═══")
        for kind_name, cnt in counts.items():
            if cnt > 0:
                print(f"  {kind_name:12s}: {cnt:>5}")

        # Show slot_code sample
        codes: set[str] = set()
        for row in grid.cells:
            for cell in row:
                if cell.slot_code:
                    codes.add(cell.slot_code)
        if codes:
            print(f"  Slot codes   : {', '.join(sorted(codes))}")

    # Connectors
    if building.connector_targets:
        print("\n═══ Connectors ═══")
        for cid, targets in building.connector_targets.items():
            floors_str = ", ".join(
                f"F{fl}@({r},{c})" for fl, r, c in targets
            )
            print(f"  {cid}: {floors_str}")