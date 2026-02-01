"""
Supabase Database Setup

This file provides database initialization for Supabase PostgreSQL.
"""

from infrastructure.database.connection import init_db, close_db
import asyncio


async def setup_database():
    """Create all database tables"""
    print("Creating database tables...")
    await init_db()
    print("Database tables created successfully!")


async def teardown_database():
    """Close database connections"""
    print("Closing database connections...")
    await close_db()
    print("Database connections closed!")


if __name__ == "__main__":
    # Run database setup
    asyncio.run(setup_database())
