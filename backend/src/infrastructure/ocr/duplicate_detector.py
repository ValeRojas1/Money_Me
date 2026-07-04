import hashlib
import re
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
    def _normalize_text(text: str) -> str:
        """Collapse whitespace and lowercase so near-identical OCR text matches."""
        return re.sub(r"\s+", " ", (text or "").strip().lower())

    @staticmethod
    async def check_exact_duplicate(
        db: AsyncSession,
        user_id: int,
        raw_text: str,
    ) -> bool:
        """
        Detect if the same receipt was already scanned by comparing the
        normalized OCR text against recent captures for this user.

        The previous implementation compared a SHA-256 image hash against the
        stored raw_text column (which never holds a hash), so it never matched.
        Comparing normalized OCR text is schema-safe (no new column) and works
        because two scans of the same image produce virtually identical text.
        """
        normalized = DuplicateDetector._normalize_text(raw_text)
        if not normalized or len(normalized) < 12:
            # Too little text to reliably decide it's a duplicate.
            return False

        stmt = (
            select(ProcessedCapture.raw_text)
            .where(ProcessedCapture.user_id == user_id)
            .order_by(ProcessedCapture.created_at.desc())
            .limit(200)
        )
        result = await db.execute(stmt)
        for (existing_text,) in result.all():
            if DuplicateDetector._normalize_text(existing_text) == normalized:
                return True
        return False

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
