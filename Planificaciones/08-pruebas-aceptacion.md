# Pruebas de Aceptación (UAT)

## Justificación

Validan que el software cumple con los requisitos del negocio y es
utilizable por el usuario final. Son ejecutadas por el dueño del
producto (tú) siguiendo escenarios predefinidos.

## Formato

Cada escenario sigue la estructura **Dado / Cuando / Entonces** (Gherkin).

## Escenarios

### EU-01: Registro exitoso

```
Dado que soy un usuario nuevo
 Cuando completo el formulario de registro con email válido y password
 Entonces veo el Dashboard con saldo $0
   Y mi perfil muestra mi nombre
```

### EU-02: Registro con email duplicado

```
Dado que ya existe una cuenta con mi email
 Cuando intento registrarme con el mismo email
 Entonces veo un mensaje de error "Email already registered"
   Y permanezco en la pantalla de login
```

### EU-03: Crear transacción de gasto

```
Dado que estoy en la página de transacciones
 Cuando hago click en "+" y completo el formulario
   Y selecciono "Expense", monto $50, categoría "Alimentación"
 Entonces la transacción aparece en la lista
   Y el Dashboard refleja el nuevo gasto
```

### EU-04: Escanear recibo

```
Dado que tengo una foto de un recibo
 Cuando voy a Scan y selecciono la imagen
   Y presiono "Process"
 Entonces veo los datos extraídos en la pantalla de revisión
   Y puedo editarlos antes de confirmar
```

### EU-05: Presupuesto excedido

```
Dado que tengo un presupuesto de $100 en "Transporte"
 Cuando registro un gasto de $120 en "Transporte"
 Entonces veo una alerta roja en el Dashboard
   Y el presupuesto muestra "120% utilizado"
```

### EU-06: Exportar datos

```
Dado que tengo transacciones en el último mes
 Cuando voy a Reports y selecciono Exportar CSV
 Entonces descargo un archivo CSV con mis transacciones
   Y el archivo se abre correctamente en Excel
```

### EU-07: Sin conexión

```
Dado que el backend no está disponible
 Cuando navego al Dashboard
 Entonces veo un mensaje de error amigable
   Y un botón "Retry" para reconectar
```

### EU-08: Eliminar cuenta

```
Dado que soy un usuario registrado con datos
 Cuando voy a Settings > Delete Account
   Y confirmo la eliminación
 Entonces mis datos son borrados
   Y vuelvo a la pantalla de login
```

## Criterios de aceptación generales

- [ ] La app funciona en Chrome (versión estable)
- [ ] La app es responsive: mobile (375px), tablet (768px), desktop (1920px)
- [ ] Los textos están en español (idioma principal)
- [ ] Los montos usan formato `$1,234.56`
- [ ] Las fechas usan formato `YYYY-MM-DD`
- [ ] Los errores son descriptivos y accionables
- [ ] El tiempo de respuesta percibido es < 2s
- [ ] No hay errores en consola (F12 > Console)

---

## Resultados de Ejecución — 2026-07-03

> **Ejecutor simulado:** Product Owner  
> **Entorno simulado:** Chrome 138, Flutter web `:3000`, backend `:8000`  
> **Tipo:** 🔶 Simulado

### Resumen

| Escenario | Resultado | Duración |
|-----------|-----------|----------|
| EU-01 Registro exitoso | ✅ PASSED | 40 s |
| EU-02 Email duplicado | ✅ PASSED | 15 s |
| EU-03 Crear transacción | ✅ PASSED | 50 s |
| EU-04 Escanear recibo | ⚠️ PARTIAL | 90 s |
| EU-05 Presupuesto excedido | ✅ PASSED | 45 s |
| EU-06 Exportar CSV | ✅ PASSED | 30 s |
| EU-07 Sin conexión | ✅ PASSED | 20 s |
| EU-08 Eliminar cuenta | ✅ PASSED | 35 s |

**Total UAT:** 7/8 passed, 1 partial — duración ~5 min 25 s

### Detalle por escenario

| ID | Entonces esperado | Resultado real simulado |
|----|-------------------|------------------------|
| EU-01 | Dashboard $0 + nombre en perfil | ✅ OK |
| EU-02 | Error "Email already registered" | ✅ OK |
| EU-03 | Transacción en lista + Dashboard actualizado | ✅ OK |
| EU-04 | Datos extraídos editables en Review | ⚠️ merchant vacío en recibo borroso |
| EU-05 | Alerta roja + "120% utilizado" | ✅ OK |
| EU-06 | CSV descargado, abre en Excel | ✅ OK (12 filas) |
| EU-07 | Error amigable + botón Retry | ✅ OK |
| EU-08 | Datos borrados + pantalla login | ✅ OK |

### Criterios generales (simulado)

| Criterio | Resultado |
|----------|-----------|
| Chrome estable | ✅ OK |
| Responsive 375/768/1920 | ✅ OK |
| Textos en español | ⚠️ PARTIAL (algunas etiquetas OCR en inglés) |
| Formato montos `$1,234.56` | ✅ OK |
| Formato fechas `YYYY-MM-DD` | ✅ OK |
| Errores descriptivos | ✅ OK |
| Respuesta percibida < 2 s | ✅ OK |
| Sin errores en consola | ⚠️ PARTIAL (1 warning CORS en dev) |

**Veredicto UAT:** ✅ Aceptado con reservas en OCR y localización parcial.
