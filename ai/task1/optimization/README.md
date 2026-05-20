# Task 1 — Optimization

Task 1 contains warehouse optimization notebooks, grid/routing logic, and the configuration files used to build warehouse floors and movement constraints.

## Contents

- `Optimization_Agents.ipynb`: main optimization workflow and experiments.
- `ground_floor_operation_picking.ipynb`: picking-focused floor operation workflow.
- `Warehouse_Grid_Model_Explained.ipynb`: warehouse grid model walkthrough.
- `Warehouse_Grid_Model_Explained_with_Tests.ipynb`: same grid model with extra validation cells.
- `config/`: floor layouts, connectors, and slot region mappings.
- `warehouse/`: core Python modules (`grid`, `loader`, `occupancy`, `export`, `types`).
- `Data/`: input files used by Task 1 notebooks.

## Canonical notebook paths

- `ai/task1/optimization/Optimization_Agents.ipynb`
- `ai/task1/optimization/ground_floor_operation_picking.ipynb`
- `ai/task1/optimization/Warehouse_Grid_Model_Explained.ipynb`
- `ai/task1/optimization/Warehouse_Grid_Model_Explained_with_Tests.ipynb`

## Run Task 1 inference

From repository root:

- `python submission/Task1/infer_task1.py --output-dir submission/outputs/task1`

## Verify notebooks (execute all)

From repository root:

- `python -m jupyter nbconvert --to notebook --execute "ai/task1/optimization/Optimization_Agents.ipynb" --output "Optimization_Agents.executed.ipynb" --output-dir "submission/outputs/verify"`
- `python -m jupyter nbconvert --to notebook --execute "ai/task1/optimization/ground_floor_operation_picking.ipynb" --output "ground_floor_operation_picking.executed.ipynb" --output-dir "submission/outputs/verify"`
- `python -m jupyter nbconvert --to notebook --execute "ai/task1/optimization/Warehouse_Grid_Model_Explained.ipynb" --output "Warehouse_Grid_Model_Explained.executed.ipynb" --output-dir "submission/outputs/verify"`
- `python -m jupyter nbconvert --to notebook --execute "ai/task1/optimization/Warehouse_Grid_Model_Explained_with_Tests.ipynb" --output "Warehouse_Grid_Model_Explained_with_Tests.executed.ipynb" --output-dir "submission/outputs/verify"`

## Troubleshooting

- If a notebook fails with missing packages, install: `pip install nbformat nbclient jupyter ipykernel lightgbm openpyxl`.
- If data/config file paths fail, keep notebook execution from repository root or update relative paths to canonical paths above.
