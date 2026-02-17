# Plan de Implementación: Servicio de Autenticación y Gestión de Tokens JWT

**Versión:** 1.0.0  
**Sprint:** 1 (v0.3.0)  
**Tarea:** 5 - Implementar servicio de autenticación y gestión de tokens JWT  
**Duración Estimada:** 3-4 días  
**Estado:** 📋 Listo para Implementación

---

## Resumen Ejecutivo

Este plan de implementación detalla los pasos necesarios para crear un servicio de autenticación robusto y seguro que gestione:

- Login/logout de usuarios
- Almacenamiento seguro de tokens JWT
- Renovación automática de tokens
- Inyección de tokens en requests HTTP
- Detección de actividad sospechosa
- Sincronización de estado en toda la aplicación

El servicio se integra con el HttpClientService completado en Task 4 y proporciona una interfaz simple para toda la aplicación.

---

## Tareas de Implementación

### 1. Crear Modelos de Datos Base

- [ ] 1.1 Crear modelo `User` con serialización JSON
  - Campos: id, email, firstName, lastName, roles, createdAt, lastLoginAt
  - Implementar `fromJson()` y `toJson()`
  - Añadir validaciones básicas
  - _Requisitos: REQ-AUTH-001, REQ-AUTH-007_

- [ ] 1.2 Crear clase `AuthState` con sealed class pattern
  - Estados: AuthInitial, AuthLoading, AuthAuthenticated, AuthUnauthenticated, AuthError, AuthLocked
  - Implementar equality y toString()
  - _Requisitos: REQ-AUTH-013_

- [ ] 1.3 Crear modelos de respuesta del backend
  - `LoginResponse`: access_token, refresh_token, expires_in, user
  - `RefreshResponse`: access_token, expires_in
  - Implementar serialización JSON
  - _Requisitos: REQ-AUTH-001, REQ-AUTH-006_

### 2. Implementar AuthService Core

- [ ] 2.1 Crear clase `AuthService` con métodos base
  - Constructor con inyección de dependencias
  - Inicialización de Secure Storage
  - Inicialización de StreamController para estado
  - _Requisitos: Base para todos los métodos_

- [ ] 2.2 Implementar método `login(email, password)`
  - Validación local de credenciales
  - Verificación de bloqueo de cuenta
  - POST a `/auth/login`
  - Almacenamiento de tokens
  - Programación de renovación automática
  - Notificación de cambio de estado
  - _Requisitos: REQ-AUTH-001, REQ-AUTH-003, REQ-AUTH-004, REQ-AUTH-011_

- [ ] 2.3 Implementar método `logout()`
  - Cancelación de timer de renovación
  - Eliminación de tokens de Secure Storage
  - Limpieza de estado en memoria
  - Notificación de cambio de estado
  - _Requisitos: REQ-AUTH-002, REQ-AUTH-013_

- [ ] 2.4 Implementar método `refreshToken()`
  - Obtención de refresh_token de Secure Storage
  - POST a `/auth/refresh`
  - Actualización de access_token
  - Reprogramación de renovación automática
  - Manejo de errores (si refresh_token expiró)
  - _Requisitos: REQ-AUTH-006, REQ-AUTH-007_

- [ ] 2.5 Implementar métodos de utilidad
  - `getAccessToken()`: Obtener token actual
  - `getRefreshToken()`: Obtener refresh token
  - `isAuthenticated()`: Verificar si hay sesión activa
  - `getCurrentUser()`: Obtener información del usuario
  - _Requisitos: REQ-AUTH-004, REQ-AUTH-005_

### 3. Implementar Almacenamiento Seguro

- [ ] 3.1 Configurar flutter_secure_storage
  - Crear instancia de FlutterSecureStorage
  - Configurar opciones de seguridad (iOS: Keychain, Android: Keystore)
  - _Requisitos: REQ-AUTH-SEC-001_

- [ ] 3.2 Implementar métodos de almacenamiento
  - `_storeTokens()`: Guardar access_token, refresh_token, expires_in
  - `_retrieveAccessToken()`: Obtener access_token
  - `_retrieveRefreshToken()`: Obtener refresh_token
  - `_retrieveUserInfo()`: Obtener información de usuario
  - `_clearAllTokens()`: Eliminar todos los tokens
  - _Requisitos: REQ-AUTH-004, REQ-AUTH-005_

- [ ] 3.3 Implementar validación de tokens almacenados
  - Verificar que tokens no estén expirados
  - Decodificar JWT y extraer información
  - Validar que contengan campos requeridos
  - _Requisitos: REQ-AUTH-007_

### 4. Implementar Renovación Automática

