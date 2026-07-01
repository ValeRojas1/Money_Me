from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from src.domain.models.category import Category, CategoryType

DEFAULT_CATEGORIES: list[tuple[str, CategoryType, str, str]] = [
    ("Salario", CategoryType.INCOME, "payments", "#22C55E"),
    ("Freelance", CategoryType.INCOME, "work", "#16A34A"),
    ("Inversiones", CategoryType.INCOME, "trending_up", "#15803D"),
    ("Alimentación", CategoryType.EXPENSE, "restaurant", "#EF4444"),
    ("Transporte", CategoryType.EXPENSE, "directions_car", "#F97316"),
    ("Vivienda", CategoryType.EXPENSE, "home", "#8B5CF6"),
    ("Servicios", CategoryType.EXPENSE, "bolt", "#6366F1"),
    ("Salud", CategoryType.EXPENSE, "medical_services", "#EC4899"),
    ("Entretenimiento", CategoryType.EXPENSE, "movie", "#06B6D4"),
    ("Compras", CategoryType.EXPENSE, "shopping_bag", "#F59E0B"),
    ("Educación", CategoryType.EXPENSE, "school", "#3B82F6"),
    ("Otros gastos", CategoryType.EXPENSE, "more_horiz", "#6B7280"),
    ("Ahorro", CategoryType.SAVINGS, "savings", "#10B981"),
    ("Transferencia", CategoryType.TRANSFER, "swap_horiz", "#64748B"),
]


async def seed_database(session: AsyncSession) -> None:
    result = await session.execute(select(func.count()).select_from(Category))
    count = result.scalar_one()
    if count:
        return

    for index, (name, category_type, icon, color) in enumerate(DEFAULT_CATEGORIES):
        session.add(
            Category(
                name=name,
                type=category_type,
                icon=icon,
                color=color,
                is_system=True,
                is_active=True,
                sort_order=index,
            )
        )

    await session.commit()
