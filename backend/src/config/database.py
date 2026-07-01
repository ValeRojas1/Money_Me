import logging
from urllib.parse import urlparse

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from src.config.settings import prepare_postgres_engine_config, settings

logger = logging.getLogger(__name__)

database_url = settings.async_database_url
connect_args: dict = {}

if settings.is_postgres:
    database_url, connect_args = prepare_postgres_engine_config(database_url)

engine_kwargs: dict = {
    "echo": settings.debug,
    "future": True,
}

if connect_args:
    engine_kwargs["connect_args"] = connect_args

if settings.is_postgres:
    engine_kwargs.update(
        pool_pre_ping=True,
        pool_size=5,
        max_overflow=10,
    )
    host = urlparse(database_url).hostname or "unknown"
    logger.info("PostgreSQL target host: %s", host)

if settings.is_mysql:
    engine_kwargs.update(
        pool_pre_ping=True,
        pool_size=5,
        max_overflow=10,
    )

engine = create_async_engine(database_url, **engine_kwargs)

async_session_factory = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


class Base(DeclarativeBase):
    pass


async def get_session() -> AsyncSession:
    async with async_session_factory() as session:
        try:
            yield session
        finally:
            await session.close()


async def init_db() -> None:
    import src.domain.models  # noqa: F401

    from src.infrastructure.database.seed import seed_database

    if settings.async_database_url.startswith("sqlite"):
        from pathlib import Path

        db_path = settings.async_database_url.split("///", 1)[-1]
        Path(db_path).parent.mkdir(parents=True, exist_ok=True)

    logger.info("Creating database tables if needed...")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with async_session_factory() as session:
        await seed_database(session)

    logger.info("Database initialized successfully")