- [ ] 4.1 Crear lógica de programación de renovación
  - Calcular tiempo de renovación (expires_in - 5 minutos)
  - Crear Timer para disparar renovación
  - _Requisitos: REQ-AUTH-006, REQ-AUTH-PERF-002_

- [ ] 4.2 Implementar método `_scheduleTokenRefresh()`
  - Cancelar timer anterior si existe
  - Calcular delay hasta renovación
  - Crear nuevo timer
  - Manejar errores de renovación
  - _Requisitos: REQ-AUTH-006_

- [ ] 4.3 Implementar reintentos de renovación
  - Reintentar hasta 3 veces con backoff exponencial
  - Si falla definitivamente: Redirigir a login
  - Loguear intentos de renovación
  - _Requisitos: REQ-AUTH-REL-002_

### 5. Implementar Detección de Anomalías

- [ ] 5.1 Crear sistema de conteo de intentos fallidos
  - Almacenar contador en memoria
  - Incrementar en cada login fallido
  - Resetear en login exitoso
  - _Requisitos: REQ-AUTH-011_

- [ ] 5.2 Implementar bloqueo de cuenta
  - Bloquear después de 5 intentos fallidos
  - Bloqueo por 15 minutos
  - Desbloqueo automático después de timeout
  - Loguear evento de bloqueo
  - _Requisitos: REQ-AUTH-011, REQ-AUTH-012_

- [ ] 5.3 Implementar notificación de actividad sospechosa
  - Detectar múltiples logins desde ubicaciones diferentes
  - Notificar al usuario
  - Permitir revocación de sesiones
  - _Requisitos: REQ-AUTH-012_

### 6. Implementar Restauración de Sesión

- [ ] 6.1 Crear método `restoreSession()`
  - Recuperar tokens de Secure Storage
  - Validar que no estén expirados
  - Si expirados: Intentar renovación
  - Restaurar información de usuario
  - Programar renovación automática
  - _Requisitos: REQ-AUTH-005, REQ-AUTH-014_

- [ ] 6.2 Integrar restauración en inicialización de app
  - Llamar a `restoreSession()` en main()
  - Mostrar splash screen mientras se restaura
  - Redirigir a home si sesión válida
  - Redirigir a login si no hay sesión
  - _Requisitos: REQ-AUTH-005, REQ-AUTH-014_

### 7. Mejorar AuthInterceptor

- [ ] 7.1 Actualizar `onRequest()` para inyectar tokens
  - Obtener access_token de AuthService
  - Añadir header `Authorization: Bearer {token}`
  - Loguear request con información de autenticación
  - _Requisitos: REQ-AUTH-008_

- [ ] 7.2 Implementar manejo de 401 en `onError()`
  - Detectar respuesta 401
  - Intentar renovar token automáticamente
  - Reintentar request original con nuevo token
  - Si renovación falla: Redirigir a login
  - _Requisitos: REQ-AUTH-009_

- [ ] 7.3 Implementar manejo de 403 en `onError()`
  - Detectar respuesta 403
  - Mostrar error de acceso denegado
  - NO intentar renovar token
  - _Requisitos: REQ-AUTH-010_

### 8. Implementar Logging Seguro

- [ ] 8.1 Crear logging para eventos de autenticación
  - Login exitoso: email, roles (sin contraseña)
  - Login fallido: email, número de intento
  - Token renovado: expires_in (sin token completo)
  - Cuenta bloqueada: email, tiempo de desbloqueo
  - _Requisitos: REQ-AUTH-SEC-004, REQ-FLT-027_

- [ ] 8.2 Implementar enmascaramiento de tokens en logs
  - Mostrar solo últimos 4 caracteres de tokens
  - Nunca loguear tokens completos
  - Nunca loguear contraseñas
  - _Requisitos: REQ-AUTH-SEC-004_

### 9. Crear Riverpod Providers

- [ ] 9.1 Crear provider para AuthService
  - `authServiceProvider`: Instancia singleton de AuthService
  - Inyectar dependencias (HttpClientService, LoggingService, etc.)
  - _Requisitos: Base para toda la app_

- [ ] 9.2 Crear provider para estado de autenticación
  - `authStateProvider`: StreamProvider que emite AuthState
  - Escuchar cambios en AuthService
  - _Requisitos: REQ-AUTH-013_

- [ ] 9.3 Crear provider para usuario actual
  - `currentUserProvider`: FutureProvider que retorna User?
  - Obtener información del usuario autenticado
  - _Requisitos: REQ-AUTH-005_

- [ ] 9.4 Crear provider para verificación de autenticación
  - `isAuthenticatedProvider`: Provider que retorna bool
  - Verificar si hay sesión activa
  - _Requisitos: REQ-AUTH-005_

