from datetime import datetime

from pydantic import BaseModel, Field

from src.domain.models.export import ExportFormat, ExportStatus, ExportType


class ExportCreate(BaseModel):
    type: ExportType
    format: ExportFormat
    start_date: str | None = None
    end_date: str | None = None
    categories: list[int] | None = None


class ExportResponse(BaseModel):
    id: int
    user_id: int
    type: ExportType
    format: ExportFormat
    status: ExportStatus
    file_url: str | None
    file_size_bytes: int | None
    error_message: str | None
    created_at: datetime
    completed_at: datetime | None

    model_config = {"from_attributes": True}


class ExportHistoryResponse(BaseModel):
    id: int
    type: ExportType
    format: ExportFormat
    status: ExportStatus
    file_url: str | None
    created_at: datetime

    model_config = {"from_attributes": True}
