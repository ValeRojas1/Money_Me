from fastapi import Request
from fastapi.responses import JSONResponse

from src.core.errors import (
    ConflictError,
    ForbiddenError,
    NotFoundError,
    UnauthorizedError,
    ValidationError,
)

USER_MESSAGES = {
    400: "The request could not be processed. Please check your data and try again.",
    401: "Your session has expired or your credentials are invalid. Please sign in again.",
    403: "You don't have permission to perform this action.",
    404: "The requested information was not found. It may have been deleted.",
    409: "This information already exists in our system.",
    422: "Some of the data provided is not valid. Please review and correct it.",
    429: "Too many requests. Please wait a moment and try again.",
    500: "Something went wrong on our end. Please try again later.",
}


async def global_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    status = getattr(exc, "status_code", 500)
    detail = getattr(exc, "detail", None) or str(exc)

    return JSONResponse(
        status_code=status,
        content={
            "error": True,
            "code": status,
            "detail": detail,
            "message": USER_MESSAGES.get(status, USER_MESSAGES[500]),
            "path": str(request.url.path),
        },
    )


async def http_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    status = getattr(exc, "status_code", 500)
    detail = getattr(exc, "detail", None) or str(exc)

    return JSONResponse(
        status_code=status,
        content={
            "error": True,
            "code": status,
            "detail": detail,
            "message": USER_MESSAGES.get(status, USER_MESSAGES[500]),
            "path": str(request.url.path),
        },
    )
