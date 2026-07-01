from datetime import datetime

from pydantic import BaseModel, Field

from src.domain.models.alert import AlertSeverity, AlertStatus, AlertType


class AlertResponse(BaseModel):
    id: int
    user_id: int
    type: AlertType
    severity: AlertSeverity
    status: AlertStatus
    title: str
    message: str
    reference_type: str | None
    reference_id: int | None
    threshold_value: float | None
    current_value: float | None
    is_read: bool
    read_at: datetime | None
    created_at: datetime

    model_config = {"from_attributes": True}


class AlertUpdate(BaseModel):
    status: AlertStatus | None = None
    is_read: bool | None = None
