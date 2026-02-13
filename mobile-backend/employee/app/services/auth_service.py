"""Authentication service."""
from typing import Optional
from datetime import timedelta
from supabase import Client
from app.schemas.auth import LoginRequest, LoginResponse, UserInfo, TokenData
from app.schemas.common import RoleType
from app.utils.security import verify_password, create_access_token, decode_access_token
from app.config import get_settings
from fastapi import HTTPException, status

settings = get_settings()


class AuthService:
    """Authentication service."""
    
    def __init__(self, db: Client):
        self.db = db
    
    async def login(self, credentials: LoginRequest) -> LoginResponse:
        """Authenticate user and return access token."""
        # Get user from database
        response = self.db.table("users").select("*").eq("email", credentials.email).execute()
        
        if not response.data or len(response.data) == 0:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password"
            )
        
        user = response.data[0]
        
        # Verify password
        if not verify_password(credentials.password, user["password_hash"]):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password"
            )
        
        # Check if user is active
        if user["status"] != "ACTIVE":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User account is not active"
            )
        
        # Create access token
        token_data = {
            "sub": user["id"],
            "email": user["email"],
            "role": user["role"]
        }
        
        access_token = create_access_token(
            data=token_data,
            expires_delta=timedelta(minutes=settings.access_token_expire_minutes)
        )
        
        # Create user info
        user_info = UserInfo(
            id=user["id"],
            name=user["name"],
            email=user["email"],
            role=RoleType(user["role"]),
            status=user["status"]
        )
        
        return LoginResponse(
            access_token=access_token,
            user=user_info
        )
    
    async def get_current_user(self, token: str) -> UserInfo:
        """Get current user from token."""
        payload = decode_access_token(token)
        
        if payload is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Could not validate credentials"
            )
        
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Could not validate credentials"
            )
        
        # Get user from database
        response = self.db.table("users").select("*").eq("id", user_id).execute()
        
        if not response.data or len(response.data) == 0:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found"
            )
        
        user = response.data[0]
        
        return UserInfo(
            id=user["id"],
            name=user["name"],
            email=user["email"],
            role=RoleType(user["role"]),
            status=user["status"]
        )
