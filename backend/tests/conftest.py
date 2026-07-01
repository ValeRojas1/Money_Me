import asyncio
from pathlib import Path

import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from src.config.database import Base, get_session
from src.core.security import hash_password
from src.domain.models import User, Profile, Wallet, Movement, Category, ProcessedCapture
from src.domain.models.budget import Budget
from src.domain.models.movement import MovementStatus, MovementType
from src.domain.models.user import UserStatus
from src.domain.models.wallet import WalletType
from src.domain.models.capture import CaptureStatus
from src.domain.models.category import CategoryType

from src.main import app

TEST_DB_URL = "sqlite+aiosqlite:///./data/test.db"

engine = create_async_engine(TEST_DB_URL, echo=False)
TestSessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)


@pytest.fixture(scope="session")
def event_loop():
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest_asyncio.fixture(autouse=True)
async def setup_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)


async def override_get_session():
    async with TestSessionLocal() as session:
        yield session


@pytest_asyncio.fixture
async def db():
    async with TestSessionLocal() as session:
        yield session


@pytest_asyncio.fixture
async def client(db):
    app.dependency_overrides[get_session] = lambda: db
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac
    app.dependency_overrides.clear()


@pytest_asyncio.fixture
async def test_user(db: AsyncSession) -> User:
    user = User(
        email="test@example.com",
        password_hash=hash_password("password123"),
        status=UserStatus.ACTIVE,
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


@pytest_asyncio.fixture
async def test_profile(db: AsyncSession, test_user: User) -> Profile:
    profile = Profile(user_id=test_user.id, name="Test User")
    db.add(profile)
    await db.commit()
    await db.refresh(profile)
    return profile


@pytest_asyncio.fixture
async def test_wallet(db: AsyncSession, test_user: User) -> Wallet:
    wallet = Wallet(
        user_id=test_user.id,
        name="Test Wallet",
        type=WalletType.CHECKING,
        currency="USD",
        balance_cents=100000,
        is_default=True,
    )
    db.add(wallet)
    await db.commit()
    await db.refresh(wallet)
    return wallet


@pytest_asyncio.fixture
async def test_category(db: AsyncSession) -> Category:
    category = Category(name="Food", type=CategoryType.EXPENSE, is_system=True, sort_order=0)
    db.add(category)
    await db.commit()
    await db.refresh(category)
    return category


@pytest_asyncio.fixture
async def test_movement(db: AsyncSession, test_user: User, test_wallet: Wallet, test_category: Category) -> Movement:
    from datetime import date
    movement = Movement(
        user_id=test_user.id,
        wallet_id=test_wallet.id,
        category_id=test_category.id,
        type=MovementType.EXPENSE,
        amount_cents=2500,
        currency="USD",
        description="Test expense",
        transaction_date=date.today(),
        status=MovementStatus.COMPLETED,
    )
    db.add(movement)
    await db.commit()
    await db.refresh(movement)
    return movement


@pytest_asyncio.fixture
async def auth_headers(client: AsyncClient, test_user: User) -> dict:
    response = await client.post(
        "/api/v1/auth/login",
        json={"email": "test@example.com", "password": "password123"},
    )
    data = response.json()
    token = data.get("access_token", "")
    return {"Authorization": f"Bearer {token}"}
