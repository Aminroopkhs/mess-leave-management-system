"""
Bootstrap layer - Dependency injection and application composition
"""
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends

from infrastructure.database.connection import get_db
from infrastructure.repositories.user_repository_impl import UserRepository
from domain.interfaces.user_repository import IUserRepository


async def get_user_repository(
    db: AsyncSession = Depends(get_db)
) -> IUserRepository:
    """
    Dependency injection for user repository
    
    Returns concrete implementation of IUserRepository
    """
    return UserRepository(db)
