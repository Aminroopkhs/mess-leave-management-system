from typing import Optional, List
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime

from domain.interfaces.user_repository import IUserRepository
from ..models.user import User


class UserRepository(IUserRepository):
    """User repository implementation for Supabase"""
    
    def __init__(self, session: AsyncSession):
        self.session = session
    
    async def get_by_id(self, user_id: str) -> Optional[dict]:
        """Get user by ID"""
        result = await self.session.execute(
            select(User).where(User.id == user_id)
        )
        user = result.scalar_one_or_none()
        return user.to_dict() if user else None
    
    async def get_by_email(self, email: str) -> Optional[dict]:
        """Get user by email"""
        result = await self.session.execute(
            select(User).where(User.email == email)
        )
        user = result.scalar_one_or_none()
        return user.to_dict() if user else None
    
    async def create(self, user_data: dict) -> dict:
        """Create new user"""
        user = User(
            id=user_data["id"],
            email=user_data["email"],
            name=user_data["name"],
            picture=user_data.get("picture"),
            email_verified=user_data.get("email_verified", False),
            last_login=datetime.utcnow()
        )
        
        self.session.add(user)
        await self.session.flush()
        
        return user.to_dict()
    
    async def update(self, user_id: str, user_data: dict) -> Optional[dict]:
        """Update user"""
        result = await self.session.execute(
            select(User).where(User.id == user_id)
        )
        user = result.scalar_one_or_none()
        
        if not user:
            return None
        
        for key, value in user_data.items():
            if hasattr(user, key):
                setattr(user, key, value)
        
        await self.session.flush()
        return user.to_dict()
    
    async def update_last_login(self, user_id: str) -> None:
        """Update user's last login timestamp"""
        await self.session.execute(
            update(User)
            .where(User.id == user_id)
            .values(last_login=datetime.utcnow())
        )
        await self.session.flush()
