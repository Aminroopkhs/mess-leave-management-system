from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI
from contextlib import asynccontextmanager
from api.api import api_router
from infrastructure.database.connection import init_db, close_db


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Lifespan context manager for FastAPI app
    Handles startup and shutdown events
    """
    # Startup: Initialize database
    print("Initializing database...")
    try:
        await init_db()
        print("✅ Database initialized successfully!")
    except ValueError as e:
        print(f"⚠️  Database not configured: {e}")
        print("⚠️  App will run but database-dependent features will be unavailable")
        print("⚠️  Please set DATABASE_URL in .env file to enable database features")
    except Exception as e:
        print(f"❌ Database initialization failed: {e}")
        print("⚠️  App will run but database operations will fail")
    
    yield
    
    # Shutdown: Close database connections
    print("Closing database connections...")
    await close_db()
    print("Database connections closed!")


app = FastAPI(
    title="Mess Leave Management System",
    description="to manage leave for hostel messes",
    version="1.0.0",
    lifespan=lifespan
)

app.include_router(api_router)

@app.get("/")
def root():
    return {"message": "Mess Leave Management System API is running"}
"""alias for deploy"""
application=app