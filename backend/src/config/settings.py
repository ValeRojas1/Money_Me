from pydantic_settings import BaseSettings, SettingsConfigDict


def normalize_database_url(url: str) -> str:
    """Convert common DATABASE_URL formats to SQLAlchemy async drivers."""
    if url.startswith("postgresql://"):
        return url.replace("postgresql://", "postgresql+asyncpg://", 1)
    if url.startswith("postgres://"):
        return url.replace("postgres://", "postgresql+asyncpg://", 1)
    if url.startswith("mysql://") and "+aiomysql" not in url:
        return url.replace("mysql://", "mysql+aiomysql://", 1)
    if url.startswith("sqlite:///") and "+aiosqlite" not in url:
        return url.replace("sqlite:///", "sqlite+aiosqlite:///", 1)
    return url


def prepare_postgres_engine_config(url: str) -> tuple[str, dict]:
    """Strip libpq-only params (e.g. sslmode) and map them for asyncpg."""
    from urllib.parse import parse_qsl, urlencode, urlparse, urlunparse

    if not url.startswith("postgresql"):
        return url, {}

    parsed = urlparse(url)
    query_params = dict(parse_qsl(parsed.query, keep_blank_values=True))
    connect_args: dict = {}

    sslmode = query_params.pop("sslmode", None)
    query_params.pop("channel_binding", None)
    query_params.pop("options", None)

    if sslmode in ("require", "verify-ca", "verify-full", "prefer", "allow"):
        connect_args["ssl"] = True

    if "neon.tech" in (parsed.hostname or ""):
        connect_args.setdefault("ssl", True)

    clean_query = urlencode(query_params)
    clean_url = urlunparse(parsed._replace(query=clean_query))
    return clean_url, connect_args


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # Application
    app_name: str = "Money Me API"
    app_version: str = "0.1.0"
    app_env: str = "development"
    debug: bool = True
    api_prefix: str = "/api/v1"

    # Server
    host: str = "0.0.0.0"
    port: int = 8000

    # Security
    secret_key: str = "change-this-to-a-secure-random-key"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 10080

    # Database
    database_url: str = "sqlite+aiosqlite:///./data/money_me.db"

    # CORS
    cors_origins: list[str] = [
        "http://localhost:3000",
        "http://localhost:5000",
        "http://localhost:8080",
        "http://127.0.0.1:8080",
    ]

    # OCR
    tesseract_cmd: str = "/usr/bin/tesseract"

    @property
    def async_database_url(self) -> str:
        return normalize_database_url(self.database_url)

    @property
    def is_postgres(self) -> bool:
        return self.async_database_url.startswith("postgresql")

    @property
    def is_mysql(self) -> bool:
        return self.async_database_url.startswith("mysql")


settings = Settings()
