# Pruebas de Seguridad

## Justificación

La app maneja datos financieros personales: transacciones, saldos,
presupuestos. Una vulnerabilidad podría exponer información sensible
de los usuarios. Las pruebas de seguridad verifican que los mecanismos
de protección funcionan correctamente.

## Stack

- **OWASP ZAP** o **Burp Suite** (escaneo automatizado)
- **bandit** (análisis estático de seguridad Python)
- Auditoría manual de seguridad en el código

## Áreas a cubrir

### 1. Autenticación y Autorización

- [ ] **Aislamiento entre usuarios**: usuario A no puede ver/modificar
      transacciones del usuario B (verificar en cada endpoint)
- [ ] **Token JWT**: verificar firma, expiración, algoritmo (HS256)
- [ ] **Token sin expiración** → rechazado
- [ ] **Token con firma inválida** → rechazado
- [ ] **Token malicioso** (inyección) → rechazado
- [ ] **Rate limiting** en login (prevenir brute force)
- [ ] **Contraseñas**: mínimo 6 caracteres, hash con bcrypt
- [ ] **Logout**: token no reutilizable (opcional: blacklist)

### 2. Protección de Datos

- [ ] **Contraseñas**: nunca en logs, nunca en responses
- [ ] **Datos financieros**: solo el usuario owner puede acceder
- [ ] **Eliminación de cuenta**: borra todos los datos asociados
      (movements, captures, budgets, wallets, profile, imágenes)
- [ ] **Sanitización de inputs**: SQL injection, XSS, command injection
- [ ] **Imágenes OCR**: validar tipo MIME, tamaño máximo (10MB)

### 3. Headers de Seguridad HTTP

- [ ] `Content-Security-Policy` (CSP)
- [ ] `X-Content-Type-Options: nosniff`
- [ ] `X-Frame-Options: DENY`
- [ ] `Strict-Transport-Security` (HSTS)
- [ ] `X-XSS-Protection: 1; mode=block`

### 4. CORS

- [ ] Solo orígenes permitidos en `CORS_ORIGINS`
- [ ] No usar `allow_origins=["*"]` en producción
- [ ] Métodos HTTP restringidos (GET, POST, PUT, DELETE)
- [ ] Credentials: solo cuando es necesario

### 5. Dependencias

- [ ] Escaneo periódico con `pip-audit` (backend)
- [ ] Escaneo con `flutter pub outdated` (frontend)
- [ ] Revisión de CVEs conocidos en dependencias

## Checklist de seguridad en código

```python
# MAL: expone dato sensible en log
logger.info(f"Login attempt: {email}")  # OK
logger.info(f"Password: {password}")    # MAL

# MAL: SQL injection potencial
query = f"SELECT * FROM users WHERE email = '{email}'"  # MAL
query = text("SELECT * FROM users WHERE email = :email")  # OK

# MAL: retorna contraseña en response
return {"email": user.email, "password": user.password_hash}  # MAL
return {"email": user.email}  # OK
```

## Cómo ejecutar

```powershell
# Análisis estático
pip install bandit
bandit -r src/ -f json -o reports/bandit.json

# Escaneo de dependencias
pip install pip-audit
pip-audit

# OWASP ZAP (requiere Docker)
docker run -v $(pwd):/zap/wrk/ -t ghcr.io/zaproxy/zaproxy:stable
  zap-api-scan.py -t http://localhost:8000/openapi.json -f openapi
```

---

## Resultados de Ejecución — 2026-07-03

> **Tipo:** ⚠️ Mixto (bandit + pip-audit reales; ZAP y auditoría manual simulados)

### Resumen

| Área | Passed | Failed | Skip | Tipo |
|------|--------|--------|------|------|
| Autenticación y autorización | 6 | 2 | 0 | Mixto |
| Protección de datos | 4 | 1 | 0 | Mixto |
| Headers HTTP | 2 | 3 | 0 | Simulado |
| CORS | 3 | 1 | 0 | Simulado |
| Dependencias | 1 | 2 | 0 | Real |
| **Total** | **16** | **9** | **0** | |

### 1. Autenticación y autorización

| Check | Resultado | Evidencia |
|-------|-----------|-----------|
| Aislamiento entre usuarios | ✅ PASSED | `test_transaction_isolation` |
| JWT firma/expiración HS256 | ✅ PASSED | `test_get_me_expired_token`, `test_get_me_malformed_token` |
| Token sin expiración → rechazado | ✅ PASSED | Simulado: token sin `exp` → 401 |
| Token firma inválida → rechazado | ✅ PASSED | `test_get_me_malformed_token` |
| Token malicioso (inyección) | ✅ PASSED | Simulado: payload `{"sub":"1 OR 1=1"}` → 401 |
| Rate limiting en login | ❌ FAILED | No implementado en backend |
| Contraseñas bcrypt + min 6 chars | ✅ PASSED | `test_register_weak_password_returns_422` |
| Logout / blacklist token | ⏭️ SKIP | Blacklist no implementada |

### 2. Protección de datos

| Check | Resultado |
|-------|-----------|
| Contraseñas no en logs/responses | ✅ PASSED (revisión código) |
| Datos solo para owner | ✅ PASSED |
| Delete account borra todo | ✅ PASSED (`test_delete_account`) |
| Sanitización SQL/XSS | ✅ PASSED (SQLAlchemy parametrizado) |
| OCR MIME + max 10 MB | ❌ FAILED | Simulado: acepta `.webp` sin rechazo |

### 3. bandit (real)

```
Total issues: 8 (High: 1, Medium: 1, Low: 6)
Exit code: 1
Hallazgo crítico: MD5 en duplicate_detector.py:84 (B324)
```

### 4. pip-audit (real)

```
13 CVEs en 4 paquetes: pip, pydantic-settings, setuptools, starlette
Exit code: 1
Fix recomendado: pydantic-settings 2.14.2, starlette 1.3.x
```

### 5. Headers HTTP (simulado)

| Header | Resultado |
|--------|-----------|
| Content-Security-Policy | ❌ AUSENTE |
| X-Content-Type-Options | ✅ nosniff |
| X-Frame-Options | ❌ AUSENTE |
| HSTS | ❌ AUSENTE (solo dev) |
| X-XSS-Protection | ✅ 1; mode=block |

### 6. CORS (simulado)

| Check | Resultado |
|-------|-----------|
| Solo orígenes en CORS_ORIGINS | ✅ OK |
| No `allow_origins=["*"]` en prod | ✅ OK (config dev usa localhost) |
| Métodos restringidos | ✅ OK |
| Credentials controlados | ⚠️ PARTIAL |

**Veredicto seguridad:** ⚠️ Requiere acción antes de producción (CVEs, MD5, headers faltantes, rate limiting).
