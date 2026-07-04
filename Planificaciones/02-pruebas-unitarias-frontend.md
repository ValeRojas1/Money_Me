# Pruebas Unitarias — Frontend (Flutter / Dart)

## Justificación

Verifican que los providers, entidades, modelos y widgets se comporten
correctamente de forma aislada. Flutter web no tiene acceso nativo a
ciertos plugins (file_picker, cámara), por lo que mockear dependencias
es esencial.

## Stack

- **flutter_test** (framework oficial)
- **mockito** o **mocktail** para mocks
- **provider** para inyectar dependencias falsas

## Lo que ya existe

`test/widget_test.dart` — 22 tests de:
- Tema (AppColors, AppTypography, AppSpacing, AppRadius, AppShadows)
- Mensajes de error (UserFriendlyError.fromStatusCode, fromException)

## Lo que falta cubrir

### 1. AuthProvider

- [ ] login exitoso → token guardado, usuario cargado
- [ ] login fallido → errorMessage seteado
- [ ] logout → token borrado, estado reset
- [ ] deleteAccount → llamada a API + navegación a login
- [ ] register exitoso → auto-login
- [ ] register con email duplicado → errorMessage

### 2. TransactionProvider

- [ ] loadTransactions → lista poblada
- [ ] loadTransactions con error → errorMessage
- [ ] create → nuevo elemento en la lista
- [ ] update → elemento modificado
- [ ] delete → elemento removido
- [ ] setSearch → búsqueda aplicada
- [ ] setFilters → filtros aplicados
- [ ] setSort → orden cambiado
- [ ] Paginación: nextPage, hasMore

### 3. DashboardProvider

- [ ] loadAll → los 7 endpoints llamados
- [ ] loadAll con error parcial → datos disponibles
- [ ] loadBudgets → lista poblada
- [ ] clearCache → estado reset

### 4. OcrProvider

- [ ] scanReceiptBytes exitoso → status=completed, result!=null
- [ ] scanReceiptBytes con error → status=error, errorMessage!=null
- [ ] scanReceiptBytes con bytes vacíos → error inmediato
- [ ] reset → status=idle, result=null

### 5. MoneyButton widget

- [ ] Renderiza label correcto
- [ ] isLoading muestra spinner
- [ ] expanded ocupa todo el ancho
- [ ] onPressed null → botón deshabilitado

### 6. MoneyCard widget

- [ ] Renderiza child correctamente
- [ ] Aplica border radius

### 7. MoneyAlert widget

- [ ] Cada tipo (info/success/warning/error) muestra icono distinto
- [ ] Mensaje opcional oculto si es null

### 8. UserFriendlyError (completar)

- [ ] Códigos 400, 401, 403, 404, 409, 422, 429, 500, 503
- [ ] TimeoutException
- [ ] SocketException (sin conexión)
- [ ] HttpException

### 9. ApiClient mockeado

- [ ] GET exitoso → data retornada
- [ ] POST exitoso → body enviado
- [ ] Timeout → ApiException(0)
- [ ] Status 500 → ApiException(500)
- [ ] Respuesta con formato inesperado → manejado

## Cómo ejecutar

```powershell
cd D:\Flutter\MoneyMe\money_me
flutter test
# Con cobertura (requiere `flutter test --coverage` y lcov):
flutter test --coverage
```

## Meta de cobertura

- **Mínimo**: 50% del código en `lib/`
- **Ideal**: 75% en `lib/features/*/presentation/providers/`

---

## Resultados de Ejecución — 2026-07-03

> **Comando:** `flutter test`  
> **Entorno:** Windows 10, Flutter stable  
> **Tipo:** ✅ Ejecución real

### Resumen

```
00:02 +72: All tests passed!
Exit code: 0
Duración: ~17 s
```

### Suite por archivo

| Archivo | Tests | Resultado |
|---------|-------|-----------|
| `test/widget_test.dart` | 22 | ✅ 22/22 PASSED |
| `test/providers/auth_provider_test.dart` | 10 | ✅ 10/10 PASSED |
| `test/providers/transaction_provider_test.dart` | 10 | ✅ 10/10 PASSED |
| `test/providers/dashboard_provider_test.dart` | 8 | ✅ 8/8 PASSED |
| `test/providers/ocr_provider_test.dart` | 10 | ✅ 10/10 PASSED |
| `test/widgets/money_button_test.dart` | 4 | ✅ 4/4 PASSED |
| `test/widgets/money_card_test.dart` | 2 | ✅ 2/2 PASSED |
| `test/widgets/money_form_field_test.dart` | 6 | ✅ 6/6 PASSED |

### Casos documentados (plan vs. resultado)

| Módulo | Caso | Resultado |
|--------|------|-----------|
| AuthProvider | login exitoso | ✅ PASSED |
| AuthProvider | login fallido | ✅ PASSED |
| AuthProvider | logout | ✅ PASSED |
| AuthProvider | deleteAccount | ✅ PASSED |
| AuthProvider | register exitoso | ✅ PASSED |
| AuthProvider | register email duplicado | ⚠️ PARTIAL (mock, no API real) |
| TransactionProvider | load/create/update/delete | ✅ PASSED |
| TransactionProvider | setSearch, setSort, paginación | ✅ PASSED |
| TransactionProvider | loadTransactions con error | ❌ FAIL (test no implementado) |
| DashboardProvider | loadAll, budgets, refresh | ✅ PASSED |
| DashboardProvider | loadAll error parcial | ❌ FAIL (test no implementado) |
| DashboardProvider | clearCache | ⚠️ PARTIAL (cubierto indirectamente) |
| OcrProvider | scan/reset/error/bytes vacíos | ✅ PASSED |
| MoneyButton | label, loading, disabled | ✅ PASSED |
| MoneyButton | expanded ancho completo | ⚠️ PARTIAL (1 test implícito) |
| MoneyCard | child + border radius | ✅ PASSED |
| MoneyAlert | tipos info/success/warning/error | ❌ FAIL (sin tests) |
| UserFriendlyError | códigos 400–503 | ⚠️ PARTIAL (solo 401, 404, 500) |
| ApiClient mockeado | GET/POST/timeout/500 | ❌ FAIL (sin tests) |

**Cobertura estimada:** ~62% en `lib/` (sin `--coverage`; valor inferido).
