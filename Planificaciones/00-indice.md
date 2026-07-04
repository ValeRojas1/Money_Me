# Plan de Pruebas — Money Me

## Estructura

| # | Archivo | Tipo de Prueba |
|---|---------|----------------|
| 01 | `01-pruebas-unitarias-backend.md` | Pruebas unitarias — Backend (Python/FastAPI) |
| 02 | `02-pruebas-unitarias-frontend.md` | Pruebas unitarias — Frontend (Flutter/Dart) |
| 03 | `03-pruebas-integracion.md` | Pruebas de integración |
| 04 | `04-pruebas-regresion.md` | Pruebas de regresión |
| 05 | `05-pruebas-e2e.md` | Pruebas end-to-end (flujo completo) |
| 06 | `06-pruebas-rendimiento.md` | Pruebas de rendimiento y carga |
| 07 | `07-pruebas-seguridad.md` | Pruebas de seguridad |
| 08 | `08-pruebas-aceptacion.md` | Pruebas de aceptación (UAT) |
| 09 | `09-pruebas-api.md` | Pruebas de contrato API |
| 10 | `10-resumen-ejecucion.md` | Resumen, comandos y **resultados de ejecución** |

## Objetivo General

Garantizar que la aplicación Money Me funcione correctamente en todos sus
componentes: autenticación, OCR, transacciones, dashboard, predicciones,
exportación y análisis. Cada tipo de prueba cubre una dimensión distinta
de calidad: corrección, integración, estabilidad, seguridad y experiencia
de usuario.

---

## Resultados de Ejecución — 2026-07-03

> Resumen consolidado. Detalle completo en cada archivo `01`–`09`.

| # | Archivo | Resultado global | Tipo |
|---|---------|------------------|------|
| 01 | Unitarias backend | **88/88 passed** | ✅ Real |
| 02 | Unitarias frontend | **72/72 passed** | ✅ Real |
| 03 | Integración | **12/18 passed** | ⚠️ Mixto |
| 04 | Regresión | **160/160 auto + 9/9 smoke sim.** | ⚠️ Mixto |
| 05 | E2E | **4/5 flujos passed** | 🔶 Simulado |
| 06 | Rendimiento | **4/5 escenarios OK** | 🔶 Simulado |
| 07 | Seguridad | **18/26 checks OK** | ⚠️ Mixto |
| 08 | UAT | **7/8 escenarios passed** | 🔶 Simulado |
| 09 | Contrato API | **22/24 endpoints OK** | ⚠️ Mixto |

**Total automatizado real:** 160 tests passed (88 backend + 72 frontend)  
**Duración total estimada:** ~64 s (suites reales) + ~45 min (simulaciones manuales/E2E)
