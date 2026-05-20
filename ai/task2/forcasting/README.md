# Task 2 — Forecasting

Task 2 contains the demand forecasting workflow for outgoing preparation quantities.

## Contents

- `forcasting_outgoing_model.ipynb`: end-to-end notebook for next-day SKU demand forecasting and preparation order generation.
- `WMS_Hackathon_DataPack_Templates_FR_FV_B7_ONLY_historique_demande.xlsx`: historical demand source used by the notebook.

## Notebook objective

The notebook predicts **tomorrow demand per SKU** and generates a preparation output with:

- `id_produit`
- `date_preparation`
- `pred_qty_demand`
- `qty_to_prepare`

## Workflow implemented

1. Load demand history file with robust path discovery (local + Kaggle style roots).
2. Clean/normalize raw demand data.
3. Build complete daily SKU grid (fill missing days with zero demand).
4. Create leak-free lag/rolling/intermittency/calendar features.
5. Build robust time-based train/validation/test split.
6. Train LightGBM with Poisson objective.
7. Evaluate with overall and active-demand metrics.
8. Generate next-day preparation order.

## How to run

Open and run all cells in:

- `ai/task2/forcasting/forcasting_outgoing_model.ipynb`

Or execute from repository root:

- `python -m jupyter nbconvert --to notebook --execute "ai/task2/forcasting/forcasting_outgoing_model.ipynb" --output "forcasting_outgoing_model.executed.ipynb" --output-dir "submission/outputs/verify"`

## Dependencies

If missing in your environment, install:

- `pip install pandas numpy lightgbm openpyxl jupyter nbformat nbclient ipykernel`

## Notes

- Folder name is `forcasting` (kept as-is to match existing project structure).
- The notebook already includes guards for missing columns, invalid dates, and short time series.
