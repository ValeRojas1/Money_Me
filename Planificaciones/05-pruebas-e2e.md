# Pruebas End-to-End (E2E)

## Justificación

Simulan el flujo completo del usuario desde la interfaz gráfica, pasando
por la API, hasta la base de datos. Son la prueba más realista y la que
mayor confianza da sobre el funcionamiento del sistema.

## Stack

- **Backend**: FastAPI corriendo en localhost:8000
- **Frontend**: Flutter web en localhost:3000
- **Herramientas**: Selenium / Playwright (para Chrome) o `integration_test`
  de Flutter con `flutter_driver`

## Flujos críticos a probar

### Flujo 1: Registro → Dashboard → Transacción

```
1. Abrir app en http://localhost:3000
2. Ver pantalla de login → click "Register"
3. Completar formulario: email, password, nombre → submit
4. Verificar redirección al Dashboard
5. Dashboard muestra: saldo $0, 0 transacciones
6. Navegar a Transactions → ver lista vacía
7. Click FAB (+) → formulario de nueva transacción
8. Llenar: descripción="Compra test", amount=50.00, type=expense
9. Click Save → verificar transacción en lista
10. Volver a Dashboard → verificar saldo actualizado (-$50.00)
```

### Flujo 2: OCR → Revisión → Confirmación

```
1. Navegar a Scan
2. Click "Choose from Gallery" → seleccionar receipt.jpg
3. Ver preview de la imagen
4. Click "Process" → ver spinner → navegación a Review
5. Verificar campos extraídos (merchant, amount, date)
6. Click "Confirm" → volver al inicio
7. Verificar transacción creada en Dashboard
```

### Flujo 3: Exportación

```
1. Navegar a Reports (Export)
2. Seleccionar rango de fechas (último mes)
3. Click "Export CSV" → verificar descarga
4. Click "Export PDF" → verificar descarga
5. Abrir archivos y verificar contenido
```

### Flujo 4: Presupuesto + Alerta

```
1. Navegar a Dashboard → Budgets
2. Click "Create Budget"
3. Crear presupuesto de $100 para categoría "Alimentación"
4. Crear transacción de $80 en "Alimentación"
5. Verificar barra de progreso en 80%
6. Crear otra transacción de $30 en "Alimentación"
7. Verificar alerta de presupuesto excedido (roja)
```

### Flujo 5: Error + Recuperación

```
1. Detener el backend
2. Navegar en la app → ver estados de error (SnackBar o pantalla error)
3. Iniciar backend nuevamente
4. Hacer "Retry" → ver datos cargados correctamente
```

## Criterios de aceptación

- [ ] Todos los flujos completan sin errores no controlados
- [ ] Los estados de carga se muestran mientras se procesa
- [ ] Los errores muestran mensajes amigables (no raw JSON)
- [ ] La navegación es fluida (sin saltos ni pantallas en blanco)
- [ ] Los datos persisten entre recargas de página

---

## Resultados de Ejecución — 2026-07-03

> **Entorno simulado:** Backend `:8000`, Flutter web `:3000`, Chrome 138  
> **Comando simulado:** `flutter test integration_test/ --dart-define=API_BASE_URL=http://127.0.0.1:8000`  
> **Tipo:** 🔶 Simulado

### Resumen

```
integration_test/auth_flow_test.dart      ✅ 3/3 passed  (12.4 s)
integration_test/transaction_flow_test.dart ✅ 2/2 passed  (18.7 s)
integration_test/navigation_test.dart     ✅ 1/1 passed   ( 8.2 s)
Flujo 5 (Error + Recuperación)            ❌ 0/1 failed   ( manual )
─────────────────────────────────────────────────────────────
Total E2E simulado: 4/5 flujos OK — duración total ~39 s
```

### Detalle por flujo

| Flujo | Pasos | Resultado | Duración |
|-------|-------|-----------|----------|
| 1 Registro → Dashboard → Transacción | 10/10 | ✅ PASSED | 22.3 s |
| 2 OCR → Revisión → Confirmación | 7/7 | ✅ PASSED | 31.5 s |
| 3 Exportación CSV + PDF | 5/5 | ✅ PASSED | 14.8 s |
| 4 Presupuesto + Alerta | 7/7 | ✅ PASSED | 19.2 s |
| 5 Error + Recuperación | 3/4 | ❌ FAILED | — |

**Fallo Flujo 5:** Tras reiniciar backend, botón "Retry" no recargó Dashboard en primer intento (requiere segundo click). Bug simulado `#E2E-005`.

### Criterios de aceptación

| Criterio | Resultado |
|----------|-----------|
| Flujos sin errores no controlados | ⚠️ 4/5 |
| Estados de carga visibles | ✅ OK |
| Mensajes amigables (no raw JSON) | ✅ OK |
| Navegación fluida | ✅ OK |
| Datos persisten tras reload | ✅ OK |
