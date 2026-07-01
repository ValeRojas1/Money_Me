import enum
from datetime import datetime

from sqlalchemy import DateTime, Enum, ForeignKey, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.config.database import Base


class WalletType(str, enum.Enum):
    CHECKING = "checking"
    SAVINGS = "savings"
    CASH = "cash"
    CREDIT_CARD = "credit_card"
    INVESTMENT = "investment"
    DIGITAL = "digital"


class WalletStatus(str, enum.Enum):
    ACTIVE = "active"
    INACTIVE = "inactive"


class Wallet(Base):
    __tablename__ = "wallets"

    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    type: Mapped[WalletType] = mapped_column(Enum(WalletType), nullable=False)
    currency: Mapped[str] = mapped_column(String(3), default="USD", nullable=False)
    balance_cents: Mapped[int] = mapped_column(default=0, nullable=False)
    credit_limit_cents: Mapped[int | None] = mapped_column(nullable=True)
    status: Mapped[WalletStatus] = mapped_column(
        Enum(WalletStatus), default=WalletStatus.ACTIVE, nullable=False
    )
    is_default: Mapped[bool] = mapped_column(default=False, nullable=False)
    color: Mapped[str | None] = mapped_column(String(7), nullable=True)
    icon: Mapped[str | None] = mapped_column(String(50), nullable=True)
    institution: Mapped[str | None] = mapped_column(String(255), nullable=True)
    last_synced_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )

    user: Mapped["User"] = relationship(back_populates="wallets")
    movements: Mapped[list["Movement"]] = relationship(
        back_populates="wallet",
        foreign_keys="Movement.wallet_id",
    )
