import hashlib
from datetime import date
from typing import Any

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.domain.models.capture import ProcessedCapture
from src.domain.models.movement import Movement


class DuplicateDetector:

    @staticmethod
    def compute_image_hash(data: bytes) -> str:
        return hashlib.sha256(data).hexdigest()

    @staticmethod
    async def check_exact_duplicate(
        db: AsyncSession,
        user_id: int,
        image_hash: str,
    ) -> bool:
        stmt = select(ProcessedCapture).where(
            ProcessedCapture.user_id == user_id,
            ProcessedCapture.raw_text == image_hash,
        )
        result = await db.execute(stmt)
        return result.scalar_one_or_none() is not None

    @staticmethod
    async def check_semantic_duplicate(
        db: AsyncSession,
        user_id: int,
        amount_cents: int,
        transaction_date: date,
        merchant: str | None,
        description: str | None,
    ) -> tuple[bool, float]:
        if not amount_cents or not transaction_date:
            return False, 0.0

        threshold_date = transaction_date.replace(
            month=transaction_date.month - 1 if transaction_date.month > 1 else 12,
            year=transaction_date.year - 1 if transaction_date.month == 1 else transaction_date.year,
        )

        stmt = select(Movement).where(
            Movement.user_id == user_id,
            Movement.amount_cents == amount_cents,
            Movement.transaction_date >= threshold_date,
            Movement.transaction_date <= transaction_date,
        )

        if merchant:
            stmt = stmt.where(Movement.description.ilike(f"%{merchant}%"))

        result = await db.execute(stmt)
        matches = list(result.scalars().all())

        if not matches:
            return False, 0.0

        base_score = 0.6
        if merchant:
            for m in matches:
                if m.description and merchant.lower() in m.description.lower():
                    return True, 0.9
        if description:
            for m in matches:
                if m.description and description.lower() in m.description.lower():
                    return True, 0.85

        return True, base_score

    @staticmethod
    def compute_fingerprint(fields: dict[str, Any]) -> str:
        relevant = {
            "amount": fields.get("amount_cents"),
            "date": str(fields.get("date", "")),
            "merchant": (fields.get("merchant") or "").lower().strip(),
        }
        raw = f"{relevant['amount']}|{relevant['date']}|{relevant['merchant']}"
        return hashlib.md5(raw.encode()).hexdigest()
