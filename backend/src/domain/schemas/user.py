from datetime import datetime
from re import match as re_match

from pydantic import BaseModel, EmailStr, Field, field_validator

from src.domain.models.user import UserStatus


class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=128)
    name: str = Field(..., min_length=1, max_length=255)

    @field_validator("password")
    @classmethod
    def password_strength(cls, v: str) -> str:
        if not re_match(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)", v):
            raise ValueError("Password must contain uppercase, lowercase and a number")
        return v


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    id: int
    email: str
    status: UserStatus
    created_at: datetime

    model_config = {"from_attributes": True}


class UserProfileUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=255)
    phone: str | None = Field(None, max_length=20)
    preferred_currency: str | None = Field(None, min_length=3, max_length=3)
    locale: str | None = Field(None, max_length=10)
    timezone: str | None = Field(None, max_length=50)

    @field_validator("preferred_currency")
    @classmethod
    def validate_currency(cls, v: str | None) -> str | None:
        if v is not None and len(v) != 3:
            raise ValueError("Currency must be a 3-letter ISO 4217 code")
        return v.upper() if v else v
