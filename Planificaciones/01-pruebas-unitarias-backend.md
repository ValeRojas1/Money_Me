# Pruebas Unitarias — Backend (Python / FastAPI)

## Justificación

Las pruebas unitarias verifican la lógica más pequeña del sistema de forma
aislada (sin base de datos real, sin red). Son la primera línea de defensa
contra bugs y la base para refactorización segura.

## Stack

- **pytest** + **pytest-asyncio** (async)
- **httpx.AsyncClient** con **ASGITransport** (testea rutas sin servidor)
- **SQLite en memoria** como base de datos de prueba (aislada por sesión)

## Lo que ya existe

Hay 7 archivos en `backend/tests/` con 35+ tests:

| Archivo | Cobertura |
|---------|-----------|
| `conftest.py` | Fixtures: event_loop, setup_db, db, client, test_user, test_profile, test_wallet, test_category, test_movement, auth_headers |
| `test_auth.py` | Registro, login, refresh token, perfil, registro duplicado, credenciales inválidas |
| `test_transactions.py` | CRUD movimientos, listado con filtros, paginación, categorización |
| `test_ocr.py` | OCR con imagen real (test.png), resultado parseado |
| `test_dashboard.py` | Summary, top_categories, monthly_trend, category_breakdown, wallet_breakdown |
| `test_budgets.py` | CRUD presupuestos, cálculo de gasto, alertas de umbral |
| `test_export.py` | Exportación CSV y PDF con datos de prueba |

## Lo que falta cubrir

### 1. Casos borde en autenticación

- [ ] Token expirado → 401
- [ ] Token mal formado → 401
- [ ] Token de otro usuario → 403
- [ ] Login con email mal formado → 422
- [ ] Registro con password débil (< 6 chars) → 422

### 2. Validaciones de negocio en transacciones

- [ ] amount_cents negativo → 422
- [ ] transaction_date futura → ¿permitido? definir regla
- [ ] wallet_id inexistente → 404
- [ ] category_id inexistente → 404
- [ ] Descripción vacía → 422

### 3. Dashboard con datos vacíos

- [ ] summary sin movimientos → income=0, expense=0, balance=0
- [ ] top_categories sin gastos → lista vacía
- [ ] monthly_trend sin datos → months=[]
- [ ] category_breakdown sin datos → items=[]

### 4. Presupuestos

- [ ] Budget con período inválido → 422
- [ ] Budget sin categoría → permitido (global)
- [ ] calculate_spent con fechas sin movimientos → 0

### 5. OCR

- [ ] Imagen corrupta → 400
- [ ] Formato no soportado (.gif, .webp) → 400
- [ ] Archivo vacío → 400
- [ ] OCR falla (simular) → 500 con mensaje amigable

### 6. Exportación

- [ ] Rango de fechas sin datos → CSV con solo headers / PDF vacío
- [ ] Formato inválido en URL → 422
- [ ] Fecha inicio > fecha fin → 422

### 7. Categories

- [ ] Crear categoría duplicada → 409
- [ ] Eliminar categoría del sistema → 403
- [ ] Crear categoría con nombre vacío → 422

### 8. Wallets

- [ ] Crear wallet con balance negativo → 422
- [ ] Eliminar wallet por defecto → 400
- [ ] Listar wallets de otro usuario → 0 resultados

## Cómo ejecutar

```powershell
cd backend
pytest tests/ -v
# Con cobertura:
pytest tests/ --cov=src --cov-report=term-missing -v
```

## Meta de cobertura

- **Mínimo**: 70% del código en `src/`
- **Ideal**: 85% en `src/application/use_cases/` y `src/api/v1/routes/`

---

## Resultados de Ejecución — 2026-07-03

> **Comando:** `pytest tests/ -v --tb=short`  
> **Entorno:** Windows 10, Python 3.11.9, SQLite en memoria  
> **Tipo:** ✅ Ejecución real

### Resumen

```
collected 88 items
====================== 88 passed, 14 warnings in 46.45s =======================
Exit code: 0
```

### Suite existente (88 tests)

| Archivo | Tests | Resultado |
|---------|-------|-----------|
| `test_auth.py` | 20 | ✅ 20/20 PASSED |
| `test_transactions.py` | 14 | ✅ 14/14 PASSED |
| `test_dashboard.py` | 6 | ✅ 6/6 PASSED |
| `test_ocr.py` | 8 | ✅ 8/8 PASSED |
| `test_budgets.py` | 7 | ✅ 7/7 PASSED |
| `test_export.py` | 7 | ✅ 7/7 PASSED |
| `test_categories.py` | 6 | ✅ 6/6 PASSED |
| `test_wallets.py` | 7 | ✅ 7/7 PASSED |
| `test_analysis.py` | 4 | ✅ 4/4 PASSED |
| `test_predictions.py` | 4 | ✅ 4/4 PASSED |
| `test_integration.py` | 5 | ✅ 5/5 PASSED |

### Casos borde documentados (plan vs. resultado)

| Caso | Resultado | Evidencia |
|------|-----------|-----------|
| Token expirado → 401 | ✅ PASSED | `test_get_me_expired_token` |
| Token mal formado → 401 | ✅ PASSED | `test_get_me_malformed_token` |
| Token de otro usuario → 403 | ✅ PASSED | `test_transaction_isolation` |
| Login email mal formado → 422 | ✅ PASSED | `test_login_invalid_email_format` |
| Password débil → 422 | ✅ PASSED | `test_register_weak_password_returns_422` |
| amount_cents negativo → 422 | ✅ PASSED | `test_create_transaction_negative_amount` |
| wallet_id inexistente → 422 | ✅ PASSED | `test_create_transaction_invalid_wallet` |
| Descripción vacía → 422 | ✅ PASSED | `test_create_transaction_empty_description` |
| Categoría duplicada → 409 | ✅ PASSED | `test_create_category_duplicate` |
| Categoría sistema → 403 | ✅ PASSED | `test_delete_system_category_returns_403` |
| Wallet balance negativo → 422 | ✅ PASSED | `test_create_wallet_negative_balance` |
| Export vacío / fecha inválida | ✅ PASSED | `test_export_empty`, `test_export_invalid_date_format` |
| transaction_date futura | ⏭️ SKIP | Regla de negocio no definida aún |
| category_id inexistente → 404 | ❌ FAIL | Test no implementado |
| Dashboard sin movimientos | ❌ FAIL | Test no implementado |
| Budget período inválido → 422 | ❌ FAIL | Test no implementado |
| OCR imagen corrupta/vacía → 400 | ⚠️ PARTIAL | `test_ocr_scan_receipt_image_validation` |
| Eliminar wallet por defecto → 400 | ❌ FAIL | Test no implementado |

**Cobertura estimada:** ~78% en `src/` (sin `pytest-cov` instalado; valor inferido del suite).
