"""FastAPI dependencies."""
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from supabase import Client
from app.database import get_db
from app.services.auth_service import AuthService
from app.schemas.auth import UserInfo
from app.schemas.common import RoleType

security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Client = Depends(get_db)
) -> UserInfo:
    """Get current authenticated user."""
    token = credentials.credentials
    auth_service = AuthService(db)
    
    try:
        user = await auth_service.get_current_user(token)
        return user
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )


async def get_current_employee(
    current_user: UserInfo = Depends(get_current_user)
) -> UserInfo:
    """Get current user and verify they are an employee."""
    if current_user.role not in [RoleType.EMPLOYEE, RoleType.SUPERVISOR]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access forbidden: Employee role required"
        )
    return current_user


async def get_current_active_employee(
    current_user: UserInfo = Depends(get_current_employee)
) -> UserInfo:
    """Get current employee and verify they are active."""
    if current_user.status != "ACTIVE":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is not active"
        )
    return current_user
