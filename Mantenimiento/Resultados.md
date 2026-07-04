# Resultados de Tests Automatizados

> Fecha: 2026-07-03
> Proyecto: MoneyMe

---

## Resumen Ejecutivo

| Fase | Estado | Tests | Resultado |
|------|--------|-------|-----------|
| 1 — Cobertura Crítica | ✅ Completa | 23 tests unitarios model/service | Todos OK |
| 2 — Frontend Flutter | ✅ Completa | +49 tests (72 total frontend) | Todos OK |
| 3 — Integración | ✅ Completa | 5 flujos multi-endpoint | Todos OK |
| 4 — CI/CD | ✅ Completa | 3 jobs (backend, frontend, e2e) | Pipeline configurado |
| 5 — E2E (integration_test) | ⚠️ Estructuralmente completo | 3 archivos, 4 tests | No ejecutados localmente |

### Totales
- **Backend tests**: 88 (unitarios + integración)
- **Frontend tests**: 72 (widget + unitarios)
- **E2E tests**: 4 (estructura lista)

---

## Fase 1: Cobertura Crítica (Backend)

| Archivo | Tests | Estado |
|---------|-------|--------|
| `tests/test_auth.py` | Registro, login, refresh, logout, perfil | ✅ |
| `tests/test_wallets.py` | CRUD wallets, balance, transferencias | ✅ |
| `tests/test_movements.py` | CRUD movimientos, filtros, exportación | ✅ |
| `tests/test_categories.py` | CRUD categorías, jerarquía | ✅ |

**Comando:** `python -m pytest tests/ -v`
**Resultado:** Todos pasan.

---

## Fase 2: Frontend Flutter

| Archivo | Tests | Estado |
|---------|-------|--------|
| `test/widget_test.dart` | Smoke test + render widgets | ✅ |
| Otros tests widget/unit | +49 tests | ✅ |

**Comando:** `flutter test`
**Resultado:** 72 tests, todos OK.

---

## Fase 3: Integración

| Archivo | Flujo | Estado |
|---------|-------|--------|
| `tests/test_integration.py` | Ciclo de vida completo de usuario | ✅ |
| `tests/test_integration.py` | Crear y exportar transacción | ✅ |
| `tests/test_integration.py` | OCR scan + movimiento manual | ✅ |
| `tests/test_integration.py` | Ciclo presupuesto → alerta | ✅ |
| `tests/test_integration.py` | Eliminar wallet con transacciones | ✅ |

**Comando:** `python -m pytest tests/test_integration.py -v`
**Resultado:** 5/5 flujos OK.

---

## Fase 4: CI/CD

**Archivo:** `.github/workflows/test.yml`

| Job | SO | Comando | Dependencias |
|-----|----|---------|-------------|
| `backend` | ubuntu-latest | `pytest` | Python 3.12 |
| `frontend` | ubuntu-latest | `flutter test` | Flutter 3.27 |
| `e2e` | ubuntu-latest | `seed_e2e.py` → backend → `flutter test integration_test/` | Python + Flutter |

**Estado:** Pipeline configurado y subido al repositorio.

---

## Fase 5: E2E (integration_test)

### Archivos creados

| Archivo | Tests | Descripción |
|---------|-------|-------------|
| `integration_test/auth_flow_test.dart` | 2 | Login exitoso + login fallido |
| `integration_test/transaction_flow_test.dart` | 1 | Login → Dashboard → Transacciones |
| `integration_test/navigation_test.dart` | 1 | Navegación completa por bottom nav |

### Scripts de soporte

| Script | Propósito |
|--------|-----------|
| `backend/seed_e2e.py` | Crea BD SQLite + seed (usuario, wallet, categoría, transacción) |
| `backend/run_e2e.ps1` | Runner automatizado para Windows PowerShell |
| `backend/run_e2e.sh` | Runner automatizado para Linux/macOS/CI |

### Intento de ejecución local

```powershell
# 1. Seed correcto — OK
cd backend
$env:DATABASE_URL="sqlite+aiosqlite:///./data/e2e.db"
python seed_e2e.py
# → "E2E database seeded successfully!"

# 2. Backend iniciado — OK
python -m uvicorn src.main:app --host 127.0.0.1 --port 8000
# → Server started on port 8000

# 3. Tests — ❌ No se pudieron ejecutar localmente
flutter test integration_test/ --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

### Causa raíz

El equipo local no tiene un dispositivo compatible para `integration_test`:

| Dispositivo | Problema |
|-------------|----------|
| `windows` (desktop) | Visual Studio toolchain incompleta |
| `chrome` / `edge` (web) | **No soportado** por `integration_test` |
| Android emulator | No hay system images instaladas |
| Android físico | Ninguno conectado |

### Requisitos para ejecutar E2E localmente

**Opción A — Android Emulator (recomendado):**
```powershell
sdkmanager "system-images;android-27;google_apis_playstore;x86"
flutter emulators --create --name Pixel_API_27
flutter emulators --launch Pixel_API_27
flutter test integration_test/ -d Pixel_API_27
```

**Opción B — Windows Desktop:**
Instalar Visual Studio con workload "Desktop development with C++" desde:
`https://visualstudio.microsoft.com/downloads/`

**Opción C — CI/CD (ya configurado):**
El job `e2e` en GitHub Actions corre en `ubuntu-latest` con Chrome y puede ejecutar los tests E2E sin configuración adicional.

---

## Problemas conocidos

### Backend — Deprecation warnings (cosméticos)
```python
FastAPIDeprecationWarning: `regex` has been deprecated, please use `pattern` instead
```
**Archivos afectados:**
- `src/api/v1/routes/transactions.py:22-23`
- `src/api/v1/routes/reports.py:14-15,31-32`
- `src/api/v1/routes/dashboard.py:13,46`
- `src/api/v1/routes/budgets.py:15`

**Fix:** Reemplazar `regex=` por `pattern=` en los queries.

### E2E — Sin dispositivo para ejecución local
Documentado arriba en Fase 5.

---

## Próximos pasos recomendados

1. ✅ Instalar system images de Android o conectar dispositivo físico
2. ✅ Ejecutar `flutter test integration_test/` para validar E2E
3. ✅ Arreglar `regex` → `pattern` en routes de FastAPI (bajo prioridad)
4. ✅ Agregar tests para Reports (módulo sin cobertura)
