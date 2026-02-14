"""
warehouse/loader.py
───────────────────
Functions that build WarehouseFloorGrid / WarehouseBuilding
from ASCII plans, JSON slot-region files, and YAML/JSON config.

Public API
──────────
    load_plan_from_ascii   — parse an ASCII string into a WarehouseFloorGrid
    apply_slot_regions     — stamp slot_code onto cells from a region dict
    apply_connectors       — register connector_id and build connector_targets
    build_building         — one-call factory that assembles floors 1‑4
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Optional

from warehouse.types import Cell, Kind
from warehouse.grid import WarehouseFloorGrid, WarehouseBuilding


# ═══════════════════════════════════════════════════════════
#  SYMBOL MAP  (ASCII char → Kind + optional connector hint)
#
#  Default mapping; callers may extend via *connector_symbols*.
# ═══════════════════════════════════════════════════════════

_DEFAULT_SYMBOL_MAP: dict[str, Kind] = {
    " ": Kind.VOID,
    ".": Kind.CORRIDOR,
    "S": Kind.STORAGE,
    "#": Kind.OBSTACLE,
    "E": Kind.CONNECTOR,  # elevator
    "M": Kind.CONNECTOR,  # monte-charge (generic)
}

# Which symbols represent connectors and their default connector_id
_DEFAULT_CONNECTOR_SYMBOLS: dict[str, str] = {
    "E": "elevator",
    "M": "mc1",
}


# ═══════════════════════════════════════════════════════════
#  1) ASCII → FLOOR GRID
# ═══════════════════════════════════════════════════════════

def load_plan_from_ascii(
    ascii_str: str,
    floor: int,
    *,
    storage_penalty: float = 2.0,
    connector_symbols: Optional[dict[str, str]] = None,
) -> WarehouseFloorGrid:
    """
    Parse an ASCII string into a :class:`WarehouseFloorGrid`.

    Parameters
    ----------
    ascii_str : str
        Multi-line text where each character maps to one cell.
        Leading/trailing blank lines are stripped.
    floor : int
        Floor number to tag on the grid (1‑4).
    storage_penalty : float
        Not stored on the grid itself, but used if we wanted to
        bake ``base_cost`` into storage cells at load time.
        Currently storage cells get ``base_cost = 1.0``; the penalty
        is applied at query time in ``move_cost()``.
    connector_symbols : dict[str, str] | None
        Extra or overridden char→connector_id mappings.
        Example: ``{"M": "mc1", "N": "mc2"}``.

    Returns
    -------
    WarehouseFloorGrid
    """
    # Merge connector symbol overrides
    conn_syms = dict(_DEFAULT_CONNECTOR_SYMBOLS)
    if connector_symbols:
        conn_syms.update(connector_symbols)

    # Clean up the ASCII input: strip leading/trailing empty lines
    lines = ascii_str.splitlines()

    # Remove completely empty leading / trailing lines
    while lines and lines[0].strip() == "":
        lines.pop(0)
    while lines and lines[-1].strip() == "":
        lines.pop()

    if not lines:
        raise ValueError("ASCII plan is empty after stripping blank lines")

    # Determine grid dimensions.
    # Rows = number of lines; cols = max line length (pad shorter lines with VOID).
    num_rows = len(lines)
    num_cols = max(len(line) for line in lines)

    cells: list[list[Cell]] = []

    for r, line in enumerate(lines):
        row: list[Cell] = []
        for c in range(num_cols):
            ch = line[c] if c < len(line) else " "

            # Resolve Kind
            kind = _DEFAULT_SYMBOL_MAP.get(ch, Kind.VOID)

            # Build the cell
            cell = Cell(kind=kind)

            # Storage cells get capacity = 1
            if kind == Kind.STORAGE:
                cell.capacity = 1

            # Connector cells get their connector_id
            if kind == Kind.CONNECTOR and ch in conn_syms:
                cell.connector_id = conn_syms[ch]

            row.append(cell)
        cells.append(row)

    return WarehouseFloorGrid(
        floor=floor,
        rows=num_rows,
        cols=num_cols,
        cells=cells,
    )


# ═══════════════════════════════════════════════════════════
#  2) SLOT REGIONS
# ═══════════════════════════════════════════════════════════

def apply_slot_regions(
    grid: WarehouseFloorGrid,
    slot_regions: dict[str, list[list[int]]],
) -> None:
    """
    Stamp ``slot_code`` onto cells from a region dictionary.

    Parameters
    ----------
    grid : WarehouseFloorGrid
        The floor grid to modify in place.
    slot_regions : dict
        Maps a region label (e.g. ``"C7"``) to a list of ``[r, c]``
        pairs that belong to that region.

    Example JSON::

        {
          "C7": [[2,3],[2,4],[3,3],[3,4]],
          "E14": [[5,8],[5,9]]
        }
    """
    for code, positions in slot_regions.items():
        for pos in positions:
            r, c = pos[0], pos[1]
            if grid.in_bounds(r, c):
                grid[r, c].slot_code = code


# ═══════════════════════════════════════════════════════════
#  3) CONNECTORS  (vertical links)
# ═══════════════════════════════════════════════════════════

def apply_connectors(
    building: WarehouseBuilding,
    connectors_config: list[dict[str, Any]],
) -> None:
    """
    Register vertical connectors across floors.

    Parameters
    ----------
    building : WarehouseBuilding
        Building whose ``connector_targets`` will be populated.
    connectors_config : list[dict]
        Each entry describes one physical connector::

            {
              "id": "elevator",
              "positions": {
                "1": [0, 5],   # floor 1 → row 0, col 5
                "2": [0, 5],
                "3": [0, 5],
                "4": [0, 5]
              },
              "vertical_cost_per_floor": 5.0   # optional override
            }

    Side effects
    -------------
    - Sets ``cell.kind = CONNECTOR`` and ``cell.connector_id`` at each
      position (in case the ASCII plan didn't already).
    - Fills ``building.connector_targets[connector_id]``.
    - Optionally overrides ``building.vertical_cost_per_floor`` (last
      connector config wins if multiple define it).
    """
    for entry in connectors_config:
        cid: str = entry["id"]
        positions: dict[str, list[int]] = entry["positions"]

        # Optional global override
        if "vertical_cost_per_floor" in entry:
            building.vertical_cost_per_floor = float(entry["vertical_cost_per_floor"])

        targets: list[tuple[int, int, int]] = []

        for floor_str, pos in positions.items():
            fl = int(floor_str)
            r, c = pos[0], pos[1]

            grid = building.floors.get(fl)
            if grid is None:
                continue
            if not grid.in_bounds(r, c):
                continue

            # Force the cell to be a CONNECTOR
            cell = grid[r, c]
            cell.kind = Kind.CONNECTOR
            cell.connector_id = cid

            targets.append((fl, r, c))

        building.connector_targets[cid] = targets


# ═══════════════════════════════════════════════════════════
#  4) BUILD BUILDING  (one-call factory)
# ═══════════════════════════════════════════════════════════

def build_building(config: dict[str, Any]) -> WarehouseBuilding:
    """
    Assemble a 4-floor :class:`WarehouseBuilding` from a config dict.

    The config dict must contain::

        {
          "plan12": "<ASCII string for floors 1 & 2>",
          "plan34": "<ASCII string for floors 3 & 4>",
          "storage_penalty": 2.0,            # optional
          "vertical_cost_per_floor": 5.0,    # optional
          "connector_symbols": {"E": "elevator", "M": "mc1"},  # optional
          "connectors": [ ... ],             # see apply_connectors()
          "slot_regions_12": { ... },        # optional JSON dict
          "slot_regions_34": { ... },        # optional JSON dict
        }

    Layout rule
    -----------
    Floors 1 & 2 use ``plan12``; floors 3 & 4 use ``plan34``.
    """
    plan12: str = config["plan12"]
    plan34: str = config["plan34"]
    penalty: float = config.get("storage_penalty", 2.0)
    vert_cost: float = config.get("vertical_cost_per_floor", 5.0)
    conn_syms: Optional[dict[str, str]] = config.get("connector_symbols")

    building = WarehouseBuilding(
        storage_penalty=penalty,
        vertical_cost_per_floor=vert_cost,
    )

    # ── Build floor grids ────────────────────────────────
    # Floors 1 & 2 share plan12
    for fl in (1, 2):
        grid = load_plan_from_ascii(
            plan12, floor=fl,
            storage_penalty=penalty,
            connector_symbols=conn_syms,
        )
        building.floors[fl] = grid

    # Floors 3 & 4 share plan34
    for fl in (3, 4):
        grid = load_plan_from_ascii(
            plan34, floor=fl,
            storage_penalty=penalty,
            connector_symbols=conn_syms,
        )
        building.floors[fl] = grid

    # ── Apply slot regions ───────────────────────────────
    regions_12 = config.get("slot_regions_12")
    if regions_12:
        for fl in (1, 2):
            apply_slot_regions(building.floors[fl], regions_12)

    regions_34 = config.get("slot_regions_34")
    if regions_34:
        for fl in (3, 4):
            apply_slot_regions(building.floors[fl], regions_34)

    # ── Apply connectors ─────────────────────────────────
    connectors = config.get("connectors", [])
    if connectors:
        apply_connectors(building, connectors)

    return building


# ═══════════════════════════════════════════════════════════
#  5) FILE HELPERS  (load JSON / YAML configs from disk)
# ═══════════════════════════════════════════════════════════

def load_json(path: str | Path) -> Any:
    """Read and parse a JSON file."""
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def _try_load_yaml(path: str | Path) -> Any:
    """
    Attempt to load a YAML file.  Falls back to JSON parsing
    if PyYAML is not installed (for zero-dependency usage).
    """
    try:
        import yaml  # type: ignore[import-untyped]
        with open(path, "r", encoding="utf-8") as f:
            return yaml.safe_load(f)
    except ImportError:
        # Fallback: try JSON (YAML is a superset of JSON for simple cases)
        return load_json(path)


def build_building_from_files(
    floors_config_path: str | Path,
    connectors_config_path: str | Path,
    plan12_path: str | Path,
    plan34_path: str | Path,
    slot_regions_12_path: Optional[str | Path] = None,
    slot_regions_34_path: Optional[str | Path] = None,
) -> WarehouseBuilding:
    """
    High-level loader: read all config files and build the building.

    Parameters
    ----------
    floors_config_path : path
        YAML or JSON with ``storage_penalty``, ``vertical_cost_per_floor``,
        and ``connector_symbols``.
    connectors_config_path : path
        YAML or JSON list of connector definitions.
    plan12_path / plan34_path : path
        Plain text files containing the ASCII grid for each plan.
    slot_regions_12_path / slot_regions_34_path : path, optional
        JSON files mapping slot_code → list of [r,c].
    """
    # Load floor config
    floor_cfg = _try_load_yaml(floors_config_path)

    # Load ASCII plans
    plan12 = Path(plan12_path).read_text(encoding="utf-8")
    plan34 = Path(plan34_path).read_text(encoding="utf-8")

    # Load connectors
    conn_cfg = _try_load_yaml(connectors_config_path)

    # Load slot regions (optional)
    regions_12 = load_json(slot_regions_12_path) if slot_regions_12_path else None
    regions_34 = load_json(slot_regions_34_path) if slot_regions_34_path else None

    config: dict[str, Any] = {
        "plan12": plan12,
        "plan34": plan34,
        "storage_penalty": floor_cfg.get("storage_penalty", 2.0),
        "vertical_cost_per_floor": floor_cfg.get("vertical_cost_per_floor", 5.0),
        "connector_symbols": floor_cfg.get("connector_symbols"),
        "connectors": conn_cfg if isinstance(conn_cfg, list) else conn_cfg.get("connectors", []),
        "slot_regions_12": regions_12,
        "slot_regions_34": regions_34,
    }

    return build_building(config)