"""Seed the E2E test database with test data."""
import asyncio
import os
from datetime import date
from pathlib import Path

# Force SQLite for E2E tests
os.environ.setdefault("DATABASE_URL", "sqlite+aiosqlite:///./data/e2e.db")

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.config.database import Base, async_session_factory, engine, init_db
from src.core.security import hash_password
from src.domain.models.category import Category
from src.domain.models.movement import Movement, MovementStatus, MovementType
from src.domain.models.profile import Profile
from src.domain.models.user import User, UserStatus
from src.domain.models.wallet import Wallet, WalletType


async def seed() -> None:
    print("Creating database tables...")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with async_session_factory() as session:
        # Seed default categories
        await _seed_categories(session)

        # Check if test user already exists
        result = await session.execute(
            select(User).where(User.email == "e2e@test.com")
        )
        existing = result.scalar_one_or_none()
        if existing:
            print(f"Test user already exists (id={existing.id}), skipping seed")
            return

        # Create test user
        print("Creating test user: e2e@test.com / TestPass1!")
        user = User(
            email="e2e@test.com",
            password_hash=hash_password("TestPass1!"),
            status=UserStatus.ACTIVE,
        )
        session.add(user)
        await session.flush()
        await session.refresh(user)

        # Create profile (required by register endpoint)
        profile = Profile(
            user_id=user.id,
            name="E2E User",
            preferred_currency="USD",
        )
        session.add(profile)

        # Create wallet
        print("Creating test wallet")
        wallet = Wallet(
            user_id=user.id,
            name="Main Wallet",
            type=WalletType.CHECKING,
            currency="USD",
            balance_cents=100000,
            is_default=True,
        )
        session.add(wallet)
        await session.flush()
        await session.refresh(wallet)

        # Get an expense category
        result = await session.execute(
            select(Category).where(Category.name == "Alimentación")
        )
        category = result.scalar_one()
        print(f"Using category: {category.name} (id={category.id})")

        # Create a sample transaction
        print("Creating sample transaction")
        movement = Movement(
            user_id=user.id,
            wallet_id=wallet.id,
            category_id=category.id,
            type=MovementType.EXPENSE,
            status=MovementStatus.COMPLETED,
            amount_cents=5000,
            currency="USD",
            description="Weekly groceries",
            transaction_date=date.today(),
        )
        session.add(movement)

        await session.commit()
        print("E2E database seeded successfully!")
        print(f"  User: e2e@test.com / TestPass1!")
        print(f"  Wallet: {wallet.name} (id={wallet.id})")
        print(f"  Transaction: {movement.description} ({movement.amount_cents}c)")


async def _seed_categories(session: AsyncSession) -> None:
    """Seed default categories if empty."""
    from src.infrastructure.database.seed import DEFAULT_CATEGORIES

    result = await session.execute(select(Category).limit(1))
    if result.scalar_one_or_none():
        return

    for index, (name, cat_type, icon, color) in enumerate(DEFAULT_CATEGORIES):
        session.add(
            Category(
                name=name,
                type=cat_type,
                icon=icon,
                color=color,
                is_system=True,
                is_active=True,
                sort_order=index,
            )
        )


if __name__ == "__main__":
    asyncio.run(seed())
