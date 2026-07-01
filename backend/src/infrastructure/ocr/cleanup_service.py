import asyncio
import logging
from datetime import datetime, timedelta, timezone
from pathlib import Path

from sqlalchemy import select

from src.config.database import async_session_factory
from src.domain.models.capture import ProcessedCapture

logger = logging.getLogger(__name__)

UPLOAD_DIR = Path("uploads/captures")
RETENTION_DAYS = 7


def _local_image_path(url: str | None) -> Path | None:
    if not url or url.startswith("http://") or url.startswith("https://"):
        return None
    return UPLOAD_DIR / url


async def cleanup_old_images() -> int:
    """Delete local capture images older than RETENTION_DAYS."""
    cutoff = datetime.now(timezone.utc) - timedelta(days=RETENTION_DAYS)
    removed = 0

    async with async_session_factory() as db:
        stmt = select(ProcessedCapture).where(ProcessedCapture.created_at < cutoff)
        result = await db.execute(stmt)
        captures = result.scalars().all()

        for cap in captures:
            for url_attr in ("raw_image_url", "processed_image_url"):
                path = _local_image_path(getattr(cap, url_attr))
                if not path:
                    continue
                try:
                    if path.exists():
                        path.unlink()
                        removed += 1
                except Exception as e:
                    logger.warning(f"Failed to delete image {path}: {e}")
                setattr(cap, url_attr, None)

        await db.commit()

    if removed:
        logger.info(f"Cleaned up {removed} old capture images (> {RETENTION_DAYS} days)")
    return removed


async def cleanup_loop(interval_hours: int = 24):
    """Background task that periodically removes old images."""
    while True:
        try:
            await cleanup_old_images()
        except Exception as e:
            logger.error(f"Image cleanup error: {e}")
        await asyncio.sleep(interval_hours * 3600)
