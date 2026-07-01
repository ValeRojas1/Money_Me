from datetime import datetime

from pydantic import BaseModel, Field

from src.domain.models.category import CategoryType


class CategoryCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    type: CategoryType
    icon: str | None = Field(None, max_length=50)
    color: str | None = Field(None, pattern=r"^#[0-9A-Fa-f]{6}$")
    parent_id: int | None = None
    sort_order: int = 0


class CategoryUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=100)
    icon: str | None = Field(None, max_length=50)
    color: str | None = Field(None, pattern=r"^#[0-9A-Fa-f]{6}$")
    is_active: bool | None = None
    sort_order: int | None = None


class CategoryResponse(BaseModel):
    id: int
    name: str
    type: CategoryType
    icon: str | None
    color: str | None
    parent_id: int | None
    is_system: bool
    is_active: bool
    sort_order: int
    created_at: datetime

    model_config = {"from_attributes": True}
