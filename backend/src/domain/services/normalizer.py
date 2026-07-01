from datetime import date, datetime, timezone


class FinancialNormalizer:
    CURRENCIES_WITH_CENTS: dict[str, int] = {
        "USD": 100,
        "EUR": 100,
        "GBP": 100,
        "MXN": 100,
        "COP": 100,
        "ARS": 100,
        "CLP": 1,
        "JPY": 1,
        "KRW": 1,
    }

    @staticmethod
    def to_cents(amount: float, currency: str = "USD") -> int:
        decimals = FinancialNormalizer.CURRENCIES_WITH_CENTS.get(currency.upper(), 100)
        return round(amount * decimals)

    @staticmethod
    def from_cents(cents: int, currency: str = "USD") -> float:
        decimals = FinancialNormalizer.CURRENCIES_WITH_CENTS.get(currency.upper(), 100)
        return cents / decimals

    @staticmethod
    def normalize_amount(amount: float, currency: str = "USD") -> int:
        return FinancialNormalizer.to_cents(amount, currency)

    @staticmethod
    def truncate_decimal(value: float, decimals: int = 2) -> float:
        return round(value, decimals)

    @staticmethod
    def to_utc(dt: datetime) -> datetime:
        if dt.tzinfo is None:
            return dt.replace(tzinfo=timezone.utc)
        return dt.astimezone(timezone.utc)

    @staticmethod
    def is_valid_currency(code: str) -> bool:
        return code.upper() in FinancialNormalizer.CURRENCIES_WITH_CENTS

    @staticmethod
    def get_decimals(currency: str) -> int:
        decimals = FinancialNormalizer.CURRENCIES_WITH_CENTS.get(currency.upper(), 100)
        return len(str(decimals)) - 1 if decimals > 1 else 0


class DateRules:
    @staticmethod
    def is_future(d: date) -> bool:
        return d > date.today()

    @staticmethod
    def is_past(d: date) -> bool:
        return d < date.today()

    @staticmethod
    def is_today(d: date) -> bool:
        return d == date.today()

    @staticmethod
    def days_between(start: date, end: date) -> int:
        return (end - start).days

    @staticmethod
    def is_within_fiscal_year(d: date, year: int) -> bool:
        return d.year == year

    @staticmethod
    def is_within_range(d: date, start: date, end: date) -> bool:
        return start <= d <= end

    @staticmethod
    def last_day_of_month(d: date) -> date:
        import calendar
        last_day = calendar.monthrange(d.year, d.month)[1]
        return date(d.year, d.month, last_day)

    @staticmethod
    def first_day_of_month(d: date) -> date:
        return date(d.year, d.month, 1)
