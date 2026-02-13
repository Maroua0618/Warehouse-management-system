"""Authentication routes."""
from fastapi import APIRouter, Depends, HTTPException, status
from supabase import Client
from app.database import get_db
from app.schemas.auth import LoginRequest, LoginResponse
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/login", response_model=LoginResponse)
async def login(
    credentials: LoginRequest,
    db: Client = Depends(get_db)
):
    """
    Employee/Supervisor login endpoint.
    
    Authenticates user with email and password.
    Returns access token and user information.
    """
    auth_service = AuthService(db)
    return await auth_service.login(credentials)


@router.post("/logout")
async def logout():
    """
    Logout endpoint.
    
    Client should discard the token.
    """
    return {"message": "Logged out successfully"}
