from pydantic import BaseModel
from typing import Optional

class GoogleAuthRequest(BaseModel):
    """Request model for Google OAuth authentication"""
    id_token: str


class UserResponse(BaseModel):
    """Response model for authenticated user"""
    email: str
    name: str
    picture: Optional[str] = None
    user_id: str
    email_verified: bool


class AuthResponse(BaseModel):
    """Response model for successful authentication with JWT"""
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
