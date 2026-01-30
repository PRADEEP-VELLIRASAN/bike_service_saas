"""
Database Configuration
SQLite database for local development with async SQLAlchemy.
"""

from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from sqlalchemy.orm import declarative_base
from sqlalchemy import create_engine, event
import os

# Get the directory where this file is located
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, "bike_service.db")

# SQLite URLs
SQLITE_URL = f"sqlite+aiosqlite:///{DB_PATH}"
SQLITE_URL_SYNC = f"sqlite:///{DB_PATH}"

# Debug mode from environment
DEBUG = os.getenv("DEBUG", "true").lower() == "true"

# Async engine for SQLite
async_engine = create_async_engine(
    SQLITE_URL,
    echo=DEBUG,
    connect_args={"check_same_thread": False}
)

# Async session factory
AsyncSessionLocal = async_sessionmaker(
    bind=async_engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False
)

# Sync engine for migrations and testing
sync_engine = create_engine(
    SQLITE_URL_SYNC,
    echo=DEBUG,
    connect_args={"check_same_thread": False}
)

# Enable foreign keys for SQLite
@event.listens_for(sync_engine, "connect")
def set_sqlite_pragma(dbapi_connection, connection_record):
    cursor = dbapi_connection.cursor()
    cursor.execute("PRAGMA foreign_keys=ON")
    cursor.close()

# Base class for all models
Base = declarative_base()


async def get_db() -> AsyncSession:
    """
    Dependency that provides a database session.
    Used with FastAPI's Depends() for automatic session management.
    """
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


async def init_db():
    """Initialize database tables."""
    async with async_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    print(f"Database created at: {DB_PATH}")


async def close_db():
    """Close database connection pool."""
    await async_engine.dispose()
