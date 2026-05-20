"""
warehouse/grid.py
─────────────────
Grid containers and pathfinding helpers.

Classes
    WarehouseFloorGrid  — 2-D matrix of Cell objects for ONE floor.
    WarehouseBuilding   — dict[int, WarehouseFloorGrid] for floors 1..4.

Free functions / methods
    walkable(cell)                     → bool
    move_cost(cell, storage_penalty)   → float
    neighbors(building, floor, r, c)   → yields (nf, nr, nc, step_cost)
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Iterator, Optional

from warehouse.types import Cell, Kind


# ═══════════════════════════════════════════════════════════
#  WALKABILITY  (Policy C — default)
#
#  Policy C:
#    • VOID / OBSTACLE → never walkable
#    • blocked cell    → never walkable
#    • CORRIDOR        → always walkable
#    • CONNECTOR       → always walkable
#    • STORAGE         → walkable ONLY IF empty (occupied == False)
# ═══════════════════════════════════════════════════════════

def walkable(cell: Cell) -> bool:
    """
    Return True if a pathfinding agent may enter this cell.

    Implements **Policy C**: storage cells are traversable only
    when they are empty, so forklifts can cut through vacant slots
    but must route around occupied ones.
    """
    if cell.blocked:
        return False
    if cell.kind in (Kind.VOID, Kind.OBSTACLE):
        return False
    if cell.kind == Kind.STORAGE:
        # Policy C: empty storage is walkable
        return not cell.occupied
    # CORRIDOR and CONNECTOR are always walkable
    return True


def move_cost(cell: Cell, storage_penalty: float = 2.0) -> float:
    """
    Movement cost to *enter* ``cell``.

    For STORAGE cells the cost is ``base_cost + storage_penalty`` so
    the planner naturally prefers corridors.  All other walkable cells
    simply return ``base_cost``.

    Parameters
    ----------
    cell : Cell
        Target cell being entered.
    storage_penalty : float
        Extra cost added when traversing an empty storage slot.
        Default 2.0 (i.e. total cost = 1.0 + 2.0 = 3.0).
    """
    if cell.kind == Kind.STORAGE:
        return cell.base_cost + storage_penalty
    return cell.base_cost


# ═══════════════════════════════════════════════════════════
#  CONNECTOR TARGET MAP
#
#  Maps (connector_id) → list of (floor, row, col) where the
#  same physical connector exists on other floors.
#  Populated by ``loader.apply_connectors()``.
# ═══════════════════════════════════════════════════════════

# Type alias for connector targets:
#   connector_id  →  list[ (floor, row, col) ]
ConnectorTargets = dict[str, list[tuple[int, int, int]]]


# ═══════════════════════════════════════════════════════════
#  FLOOR GRID
# ═══════════════════════════════════════════════════════════

@dataclass
class WarehouseFloorGrid:
    """
    A single warehouse floor stored as a 2-D matrix of :class:`Cell`.

    Attributes
    ----------
    floor : int
        Floor number (1..4).
    rows  : int
        Number of rows (grid height in metres).
    cols  : int
        Number of columns (grid width in metres).
    cells : list[list[Cell]]
        ``cells[r][c]`` gives the Cell at row *r*, column *c*.
    """

    floor: int
    rows: int
    cols: int
    cells: list[list[Cell]] = field(default_factory=list, repr=False)

    # ── access helpers ────────────────────────────────────

    def __getitem__(self, pos: tuple[int, int]) -> Cell:
        """grid[r, c] → Cell"""
        r, c = pos
        return self.cells[r][c]

    def __setitem__(self, pos: tuple[int, int], value: Cell) -> None:
        """grid[r, c] = cell"""
        r, c = pos
        self.cells[r][c] = value

    def in_bounds(self, r: int, c: int) -> bool:
        """Return True if (r, c) is inside the grid."""
        return 0 <= r < self.rows and 0 <= c < self.cols

    def summary(self) -> dict[str, int]:
        """Count cells of each Kind."""
        counts: dict[str, int] = {k.value: 0 for k in Kind}
        for row in self.cells:
            for cell in row:
                counts[cell.kind.value] += 1
        return counts


# ═══════════════════════════════════════════════════════════
#  BUILDING  (floors 1..4)
# ═══════════════════════════════════════════════════════════

@dataclass
class WarehouseBuilding:
    """
    The full warehouse: floors 1‑4 (ground floor excluded).

    Attributes
    ----------
    floors : dict[int, WarehouseFloorGrid]
        Keyed by floor number (1, 2, 3, 4).
    connector_targets : ConnectorTargets
        Populated by :func:`loader.apply_connectors`.
        Maps a connector_id to every (floor, r, c) where it appears.
    storage_penalty : float
        Penalty added when traversing empty storage slots.
    vertical_cost_per_floor : float
        Cost to ride a connector up/down one floor level.
    """

    floors: dict[int, WarehouseFloorGrid] = field(default_factory=dict)
    connector_targets: ConnectorTargets = field(default_factory=dict)
    storage_penalty: float = 2.0
    vertical_cost_per_floor: float = 5.0

    # ── neighbor generator (for A* / Dijkstra) ───────────

    def neighbors(
        self,
        floor: int,
        r: int,
        c: int,
    ) -> Iterator[tuple[int, int, int, float]]:
        """
        Yield reachable neighbours of cell ``(floor, r, c)``.

        Yields
        ------
        (next_floor, next_row, next_col, step_cost)

        Movement rules:
            1. **Horizontal** — 4-connected (N/S/E/W) on the same floor.
               Target must be walkable.
            2. **Vertical** — only if the current cell is a CONNECTOR.
               Jumps to every other floor where the same connector_id
               exists.  Cost = |Δfloor| × vertical_cost_per_floor.
        """
        grid = self.floors.get(floor)
        if grid is None:
            return

        current = grid[r, c]

        # ── 1) horizontal 4-neighbourhood ─────────────────
        for dr, dc in ((-1, 0), (1, 0), (0, -1), (0, 1)):
            nr, nc = r + dr, c + dc
            if not grid.in_bounds(nr, nc):
                continue
            target = grid[nr, nc]
            if walkable(target):
                yield (floor, nr, nc, move_cost(target, self.storage_penalty))

        # ── 2) vertical via connectors ────────────────────
        if current.kind == Kind.CONNECTOR and current.connector_id:
            targets = self.connector_targets.get(current.connector_id, [])
            for (tf, tr, tc) in targets:
                if tf == floor and tr == r and tc == c:
                    continue  # skip self
                # Verify the target cell exists and is walkable
                target_grid = self.floors.get(tf)
                if target_grid is None:
                    continue
                target_cell = target_grid[tr, tc]
                if not walkable(target_cell):
                    continue
                delta = abs(tf - floor)
                cost = delta * self.vertical_cost_per_floor
                yield (tf, tr, tc, cost)