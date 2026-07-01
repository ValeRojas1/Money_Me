from datetime import datetime

from pydantic import BaseModel, Field

from src.domain.models.capture import CaptureSource, CaptureStatus


class CaptureResponse(BaseModel):
    id: int
    user_id: int
    source: CaptureSource
    status: CaptureStatus
    raw_image_url: str | None
    processed_image_url: str | None
    raw_text: str | None
    merchant_name: str | None
    total_cents: int | None
    currency: str | None
    capture_date: datetime | None
    confidence_score: float | None
    error_message: str | None
    detected_items: str | None
    created_at: datetime
    processed_at: datetime | None

    model_config = {"from_attributes": True}


class CaptureHistoryResponse(BaseModel):
    id: int
    source: CaptureSource
    status: CaptureStatus
    merchant_name: str | None
    total_cents: int | None
    currency: str | None
    confidence_score: float | None
    created_at: datetime

    model_config = {"from_attributes": True}
