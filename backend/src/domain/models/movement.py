import enum
from datetime import date, datetime

from sqlalchemy import Date, DateTime, Enum, Float, ForeignKey, Integer, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.config.database import Base


class MovementType(str, enum.Enum):
    INCOME = "income"
    EXPENSE = "expense"
    TRANSFER = "transfer"


class MovementStatus(str, enum.Enum):
    PENDING = "pending"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    RECONCILED = "reconciled"


class Movement(Base):
    __tablename__ = "movements"

    id: Mapped[int] = mapped_column(primary_key=True)
    wallet_id: Mapped[int] = mapped_column(ForeignKey("wallets.id"), nullable=False)
    category_id: Mapped[int] = mapped_column(ForeignKey("categories.id"), nullable=False)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    type: Mapped[MovementType] = mapped_column(Enum(MovementType), nullable=False)
    status: Mapped[MovementStatus] = mapped_column(
        Enum(MovementStatus), default=MovementStatus.COMPLETED, nullable=False
    )
    amount_cents: Mapped[int] = mapped_column(nullable=False)
    currency: Mapped[str] = mapped_column(String(3), default="USD", nullable=False)
    description: Mapped[str] = mapped_column(String(500), nullable=False)
    notes: Mapped[str | None] = mapped_column(String(2000), nullable=True)
    transaction_date: Mapped[date] = mapped_column(Date, nullable=False)
    is_recurring: Mapped[bool] = mapped_column(default=False, nullable=False)
    recurring_frequency: Mapped[str | None] = mapped_column(String(50), nullable=True)
    tags: Mapped[str | None] = mapped_column(String(500), nullable=True)
    receipt_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    capture_id: Mapped[int | None] = mapped_column(nullable=True)
    transfer_to_wallet_id: Mapped[int | None] = mapped_column(
        ForeignKey("wallets.id"), nullable=True
    )
    exchange_rate: Mapped[float | None] = mapped_column(nullable=True)
    original_amount_cents: Mapped[int | None] = mapped_column(nullable=True)
    original_currency: Mapped[str | None] = mapped_column(String(3), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )

    wallet: Mapped["Wallet"] = relationship(
        back_populates="movements",
        foreign_keys=[wallet_id],
    )
    category: Mapped["Category"] = relationship(back_populates="movements")
