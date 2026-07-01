import enum
from datetime import date, datetime

from sqlalchemy import Date, DateTime, Enum, Float, ForeignKey, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.config.database import Base


class PredictionType(str, enum.Enum):
    MONTHLY_SPENDING = "monthly_spending"
    CATEGORY_SPENDING = "category_spending"
    SAVINGS_GOAL = "savings_goal"
    CASH_FLOW = "cash_flow"
    BUDGET_RECOMMENDATION = "budget_recommendation"


class PredictionStatus(str, enum.Enum):
    PENDING = "pending"
    COMPLETED = "completed"
    FAILED = "failed"


class Prediction(Base):
    __tablename__ = "predictions"

    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    type: Mapped[PredictionType] = mapped_column(Enum(PredictionType), nullable=False)
    status: Mapped[PredictionStatus] = mapped_column(
        Enum(PredictionStatus), default=PredictionStatus.PENDING, nullable=False
    )
    predicted_amount_cents: Mapped[int | None] = mapped_column(nullable=True)
    confidence_score: Mapped[float | None] = mapped_column(Float, nullable=True)
    prediction_date: Mapped[date] = mapped_column(Date, nullable=False)
    target_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    category_id: Mapped[int | None] = mapped_column(ForeignKey("categories.id"), nullable=True)
    input_data: Mapped[str | None] = mapped_column(Text, nullable=True)
    result_data: Mapped[str | None] = mapped_column(Text, nullable=True)
    model_version: Mapped[str | None] = mapped_column(String(50), nullable=True)
    error_message: Mapped[str | None] = mapped_column(String(500), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    user: Mapped["User"] = relationship(back_populates="predictions")
