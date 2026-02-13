"""Authentication schemas."""
from pydantic import BaseModel, Field, EmailStr
from typing import Optional
from app.schemas.common import RoleType


class LoginRequest(BaseModel):
    """Login request schema."""
    email: EmailStr
    password: str = Field(..., min_length=6)


class LoginResponse(BaseModel):
    """Login response schema."""
    access_token: str
    token_type: str = "bearer"
    user: "UserInfo"


class UserInfo(BaseModel):
    """User information schema."""
    id: str
    name: str
    email: str
    role: RoleType
    status: str


class TokenData(BaseModel):
    """Token payload data."""
    user_id: str
    email: str
    role: RoleType
