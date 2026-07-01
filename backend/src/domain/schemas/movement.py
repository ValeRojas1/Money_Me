from datetime import date, datetime

from pydantic import BaseModel, Field, field_validator, model_validator

from src.domain.models.movement import MovementStatus, MovementType


class MovementCreate(BaseModel):
    wallet_id: int
    category_id: int
    type: MovementType
    amount_cents: int = Field(..., gt=0)
    currency: str = Field(default="USD", min_length=3, max_length=3)
    description: str = Field(..., min_length=1, max_length=500)
    notes: str | None = Field(None, max_length=2000)
    transaction_date: date
    is_recurring: bool = False
    recurring_frequency: str | None = Field(None, max_length=50)
    tags: str | None = Field(None, max_length=500)
    receipt_url: str | None = Field(None, max_length=500)
    capture_id: int | None = None
    transfer_to_wallet_id: int | None = None
    exchange_rate: float | None = Field(None, gt=0)
    original_amount_cents: int | None = Field(None, gt=0)
    original_currency: str | None = Field(None, min_length=3, max_length=3)

    @field_validator("currency", "original_currency")
    @classmethod
    def validate_currency(cls, v: str | None) -> str | None:
        return v.upper() if v else v

    @model_validator(mode="after")
    def validate_transfer(self) -> "MovementCreate":
        if self.type == MovementType.TRANSFER and not self.transfer_to_wallet_id:
            raise ValueError("Transfer must specify target wallet")
        if self.transfer_to_wallet_id and self.transfer_to_wallet_id == self.wallet_id:
            raise ValueError("Cannot transfer to the same wallet")
        if self.original_amount_cents and not self.original_currency:
            raise ValueError("Original currency required when original amount is set")
        if self.exchange_rate and not self.original_amount_cents:
            raise ValueError("Original amount required when exchange rate is set")
        return self

    @field_validator("transaction_date")
    @classmethod
    def date_not_in_future(cls, v: date) -> date:
        from datetime import date as dt_date
        if v > dt_date.today():
            raise ValueError("Transaction date cannot be in the future")
        return v

    @field_validator("recurring_frequency")
    @classmethod
    def recurring_requires_flag(cls, v: str | None, info) -> str | None:
        if v is not None and not info.data.get("is_recurring"):
            raise ValueError("Set is_recurring=true when providing recurring_frequency")
        return v


class MovementUpdate(BaseModel):
    description: str | None = Field(None, min_length=1, max_length=500)
    notes: str | None = Field(None, max_length=2000)
    category_id: int | None = None
    status: MovementStatus | None = None
    tags: str | None = Field(None, max_length=500)


class MovementResponse(BaseModel):
    id: int
    wallet_id: int
    category_id: int
    user_id: int
    type: MovementType
    status: MovementStatus
    amount_cents: int
    currency: str
    description: str
    notes: str | None
    transaction_date: date
    is_recurring: bool
    recurring_frequency: str | None
    tags: str | None
    receipt_url: str | None
    capture_id: int | None
    transfer_to_wallet_id: int | None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
