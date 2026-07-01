from datetime import datetime

from pydantic import BaseModel, Field, field_validator

from src.domain.models.wallet import WalletStatus, WalletType


class WalletCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    type: WalletType
    currency: str = Field(default="USD", min_length=3, max_length=3)
    balance_cents: int = Field(default=0, ge=0)
    credit_limit_cents: int | None = Field(None, ge=0)
    is_default: bool = False
    color: str | None = Field(None, pattern=r"^#[0-9A-Fa-f]{6}$")
    icon: str | None = Field(None, max_length=50)
    institution: str | None = Field(None, max_length=255)

    @field_validator("currency")
    @classmethod
    def validate_currency(cls, v: str) -> str:
        return v.upper()

    @field_validator("credit_limit_cents")
    @classmethod
    def credit_limit_requires_credit(cls, v: int | None, info) -> int | None:
        if v is not None and info.data.get("type") != WalletType.CREDIT_CARD:
            raise ValueError("Credit limit only applies to credit_card wallets")
        return v


class WalletUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=255)
    balance_cents: int | None = Field(None, ge=0)
    status: WalletStatus | None = None
    is_default: bool | None = None
    color: str | None = Field(None, pattern=r"^#[0-9A-Fa-f]{6}$")
    icon: str | None = Field(None, max_length=50)


class WalletResponse(BaseModel):
    id: int
    user_id: int
    name: str
    type: WalletType
    currency: str
    balance_cents: int
    credit_limit_cents: int | None
    status: WalletStatus
    is_default: bool
    color: str | None
    icon: str | None
    institution: str | None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
