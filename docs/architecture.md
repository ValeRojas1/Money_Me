# Money Me - Architecture

## Overview

Money Me is a personal finance management application with a **Flutter web frontend** and a **FastAPI (Python) backend**. The architecture follows clean architecture principles with clear separation of concerns.

## Project Structure

```
money_me/
├── lib/                          # Flutter frontend (Clean Architecture)
│   ├── main.dart                 # App entry point
│   ├── app/                      # App configuration, routing, theming
│   ├── core/                     # Shared utilities, networking, constants
│   ├── features/                 # Feature-based modules (DDD)
│   │   ├── auth/                 # Authentication module
│   │   ├── dashboard/            # Main dashboard
│   │   ├── transactions/         # Transaction management
│   │   ├── analysis/             # Spending analysis
│   │   ├── predictions/          # ML-based predictions
│   │   ├── reports/              # Report generation
│   │   └── ocr/                  # Receipt/invoice scanning
│   └── shared/                   # Reusable widgets and extensions
├── backend/                      # FastAPI backend (Hexagonal Architecture)
│   ├── src/
│   │   ├── main.py               # FastAPI app entry point
│   │   ├── config/               # Environment, database config
│   │   ├── api/                  # API layer (routes, controllers, middleware)
│   │   ├── core/                 # Security, error handling
│   │   ├── domain/               # Business entities, schemas, services
│   │   ├── application/          # Use cases, ports (interfaces)
│   │   └── infrastructure/       # DB, OCR, ML, external integrations
│   └── tests/                    # Test suite
└── docs/                         # Documentation and API contracts
```

## Architecture Layers

### Frontend (Flutter) - Clean Architecture

1. **Presentation Layer** - Widgets, pages, state providers (ChangeNotifier/Provider)
2. **Domain Layer** - Entities, repository interfaces, use cases
3. **Data Layer** - Repository implementations, data sources (remote/local), DTOs/models

### Backend (FastAPI) - Hexagonal Architecture

1. **API Layer** (`api/`) - Route handlers, controllers, middleware, dependencies
2. **Application Layer** (`application/`) - Use cases, port interfaces
3. **Domain Layer** (`domain/`) - Business entities, schemas, domain services
4. **Infrastructure Layer** (`infrastructure/`) - Database, OCR, ML, external service implementations

## Key Design Decisions

- **Stateless Backend**: The API is stateless; authentication uses JWT tokens
- **Async Everywhere**: Both Flutter (I/O) and FastAPI (async/await) use async patterns
- **Environment Variables**: All configuration via environment (pydantic-settings for backend, --dart-define for Flutter)
- **Feature-based Modules**: Frontend organized by feature, not by layer type
- **API Versioning**: All routes under `/api/v1/` for future backward compatibility
- **REST Contracts**: Documented in `docs/api-contracts/`

## Data Flow

```
[Flutter Web] --HTTP/JSON--> [FastAPI API] --> [Application Use Cases]
                                                    |
                                            [Domain Services]
                                                    |
                                            [Infrastructure]
                                              (DB / OCR / ML)
```
