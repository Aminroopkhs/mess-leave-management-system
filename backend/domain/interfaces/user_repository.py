from abc import ABC, abstractmethod
from typing import Optional, List
from sqlalchemy.ext.asyncio import AsyncSession


class IUserRepository(ABC):
    """User repository port/interface"""
    
    @abstractmethod
    async def get_by_id(self, user_id: str) -> Optional[dict]:
        """Get user by ID"""
        pass
    
    @abstractmethod
    async def get_by_email(self, email: str) -> Optional[dict]:
        """Get user by email"""
        pass
    
    @abstractmethod
    async def create(self, user_data: dict) -> dict:
        """Create new user"""
        pass
    
    @abstractmethod
    async def update(self, user_id: str, user_data: dict) -> Optional[dict]:
        """Update user"""
        pass
    
    @abstractmethod
    async def update_last_login(self, user_id: str) -> None:
        """Update user's last login timestamp"""
        pass
