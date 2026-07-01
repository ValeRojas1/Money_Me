from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.errors import NotFoundError
from src.domain.models.category import Category, CategoryType
from src.domain.schemas.category import CategoryCreate, CategoryUpdate


class CategoryUseCase:

    async def list_categories(
        self,
        db: AsyncSession,
        type_filter: str | None = None,
    ) -> list[dict]:
        stmt = select(Category).where(Category.is_active == True).order_by(Category.sort_order, Category.name)
        if type_filter:
            stmt = stmt.where(Category.type == CategoryType(type_filter))
        result = await db.execute(stmt)
        categories = result.scalars().all()

        return [
            {
                "id": c.id,
                "name": c.name,
                "type": c.type.value,
                "icon": c.icon,
                "color": c.color,
                "parent_id": c.parent_id,
                "is_system": c.is_system,
                "sort_order": c.sort_order,
            }
            for c in categories
        ]

    async def create_category(self, db: AsyncSession, data: CategoryCreate) -> dict:
        category = Category(
            name=data.name,
            type=data.type,
            icon=data.icon,
            color=data.color,
            parent_id=data.parent_id,
            sort_order=data.sort_order,
            is_system=False,
        )
        db.add(category)
        await db.commit()
        await db.refresh(category)

        return {
            "id": category.id,
            "name": category.name,
            "type": category.type.value,
            "icon": category.icon,
            "color": category.color,
            "is_system": False,
        }

    async def update_category(self, db: AsyncSession, category_id: int, data: CategoryUpdate) -> dict:
        stmt = select(Category).where(Category.id == category_id)
        result = await db.execute(stmt)
        category = result.scalar_one_or_none()
        if not category:
            raise NotFoundError("Category not found")

        if data.name is not None:
            category.name = data.name
        if data.icon is not None:
            category.icon = data.icon
        if data.color is not None:
            category.color = data.color
        if data.is_active is not None:
            category.is_active = data.is_active
        if data.sort_order is not None:
            category.sort_order = data.sort_order

        await db.commit()
        return {"message": "Category updated"}

    async def delete_category(self, db: AsyncSession, category_id: int) -> dict:
        stmt = select(Category).where(Category.id == category_id)
        result = await db.execute(stmt)
        category = result.scalar_one_or_none()
        if not category:
            raise NotFoundError("Category not found")
        if category.is_system:
            raise ValueError("Cannot delete system categories")

        await db.delete(category)
        await db.commit()
        return {"message": "Category deleted"}
