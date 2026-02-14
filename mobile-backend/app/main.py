from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import supervisor, storage_moves, picking_tasks, bon_de_preparation, operational_monitor, command_orders

app = FastAPI(title="MobAI WMS - Supervisor API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(supervisor.router, prefix="/supervisor", tags=["Supervisor"])
app.include_router(storage_moves.router, prefix="/supervisor", tags=["Storage Moves"])
app.include_router(picking_tasks.router, prefix="/supervisor", tags=["Picking Tasks"])
app.include_router(bon_de_preparation.router, prefix="/supervisor", tags=["Bon de Préparation"])
app.include_router(operational_monitor.router, prefix="/supervisor", tags=["Operational Monitor"])
app.include_router(command_orders.router, prefix="/supervisor", tags=["Command Orders (Bon de Commande)"])

@app.get("/")
def root():
    return {"message": "MobAI WMS Supervisor API"}
