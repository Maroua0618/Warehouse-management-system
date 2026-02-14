# Task 1 Optimization Workspace

Centralized Task 1 assets for optimization, routing, and warehouse operation simulations.

## Folder layout

- `Optimization_Agents.ipynb` (main optimization pipeline + benchmark/advanced demos)
- `ground_floor_operation_picking.ipynb` (ground-floor / picking-focused operations)
- `Warehouse_Grid_Model_Explained.ipynb` (grid model and routing logic)
- `Warehouse_Grid_Model_Explained_with_Tests.ipynb` (grid model with validation checks)
- `config/` (floor/connectors/slot region configs)
- `warehouse/` (grid, loader, occupancy, export utilities)
- `Data/` (input datasets used by notebooks)
- `detailed_methodology_all_notebooks_2026-02-14.txt` (formulas, assumptions, rationale)

## Canonical notebook paths

- `ai/task1/optimization/Optimization_Agents.ipynb`
- `ai/task1/optimization/ground_floor_operation_picking.ipynb`
- `ai/task1/optimization/Warehouse_Grid_Model_Explained.ipynb`
- `ai/task1/optimization/Warehouse_Grid_Model_Explained_with_Tests.ipynb`

## Quick run commands

From repository root:

- `python submission/Task1/infer_task1.py --output-dir submission/outputs/task1`
- `python submission/Task2/infer_task2.py --output-dir submission/outputs/task2`

## Notebook verification commands

Run all optimization notebooks and save executed copies:

- `python -m jupyter nbconvert --to notebook --execute "ai/task1/optimization/Optimization_Agents.ipynb" --output "Optimization_Agents.executed.ipynb" --output-dir "submission/outputs/verify"`
- `python -m jupyter nbconvert --to notebook --execute "ai/task1/optimization/ground_floor_operation_picking.ipynb" --output "ground_floor_operation_picking.executed.ipynb" --output-dir "submission/outputs/verify"`
- `python -m jupyter nbconvert --to notebook --execute "ai/task1/optimization/Warehouse_Grid_Model_Explained.ipynb" --output "Warehouse_Grid_Model_Explained.executed.ipynb" --output-dir "submission/outputs/verify"`
- `python -m jupyter nbconvert --to notebook --execute "ai/task1/optimization/Warehouse_Grid_Model_Explained_with_Tests.ipynb" --output "Warehouse_Grid_Model_Explained_with_Tests.executed.ipynb" --output-dir "submission/outputs/verify"`

## Notes

- Submission scripts in `submission/Task1` and `submission/Task2` already point to these canonical paths.
- If any legacy references are found, replace them with the canonical paths listed above.
