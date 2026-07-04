# Plan de Implementación de Pruebas Automatizadas

> **Proyecto:** MoneyMe — FastAPI Backend + Flutter Web Frontend
> **Estado actual:** 88 tests backend (pytest) + 72 tests frontend (flutter_test)
> **Meta:** Suite automatizada > 90% cobertura crítica, CI/CD integrado

---

## 1. Diagnóstico actual

### Backend — Cobertura por módulo

| Módulo | Tests | Endpoints | Cobertura estimada | Estado |
|--------|-------|-----------|-------------------|--------|
| Auth | 20 | 7 | ~95% | ✅ Completo |
| Transactions | 12 | 6 | ~90% | ✅ Completo |
| Wallets | 7 | 5 | ~85% | ✅ Completo |
| Categories | 6 | 4 | ~85% | ✅ Completo |
| Dashboard | 6 | 5 | ~80% | ⚠️ Regular |
| OCR | 8 | 4 | ~80% | ✅ Completo |
| Budgets | 7 | 4 | ~85% | ✅ Completo |
| Export | 7 | 3 | ~85% | ✅ Completo |
| Analysis | 4 | 2 | ~75% | ✅ Completo |
| Predictions | 4 | 2 | ~75% | ✅ Completo |
| Integration | 5 | 5 flujos | n/a | ✅ Completo |
| Reports | 0 | 2 | 0% | ❌ Sin tests |
| **Total** | **88** | **44** | **~80%** | |

### Frontend — Cobertura por capa

| Capa | Tests | Estado |
|------|-------|--------|
| Theme/Estilos + UserFriendlyError | 23 | ✅ Completo |
| Providers (Auth, Transaction, Dashboard, OCR) | 37 | ✅ Completo |
| Widgets (MoneyButton, MoneyFormField, MoneyCard) | 20 | ✅ Completo |
| Pages (cada feature) | 0 | ❌ Sin tests |
| **Total** | **72** | |

### Brechas identificadas

1. ~~Análisis y Predicciones: 0 tests~~ → ✅ 8 tests
2. ~~Presupuestos y Export: tests básicos~~ → ✅ 7 tests cada uno
3. ~~OCR: mock Tesseract~~ → ✅ implementado
4. ~~Frontend providers: 0 tests~~ → ✅ 37 tests
5. ~~Tests de integración: 0~~ → ✅ 5 flujos multi-endpoint
6. ~~Tests E2E: 0~~ → ✅ implementado (3 flujos)
7. ~~CI/CD: 0~~ → ✅ implementado
8. **Reports**: 0 tests — módulo sin verificación

---

## 2. Plan por fases

### ✅ Fase 1 — Cobertura crítica faltante (Completada)

| Tarea | Módulo | Estado |
|-------|--------|--------|
| `test_analysis.py` — 4 tests | Analysis | ✅ |
| `test_predictions.py` — 4 tests | Predictions | ✅ |
| `test_budgets.py` — +3 tests | Budgets | ✅ |
| `test_export.py` — +2 tests | Export | ✅ |
| `test_ocr.py` — mock Tesseract +2 tests | OCR | ✅ |

**Resultado**: +15 tests → **83 tests backend** (+12 de lo estimado)

### ✅ Fase 2 — Frontend: Providers + Widgets (Completada)

| Tarea | Archivo | Estado |
|-------|---------|--------|
| `auth_provider_test.dart` — 10 tests | `test/providers/` | ✅ |
| `transaction_provider_test.dart` — 9 tests | `test/providers/` | ✅ |
| `dashboard_provider_test.dart` — 8 tests | `test/providers/` | ✅ |
| `ocr_provider_test.dart` — 10 tests | `test/providers/` | ✅ |
| `money_button_test.dart` — 7 tests | `test/widgets/` | ✅ |
| `money_form_field_test.dart` — 7 tests | `test/widgets/` | ✅ |
| `money_card_test.dart` — 6 tests | `test/widgets/` | ✅ |

**Resultado**: +57 tests → **72 tests frontend** (+8 de lo estimado)

