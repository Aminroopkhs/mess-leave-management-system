from sqlalchemy.ext.asyncio import AsyncEngine, AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from contextlib import asynccontextmanager
from fastapi import HTTPException
import os
import logging

# Reduce SQLAlchemy and asyncpg logging verbosity
logging.getLogger('sqlalchemy.engine').setLevel(logging.WARNING)
logging.getLogger('sqlalchemy.pool').setLevel(logging.WARNING)
logging.getLogger('asyncpg').setLevel(logging.WARNING)

# Supabase connection configuration
SUPABASE_URL = os.getenv("SUPABASE_URL", "")
SUPABASE_KEY = os.getenv("SUPABASE_KEY", "")
DATABASE_URL = os.getenv("DATABASE_URL", "")

# Create SQLAlchemy Base
Base = declarative_base()

# Database engine (singleton)
engine: AsyncEngine = None


def get_database_url() -> str:
    """
    Get database URL for Supabase PostgreSQL connection
    
    Supabase provides a direct PostgreSQL connection string.
    Format: postgresql+asyncpg://user:password@host:port/database
    """
    if not DATABASE_URL:
        return None
    
    # Replace postgres:// with postgresql+asyncpg:// for async
    url = DATABASE_URL
    if url.startswith("postgres://"):
        url = url.replace("postgres://", "postgresql+asyncpg://", 1)
    elif url.startswith("postgresql://"):
        url = url.replace("postgresql://", "postgresql+asyncpg://", 1)
    
    # Debug output - hide password
    try:
        parts = url.split('@', 1)
        if len(parts) == 2:
            user_part = parts[0]
            host_part = parts[1]
            print(f"Connecting to: {host_part}")
        else:
            print(f"URL format issue: {url}")
    except:
        pass
    
    return url


def is_database_configured() -> bool:
    """Check if database is properly configured"""
    return bool(DATABASE_URL and DATABASE_URL.strip())


def create_engine() -> AsyncEngine:
    """Create async database engine"""
    global engine
    
    if engine is None:
        database_url = get_database_url()
        
        if not database_url:
            return None
        
        engine = create_async_engine(
            database_url,
            echo=False,  # Disable SQL query logging
            pool_size=5,
            max_overflow=10,
            pool_pre_ping=True,  # Verify connections before using
        )
    
    return engine


# Session factory
async_session_maker = None


def get_session_maker() -> sessionmaker:
    """Get session maker"""
    global async_session_maker
    
    if async_session_maker is None:
        engine = create_engine()
        
        if not engine:
            return None
            
        async_session_maker = sessionmaker(
            engine,
            class_=AsyncSession,
            expire_on_commit=False,
        )
    
    return async_session_maker


@asynccontextmanager
async def get_db_session():
    """
    Async context manager for database sessions
    
    Usage:
        async with get_db_session() as session:
            # Use session here
            await session.execute(...)
    """
    if not is_database_configured():
        raise RuntimeError("Database is not configured. Please set DATABASE_URL in .env file")
    
    session_maker = get_session_maker()
    async with session_maker() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


async def get_db():
    """
    Dependency for FastAPI routes
    
    Usage:
        @router.get("/users")
        async def get_users(db: AsyncSession = Depends(get_db)):
            # Use db session here
    """
    if not is_database_configured():
        raise HTTPException(
            status_code=503,
            detail="Database is not configured. Please contact administrator."
        )
    
    async with get_db_session() as session:
        yield session


async def init_db():
    """Initialize database - create all tables"""
    if not is_database_configured():
        raise ValueError("Database is not configured. Set DATABASE_URL in .env file")
    
    engine = create_engine()
    if engine:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)


async def close_db():
    """Close database connection"""
    global engine
    if engine:
        await engine.dispose()