### 10. Implementar Tests Unitarios

- [ ] 10.1 Tests para AuthService.login()
  - Login exitoso con credenciales válidas
  - Login fallido con credenciales inválidas
  - Login fallido por error de red
  - Bloqueo después de 5 intentos fallidos
  - _Requisitos: REQ-AUTH-001, REQ-AUTH-011_

- [ ] 10.2 Tests para AuthService.logout()
  - Logout limpia todos los tokens
  - Logout cancela timer de renovación
  - Logout notifica cambio de estado
  - _Requisitos: REQ-AUTH-002_

- [ ] 10.3 Tests para AuthService.refreshToken()
  - Renovación exitosa actualiza tokens
  - Renovación fallida redirige a login
  - Renovación reprograma timer
  - _Requisitos: REQ-AUTH-006_

- [ ] 10.4 Tests para almacenamiento seguro
  - Tokens se almacenan en Secure Storage
  - Tokens se recuperan correctamente
  - Tokens se eliminan al logout
  - _Requisitos: REQ-AUTH-004_

- [ ] 10.5 Tests para validación de credenciales
  - Email válido/inválido
  - Contraseña válida/inválida
  - Mensajes de error específicos
  - _Requisitos: REQ-AUTH-003_

- [ ] 10.6 Tests para AuthState
  - Transiciones de estado correctas
  - Igualdad de estados
  - Serialización de estados
  - _Requisitos: REQ-AUTH-013_

- [ ] 10.7 Tests para User model
  - Serialización JSON
  - Deserialización JSON
  - Validaciones
  - _Requisitos: REQ-AUTH-001_

### 11. Implementar Tests de Integración

- [ ] 11.1 Test: Flujo completo de login
  - Usuario ingresa credenciales
  - Sistema valida y envía al backend
  - Backend retorna tokens
  - Tokens se almacenan
  - Usuario redirigido a home
  - _Requisitos: REQ-AUTH-001, REQ-AUTH-004_

- [ ] 11.2 Test: Renovación automática de token
  - Usuario autenticado
  - Token próximo a expirar
  - Sistema renueva automáticamente
  - Usuario continúa sin interrupciones
  - _Requisitos: REQ-AUTH-006_

- [ ] 11.3 Test: Logout
  - Usuario autenticado
  - Usuario toca logout
  - Tokens eliminados
  - Usuario redirigido a login
  - _Requisitos: REQ-AUTH-002_

- [ ] 11.4 Test: Restauración de sesión
  - Usuario autenticado
  - App se cierra y reabre
  - Sesión se restaura automáticamente
  - Usuario ve home sin pasar por login
  - _Requisitos: REQ-AUTH-005, REQ-AUTH-014_

- [ ] 11.5 Test: Manejo de 401
  - Request retorna 401
  - Sistema renueva token automáticamente
  - Request se reintenta
  - Éxito sin intervención del usuario
  - _Requisitos: REQ-AUTH-009_

### 12. Implementar Tests de Propiedades

- [ ] 12.1 Property test: Login Success Invariant
  - **Property 1: Login Success Invariant**
  - **Validates: REQ-AUTH-001, REQ-AUTH-004**
  - Generar email/password válidos
  - Verificar que tokens se almacenen
  - Verificar que AuthState sea AuthAuthenticated

- [ ] 12.2 Property test: Token Expiration Invariant
  - **Property 2: Token Expiration Invariant**
  - **Validates: REQ-AUTH-006, REQ-AUTH-007**
  - Generar token con expiración
  - Verificar detección de expiración
  - Verificar intento de renovación

- [ ] 12.3 Property test: Logout Cleanup Invariant
  - **Property 3: Logout Cleanup Invariant**
  - **Validates: REQ-AUTH-002, REQ-AUTH-013**
  - Generar sesión autenticada
  - Realizar logout
  - Verificar limpieza de tokens

- [ ] 12.4 Property test: Session Restoration Round-Trip
  - **Property 4: Session Restoration Round-Trip**
  - **Validates: REQ-AUTH-005, REQ-AUTH-014**
  - Generar sesión válida
  - Almacenar tokens
  - Restaurar sesión
  - Verificar mismo usuario recuperado

- [ ] 12.5 Property test: Failed Login Attempt Tracking
  - **Property 5: Failed Login Attempt Tracking**
  - **Validates: REQ-AUTH-011**
  - Generar 5 intentos fallidos
  - Verificar bloqueo de cuenta
  - Verificar duración de bloqueo