### ✅ Fase 3 — Tests de integración backend (Completada)

| Flujo | Archivo | Endpoints | Estado |
|-------|---------|-----------|--------|
| Registro → Login → Wallet → Transacción → Dashboard | `test_integration.py` | `POST /auth/register`, `POST /auth/login`, `GET /auth/me`, `POST /wallets/`, `POST /categories/`, `POST /transactions/`, `GET /dashboard/summary`, `GET /dashboard/top-categories`, `GET /wallets/{id}` | ✅ |
| Login → Categoría → Transacción → Export CSV | `test_integration.py` | `POST /auth/register`, `POST /wallets/`, `POST /categories/`, `POST /transactions/`, `GET /reports/export/csv` | ✅ |
| Login → OCR Scan (mocked) → History → Manual | `test_integration.py` | `POST /auth/register`, `POST /wallets/`, `POST /categories/`, `POST /ocr/scan-receipt`, `GET /ocr/history`, `POST /ocr/manual` | ✅ |
| Login → Presupuesto → Transacciones → Alertas | `test_integration.py` | `POST /auth/register`, `POST /wallets/`, `POST /categories/`, `POST /budgets/`, `POST /transactions/`, `GET /budgets/alerts`, `GET /budgets/` | ✅ |
| Login → Crear wallet → Eliminar → Ver lista | `test_integration.py` | `POST /auth/register`, `POST /wallets/` (x2), `DELETE /wallets/{id}`, `GET /wallets/`, `GET /wallets/{id}` | ✅ |

**Resultado**: 5 flujos → **88 tests backend total**

### ✅ Fase 4 — CI/CD Pipeline (Completada)

**Archivo**: `.github/workflows/test.yml`

| Característica | Implementación |
|---------------|---------------|
| Trigger en push a `main`/`develop` | ✅ |
| Trigger en PR a `main` | ✅ |
| Cancelación automática de runs previos | ✅ (vía `concurrency`) |
| Backend job (pytest) | ✅ Python 3.12, caching pip, SQLite |
| Frontend job (flutter test) | ✅ Flutter 3.27, caching pub |
| Ejecución paralela backend + frontend | ✅ |
| Variables de entorno | ✅ `DATABASE_URL` forzada a SQLite |

**Configuración adicional requerida** (1 vez en GitHub):
1. Ir a Settings → Secrets and variables → Actions
2. Agregar cualquier secret necesario (ninguno requerido por ahora)
3. El workflow se ejecutará automáticamente en el próximo `push`

### ✅ Fase 5 — Tests E2E (Completada)

**Herramienta:** `integration_test` (Flutter SDK oficial)

| Archivo | Flujo | Estado |
|---------|-------|--------|
| `integration_test/auth_flow_test.dart` | Login → Dashboard validación | ✅ |
| `integration_test/auth_flow_test.dart` | Login fallido → mensaje de error | ✅ |
| `integration_test/transaction_flow_test.dart` | Login → Dashboard → Transacciones | ✅ |
| `integration_test/navigation_test.dart` | Navegar todos los tabs del bottom nav | ✅ |

**Helper scripts:**

| Script | Propósito |
|--------|-----------|
| `backend/seed_e2e.py` | Crea DB + cataloga test user/wallet/transaccion |
| `backend/run_e2e.ps1` | Seed + inicia servidor (Windows) |
| `backend/run_e2e.sh` | Seed + inicia servidor (Linux/CI) |

**Ejecución local:**
```bash
# Terminal 1: Backend
cd backend
$env:DATABASE_URL="sqlite+aiosqlite:///./data/e2e.db"
python seed_e2e.py
uvicorn src.main:app --port 8000

# Terminal 2: E2E tests
cd money_me
flutter test integration_test/ --dart-define=API_BASE_URL=http://localhost:8000
```

**CI Pipeline:** El job `e2e` en `.github/workflows/test.yml` automatiza:
1. Seed DB
2. Inicia backend en background
3. Ejecuta `flutter test integration_test/`

---

## 3. Infraestructura de tests

### Backend — Configuración actual (conftest.py)

