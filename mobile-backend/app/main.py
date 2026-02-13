from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import supervisor

app = FastAPI(title="MobAI WMS - Supervisor API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(supervisor.router, prefix="/supervisor", tags=["Supervisor"])

@app.get("/")
def root():
    return {"message": "MobAI WMS Supervisor API"}
