# Task 2 — Index

Task 2 currently contains the forecasting workflow.

## Structure

- `forcasting/`
  - `README.md`
  - `forcasting_outgoing_model.ipynb`
  - `WMS_Hackathon_DataPack_Templates_FR_FV_B7_ONLY_historique_demande.xlsx`

## Start here

- Detailed task documentation: `ai/task2/forcasting/README.md`
- Main notebook: `ai/task2/forcasting/forcasting_outgoing_model.ipynb`

## Quick run

From repository root:

- `python -m jupyter nbconvert --to notebook --execute "ai/task2/forcasting/forcasting_outgoing_model.ipynb" --output "forcasting_outgoing_model.executed.ipynb" --output-dir "submission/outputs/verify"`

## Dependencies

Install if needed:

- `pip install pandas numpy lightgbm openpyxl jupyter nbformat nbclient ipykernel`

## Note

The folder name is `forcasting` (kept to match current project structure).