```
tests/
├── conftest.py            ← Fixtures: db, client, auth_headers, test_user, test_wallet, test_category, test_movement
├── pyproject.toml         ← pytest config
├── test_analysis.py       ← 4 tests  ✅
├── test_auth.py           ← 20 tests ✅
├── test_budgets.py        ← 7 tests  ✅
├── test_categories.py     ← 6 tests  ✅
├── test_dashboard.py      ← 6 tests  ✅
├── test_export.py         ← 7 tests  ✅
├── test_integration.py    ← 5 flows  ✅
├── test_ocr.py            ← 8 tests  ✅
├── test_predictions.py    ← 4 tests  ✅
├── test_transactions.py   ← 12 tests ✅
└── test_wallets.py        ← 7 tests  ✅
```

### Frontend — Estructura propuesta

```
test/
├── widget_test.dart                  ← 23 tests (theme + UserFriendlyError)
├── providers/
│   ├── auth_provider_test.dart       ← 10 tests ✅
│   ├── transaction_provider_test.dart ← 9 tests ✅
│   ├── dashboard_provider_test.dart  ← 8 tests ✅
│   └── ocr_provider_test.dart        ← 10 tests ✅
├── widgets/
│   ├── money_button_test.dart        ← 7 tests  ✅
│   ├── money_form_field_test.dart    ← 7 tests  ✅
│   └── money_card_test.dart          ← 6 tests  ✅
└── integration_test/                 ← Fase 5
    ├── auth_flow_test.dart           ← 2 tests ✅
    ├── transaction_flow_test.dart     ← 1 test  ✅
    └── navigation_test.dart          ← 1 test  ✅
```

---

## 4. Estrategia de mocking

### Backend

| Dependencia externa | Estrategia mock |
|---------------------|-----------------|
| Base de datos | SQLite en memoria (ya implementado en `conftest.py`) |
| Tesseract OCR | `unittest.mock.patch("src.infrastructure.ocr.image_processor.ImageProcessor.process", ...)` |
| JWT/tiempo | Fechas fijas en fixtures. `datetime` controlado |

### Frontend

| Dependencia externa | Estrategia mock |
|---------------------|-----------------|
| ApiClient | Clase Mock que implementa `get/post/put/delete` con datos prefabricados |
| file_picker | Mock que retorna `PlatformFile` dummy |
| Provider | Instancias reales con `ChangeNotifierProvider` en test |

---

## 5. Métricas y OKRs

| Métrica | Actual | Meta Final (Fase 5) |
|---------|--------|---------------------|
| Tests backend | **88** | 88+ |
| Tests frontend | **72** | 72+ |
| Tests integración | **5 flujos** | 5 suites |
| Cobertura backend | ~80% | >85% |
| Cobertura frontend | ~60% | >70% |
| Tiempo ejecución suite | ~35s | <60s |
| CI/CD | **✅ Sí** | Sí |

---

## 6. Priorización

```
✅ Completado:         Fase 1 (cobertura crítica), Fase 2 (frontend), Fase 3 (integración), Fase 4 (CI/CD), Fase 5 (E2E)
```

---

## 7. Comandos de ejecución

```powershell
# Backend — suite completa
python -m pytest -v

# Backend — solo un módulo
python -m pytest tests/test_transactions.py -v

# Backend — con cobertura
python -m pytest --cov=src --cov-report=term-missing

# Backend — test específico
python -m pytest tests/test_auth.py::test_register -v

# Frontend — suite completa
flutter test

# Frontend — con cobertura
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 8. Riesgos y mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Tesseract OCR no disponible en CI | Alta | Medio | Tests OCR con mock de `image_processor` |
| MySQL no disponible en CI | Media | Alto | Tests usan SQLite forzado vía `DATABASE_URL` |
| Flutter web dependencies rotas | Baja | Medio | `pubspec.lock` versionado. `flutter pub upgrade` controlado |
| Tiempo de ejecución crece con más tests | Alta | Bajo | pytest `-n auto` (paralelo). CI timeout 10 min |
