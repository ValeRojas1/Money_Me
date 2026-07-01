from datetime import date, datetime
from re import match as re_match

from src.domain.models.movement import MovementType
from src.domain.services.normalizer import FinancialNormalizer


class DomainValidator:

    AMOUNT_MIN = 1
    AMOUNT_MAX = 99_999_999_99  # ~$1B in cents

    @staticmethod
    def validate_amount_cents(amount_cents: int) -> list[str]:
        errors: list[str] = []
        if not isinstance(amount_cents, int):
            errors.append("Amount must be an integer (cents)")
        if amount_cents < DomainValidator.AMOUNT_MIN:
            errors.append(f"Minimum amount is {DomainValidator.AMOUNT_MIN} cent(s)")
        if amount_cents > DomainValidator.AMOUNT_MAX:
            errors.append(f"Amount exceeds maximum allowed")
        return errors

    @staticmethod
    def validate_currency_code(code: str) -> list[str]:
        errors: list[str] = []
        if not code or len(code) != 3:
            errors.append("Currency code must be 3 letters (ISO 4217)")
        elif not code.isalpha() or not code.isupper():
            errors.append("Currency code must be uppercase letters")
        elif not FinancialNormalizer.is_valid_currency(code):
            errors.append(f"Unsupported currency: {code}")
        return errors

    @staticmethod
    def validate_email(email: str) -> list[str]:
        errors: list[str] = []
        if not email:
            errors.append("Email is required")
        elif not re_match(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$", email):
            errors.append("Invalid email format")
        elif len(email) > 255:
            errors.append("Email too long")
        return errors

    @staticmethod
    def validate_password(password: str) -> list[str]:
        errors: list[str] = []
        if len(password) < 8:
            errors.append("Password must be at least 8 characters")
        if len(password) > 128:
            errors.append("Password too long")
        if not re_match(r"[A-Z]", password):
            errors.append("Password must contain an uppercase letter")
        if not re_match(r"[a-z]", password):
            errors.append("Password must contain a lowercase letter")
        if not re_match(r"\d", password):
            errors.append("Password must contain a number")
        return errors

    @staticmethod
    def validate_transaction_date(d: date) -> list[str]:
        errors: list[str] = []
        if not d:
            errors.append("Transaction date is required")
        elif d > date.today():
            errors.append("Transaction date cannot be in the future")
        return errors

    @staticmethod
    def validate_description(desc: str) -> list[str]:
        errors: list[str] = []
        if not desc or not desc.strip():
            errors.append("Description is required")
        elif len(desc) > 500:
            errors.append("Description too long (max 500 characters)")
        return errors

    @staticmethod
    def validate_movement_consistency(
        movement_type: MovementType,
        amount_cents: int,
        wallet_id: int,
        transfer_to_wallet_id: int | None = None,
    ) -> list[str]:
        errors: list[str] = []
        if movement_type == MovementType.TRANSFER:
            if not transfer_to_wallet_id:
                errors.append("Transfer must specify a destination wallet")
            elif transfer_to_wallet_id == wallet_id:
                errors.append("Cannot transfer to the same wallet")
        if amount_cents <= 0:
            errors.append("Amount must be positive")
        return errors

    @staticmethod
    def validate_budget_dates(start_date: date, end_date: date | None, period: str) -> list[str]:
        errors: list[str] = []
        if not start_date:
            errors.append("Start date is required")
        if end_date and end_date <= start_date:
            errors.append("End date must be after start date")
        if period == "custom" and not end_date:
            errors.append("Custom period requires an end date")
        return errors

    @staticmethod
    def validate_notify_percentage(pct: int) -> list[str]:
        errors: list[str] = []
        if pct < 0 or pct > 100:
            errors.append("Notification percentage must be between 0 and 100")
        return errors

    @staticmethod
    def validate_required_fields(obj: dict, fields: list[str]) -> list[str]:
        errors: list[str] = []
        for field in fields:
            if field not in obj or obj[field] is None or (isinstance(obj[field], str) and not obj[field].strip()):
                errors.append(f"{field.replace('_', ' ').title()} is required")
        return errors
