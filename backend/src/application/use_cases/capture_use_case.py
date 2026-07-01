from datetime import date, datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.errors import NotFoundError
from src.domain.models.capture import CaptureStatus, ProcessedCapture
from src.domain.models.movement import Movement, MovementStatus, MovementType


class CaptureUseCase:

    async def confirm_capture(
        self,
        db: AsyncSession,
        user_id: int,
        capture_id: int,
        edits: dict | None = None,
    ) -> dict:
        stmt = select(ProcessedCapture).where(
            ProcessedCapture.id == capture_id,
            ProcessedCapture.user_id == user_id,
        )
        result = await db.execute(stmt)
        capture = result.scalar_one_or_none()
        if not capture:
            raise NotFoundError("Capture not found")

        amount_cents = edits.get("amount_cents", capture.total_cents) if edits else capture.total_cents
        description = edits.get("description", capture.merchant_name or "Captured transaction") if edits else (capture.merchant_name or "Captured transaction")
        transaction_date_str = edits.get("transaction_date", str(capture.capture_date.date() if capture.capture_date else date.today())) if edits else str(capture.capture_date.date() if capture.capture_date else date.today())

        txn_date = date.fromisoformat(transaction_date_str) if isinstance(transaction_date_str, str) else transaction_date_str

        movement_type = MovementType.EXPENSE
        if amount_cents and amount_cents < 0:
            movement_type = MovementType.INCOME
            amount_cents = abs(amount_cents)

        movement = Movement(
            user_id=user_id,
            wallet_id=edits.get("wallet_id", 1) if edits else 1,
            category_id=edits.get("category_id", 2) if edits else 2,
            type=movement_type,
            status=MovementStatus.COMPLETED,
            amount_cents=amount_cents or 0,
            description=description or "Captured transaction",
            transaction_date=txn_date,
            capture_id=capture_id,
            notes=edits.get("notes") if edits else None,
        )
        db.add(movement)
        capture.status = CaptureStatus.COMPLETED
        await db.commit()
        await db.refresh(movement)

        return {
            "movement_id": movement.id,
            "amount_cents": movement.amount_cents,
            "description": movement.description,
            "date": movement.transaction_date.isoformat(),
            "status": "confirmed",
        }

    async def reject_capture(
        self,
        db: AsyncSession,
        user_id: int,
        capture_id: int,
    ) -> dict:
        stmt = select(ProcessedCapture).where(
            ProcessedCapture.id == capture_id,
            ProcessedCapture.user_id == user_id,
        )
        result = await db.execute(stmt)
        capture = result.scalar_one_or_none()
        if not capture:
            raise NotFoundError("Capture not found")

        capture.status = CaptureStatus.FAILED
        capture.error_message = "Rejected by user"
        await db.commit()

        return {"status": "rejected", "capture_id": capture_id}

    async def reprocess_capture(
        self,
        db: AsyncSession,
        user_id: int,
        capture_id: int,
    ) -> dict:
        stmt = select(ProcessedCapture).where(
            ProcessedCapture.id == capture_id,
            ProcessedCapture.user_id == user_id,
        )
        result = await db.execute(stmt)
        capture = result.scalar_one_or_none()
        if not capture:
            raise NotFoundError("Capture not found")

        capture.status = CaptureStatus.PENDING
        capture.error_message = None
        await db.commit()

        return {"status": "pending_reprocessing", "capture_id": capture_id}

    async def list_history(
        self,
        db: AsyncSession,
        user_id: int,
    ) -> list[dict]:
        stmt = select(ProcessedCapture).where(
            ProcessedCapture.user_id == user_id,
        ).order_by(ProcessedCapture.created_at.desc()).limit(50)
        result = await db.execute(stmt)
        captures = result.scalars().all()

        return [
            {
                "id": c.id,
                "source": c.source.value,
                "status": c.status.value,
                "merchant_name": c.merchant_name,
                "total_cents": c.total_cents,
                "currency": c.currency,
                "confidence_score": c.confidence_score,
                "error_message": c.error_message,
                "created_at": c.created_at.isoformat(),
                "can_confirm": c.status == CaptureStatus.PENDING or c.status == CaptureStatus.FAILED,
                "status_label": self._status_label(c.status),
            }
            for c in captures
        ]

    async def create_manual_movement(
        self,
        db: AsyncSession,
        user_id: int,
        data: dict,
    ) -> dict:
        movement = Movement(
            user_id=user_id,
            wallet_id=data.get("wallet_id", 1),
            category_id=data.get("category_id", 2),
            type=MovementType(data.get("type", "expense")),
            status=MovementStatus.COMPLETED,
            amount_cents=data.get("amount_cents", 0),
            description=data.get("description", ""),
            notes=data.get("notes"),
            transaction_date=date.fromisoformat(data.get("date", str(date.today()))),
        )
        db.add(movement)
        await db.commit()
        await db.refresh(movement)

        return {
            "movement_id": movement.id,
            "amount_cents": movement.amount_cents,
            "description": movement.description,
            "type": movement.type.value,
            "date": movement.transaction_date.isoformat(),
            "status": "created",
        }

    def _status_label(self, status: CaptureStatus) -> str:
        labels = {
            CaptureStatus.PENDING: "Pending review",
            CaptureStatus.PROCESSING: "Processing...",
            CaptureStatus.COMPLETED: "Completed",
            CaptureStatus.FAILED: "Failed",
        }
        return labels.get(status, "Unknown")