- [ ] 12.6 Property test: Token Injection Consistency
  - **Property 6: Token Injection Consistency**
  - **Validates: REQ-AUTH-008, REQ-AUTH-009**
  - Generar sesión autenticada
  - Hacer múltiples requests
  - Verificar Authorization header en todos

- [ ] 12.7 Property test: 401 Automatic Recovery
  - **Property 7: 401 Automatic Recovery**
  - **Validates: REQ-AUTH-009**
  - Generar request que retorna 401
  - Verificar renovación automática
  - Verificar reintento de request

- [ ] 12.8 Property test: Secure Storage Encryption
  - **Property 8: Secure Storage Encryption**
  - **Validates: REQ-AUTH-SEC-001**
  - Generar token aleatorio
  - Almacenar en Secure Storage
  - Verificar encriptación

### 13. Validación y Documentación

- [ ] 13.1 Ejecutar análisis estático
  - `flutter analyze` sin errores
  - `dart format` aplicado
  - Documentación completa (dartdoc)
  - _Requisitos: Calidad de código_

- [ ] 13.2 Validar cobertura de tests
  - Cobertura mínima 90% en AuthService
  - Cobertura mínima 85% en modelos
  - Todos los métodos públicos testeados
  - _Requisitos: Calidad de tests_

- [ ] 13.3 Crear documentación
  - README con ejemplos de uso
  - Documentación de API (dartdoc)
  - Guía de integración para otros servicios
  - _Requisitos: Mantenibilidad_

- [ ] 13.4 Validar requisitos
  - Todos los requisitos implementados
  - Todos los criterios de aceptación cumplidos
  - Validación de seguridad completada
  - _Requisitos: Cumplimiento_

---

## Dependencias

**Dependencias de Código:**
- flutter_secure_storage: ^9.0.0
- jwt_decoder: ^2.0.1
- http: ^1.2.0 (ya incluido)
- flutter_riverpod: ^2.5.1 (ya incluido)

**Dependencias de Servicios:**
- HttpClientService (Task 4 - ✅ Completado)
- LoggingService (Task 4 - ✅ Completado)
- EnvironmentManager (Task 2 - ✅ Completado)
- Backend API Gateway con `/auth/login` y `/auth/refresh`

**Dependencias de Infraestructura:**
- Secure Storage nativo (Keychain iOS, Keystore Android)
- HTTPS/TLS 1.3

---

## Criterios de Aceptación

- [ ] AuthService implementado con todos los métodos
- [ ] Tokens almacenados en Secure Storage
- [ ] Renovación automática funciona sin interrupciones
- [ ] Manejo de 401 y 403 implementado
- [ ] Bloqueo por intentos fallidos funciona
- [ ] Logs no contienen credenciales o tokens
- [ ] Todos los tests pasan (unit, integration, property)
- [ ] Cobertura de tests ≥ 90%
- [ ] Análisis estático sin errores
- [ ] Documentación completa

---

## Estimación de Tiempo

| Tarea | Estimación | Notas |
|-------|-----------|-------|
| 1. Modelos de datos | 2-3 horas | Relativamente simple |
| 2. AuthService core | 6-8 horas | Lógica principal |
| 3. Almacenamiento seguro | 2-3 horas | Integración con flutter_secure_storage |
| 4. Renovación automática | 2-3 horas | Manejo de timers |
| 5. Detección de anomalías | 2-3 horas | Bloqueo de cuenta |
| 6. Restauración de sesión | 2-3 horas | Integración con app startup |
| 7. AuthInterceptor mejorado | 2-3 horas | Integración con HttpClientService |
| 8. Logging seguro | 1-2 horas | Enmascaramiento de datos sensibles |
| 9. Riverpod providers | 2-3 horas | Inyección de dependencias |
| 10. Tests unitarios | 4-6 horas | Cobertura completa |
| 11. Tests de integración | 3-4 horas | Flujos completos |
| 12. Tests de propiedades | 4-6 horas | Property-based testing |
| 13. Validación y docs | 2-3 horas | Documentación final |
| **Total** | **36-50 horas** | **3-4 días de trabajo** |

---

## Notas de Implementación

1. **Orden de Implementación:** Seguir el orden de tareas para evitar dependencias circulares
2. **Testing Temprano:** Escribir tests mientras se implementa, no después
3. **Seguridad Primero:** Validar que no haya credenciales en logs o código
4. **Integración Gradual:** Integrar con HttpClientService y AuthInterceptor paso a paso
5. **Documentación Continua:** Documentar mientras se implementa

---

**Última actualización:** 17 de febrero de 2026  
**Versión:** 1.0.0  
**Estado:** 📋 Listo para Implementación
