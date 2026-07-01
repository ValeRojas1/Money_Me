from datetime import date, datetime

from pydantic import BaseModel, Field

from src.domain.models.prediction import PredictionStatus, PredictionType


class PredictionResponse(BaseModel):
    id: int
    user_id: int
    type: PredictionType
    status: PredictionStatus
    predicted_amount_cents: int | None
    confidence_score: float | None
    prediction_date: date
    target_date: date | None
    category_id: int | None
    result_data: str | None
    model_version: str | None
    created_at: datetime

    model_config = {"from_attributes": True}


class MonthlySpendingPrediction(BaseModel):
    predicted_amount_cents: int
    confidence_score: float
    categories: list[dict]


class BudgetRecommendation(BaseModel):
    category: str
    suggested_budget_cents: int
    current_avg_cents: int


class SavingsGoalPrediction(BaseModel):
    goal_amount_cents: int = Field(..., gt=0)
    monthly_savings_cents: int | None = Field(None, gt=0)
