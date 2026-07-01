from datetime import date

from pydantic import BaseModel, Field


class BudgetCreate(BaseModel):
    category_id: int
    name: str = Field(..., min_length=1, max_length=255)
    period: str = Field(..., pattern=r"^(weekly|monthly|quarterly|annual|custom)$")
    limit_cents: int = Field(..., gt=0)
    currency: str = "USD"
    start_date: date | None = None
    end_date: date | None = None
    is_rollover: bool = False
    notify_at_percentage: int = Field(default=80, ge=1, le=100)


class BudgetUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=255)
    period: str | None = Field(None, pattern=r"^(weekly|monthly|quarterly|annual|custom)$")
    limit_cents: int | None = Field(None, gt=0)
    start_date: date | None = None
    end_date: date | None = None
    is_rollover: bool | None = None
    notify_at_percentage: int | None = Field(None, ge=1, le=100)
    status: str | None = Field(None, pattern=r"^(active|paused|completed|expired)$")
