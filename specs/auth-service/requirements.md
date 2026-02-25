# Especificación de Requisitos: Servicio de Autenticación y Gestión de Tokens JWT

**Versión:** 1.0.0
**Sprint:** 1 (v0.3.0)
**Tarea:** 5 - Implementar servicio de autenticación y gestión de tokens JWT
**Requisitos Asociados:** REQ-SEC-001, REQ-SEC-002, REQ-SEC-003, REQ-COM-002, REQ-FLT-027
**Estado:** 📋 Especificación en Revisión

---

## 1. Introducción

### 1.1. Propósito

Este documento especifica los requisitos funcionales y no funcionales para el **Servicio de Autenticación y Gestión de Tokens JWT** de AltruPets. El servicio es responsable de:

- Autenticación segura de usuarios mediante credenciales
- Generación y validación de JWT (JSON Web Tokens)
- Gestión de refresh tokens para renovación automática
- Almacenamiento seguro de credenciales
- Detección de actividad sospechosa
- Integración con el cliente HTTP para inyección automática de tokens

**Audiencia:**
- Desarrolladores Flutter del equipo de AltruPets
- Arquitectos de seguridad
- Equipos de QA y testing
- Auditores de cumplimiento

### 1.2. Ámbito del Servicio

**Funcionalidades incluidas:**
- Servicio de autenticación (AuthService) con login/logout
- Almacenamiento seguro de tokens en dispositivo móvil
- Renovación automática de tokens antes de expiración
- Interceptor mejorado para inyección de tokens en requests HTTP
- Manejo de errores de autenticación (401, 403)
- Detección de actividad sospechosa
- Sincronización de estado de autenticación en toda la aplicación

**Funcionalidades excluidas:**
- Implementación del backend de autenticación (asumido existente)
- Integración con OAuth 2.0/OpenID Connect (futura)
- Autenticación biométrica (futura)
- Autenticación de dos factores (futura)

### 1.3. Definiciones y Acrónimos

- **JWT:** JSON Web Token - Token autofirmado con información de usuario y expiración
- **Access Token:** Token de corta duración (24h) para acceso a APIs
- **Refresh Token:** Token de larga duración para renovar access tokens sin re-autenticación
- **Token Expiration:** Tiempo en el que un token deja de ser válido
- **Token Refresh:** Proceso de obtener un nuevo access token usando refresh token
- **Secure Storage:** Almacenamiento encriptado en el dispositivo (Keychain/Keystore)
- **PII:** Personally Identifiable Information - Información personal identificable
- **RBAC:** Role-Based Access Control - Control de acceso basado en roles

### 1.4. Referencias

- Requisito REQ-SEC-001: Autenticación JWT + refresh tokens (24h)
- Requisito REQ-SEC-002: Hash de credenciales con bcrypt (≥12 rounds)
- Requisito REQ-SEC-003: Bloqueo por actividad sospechosa
- Requisito REQ-COM-002: REST vía API Gateway con JWT
- Requisito REQ-FLT-027: No hardcodear claves
- RFC 7519: JSON Web Token (JWT) Specification
- OWASP Mobile Security Testing Guide

---

## 2. Descripción General

### 2.1. Perspectiva del Servicio

El **AuthService** es un componente central que se integra con:

**Componentes internos:**
- HttpClientService: Para realizar requests de login/logout
- LoggingService: Para logging estructurado de eventos de autenticación
- EnvironmentManager: Para obtener URLs de endpoints de autenticación
- Riverpod providers: Para inyección de dependencias

**Servicios externos:**
- Backend API Gateway: Endpoint `/auth/login` y `/auth/refresh`
- Secure Storage: Almacenamiento de tokens en Keychain (iOS) / Keystore (Android)

**Flujo de integración:**
```
Usuario → AuthService.login()
  → HttpClientService.post('/auth/login')
  → Backend valida credenciales
  → Retorna access_token + refresh_token
  → AuthService almacena en Secure Storage
  → AuthInterceptor inyecta token en requests
  → Cuando expira → AuthService.refreshToken()
  → Obtiene nuevo access_token
  → Continúa operación sin interrupciones
```

### 2.2. Funciones Principales

1. **Autenticación de Usuario**
   - Validación de credenciales contra backend
   - Generación de JWT por backend
   - Almacenamiento seguro de tokens

2. **Gestión de Tokens**
   - Almacenamiento seguro en Keychain/Keystore
   - Renovación automática antes de expiración
   - Revocación al logout

3. **Inyección de Tokens**
   - Interceptor que añade token a todos los requests
   - Manejo automático de renovación en caso de 401

4. **Detección de Anomalías**
   - Bloqueo por múltiples intentos fallidos
   - Notificación de actividad sospechosa

5. **Sincronización de Estado**
   - Notificación a toda la app cuando cambia estado de autenticación
   - Redirección automática a login si token expira

### 2.3. Características de Usuarios

**Desarrolladores:**
- Experiencia: Intermedia a avanzada en Flutter
- Necesidad: Servicio de autenticación robusto y fácil de usar
- Expectativa: API simple, manejo automático de tokens

**Usuarios Finales:**
- Experiencia: Diversa (básica a avanzada)
- Necesidad: Login seguro y sin interrupciones
- Expectativa: Experiencia fluida sin re-autenticación frecuente

### 2.4. Restricciones

**Restricciones de Seguridad:**
- Tokens NUNCA deben hardcodearse en el código
- Credenciales NUNCA deben almacenarse en plain text
- Tokens deben almacenarse en Secure Storage (Keychain/Keystore)
- Comunicación SIEMPRE debe ser HTTPS/TLS 1.3

**Restricciones Técnicas:**
- Access tokens expiran en 24 horas (REQ-SEC-001)
- Refresh tokens deben tener expiración más larga (típicamente 30 días)
- Máximo 5 intentos fallidos de login antes de bloqueo temporal
- Bloqueo temporal: 15 minutos

**Restricciones de Integración:**
- Backend debe proporcionar endpoints `/auth/login` y `/auth/refresh`
- Respuesta debe incluir `access_token`, `refresh_token`, `expires_in`
- Backend debe validar credenciales con bcrypt (≥12 rounds)

### 2.5. Suposiciones y Dependencias

**Suposiciones:**
- Backend de autenticación está disponible y funcional
- Dispositivo tiene acceso a Secure Storage (Keychain/Keystore)
- Usuario tiene conectividad a internet para autenticación
- Reloj del dispositivo está sincronizado (para validación de JWT)

**Dependencias:**
- flutter_secure_storage: Para almacenamiento seguro de tokens
- jwt_decoder: Para decodificación y validación de JWT
- HttpClientService: Para comunicación con backend
- Riverpod: Para inyección de dependencias

---

## 3. Requisitos Específicos

### 3.1. Requisitos Funcionales

#### 3.1.1. Autenticación de Usuario

**REQ-AUTH-001: Login con credenciales**

CUANDO un usuario ingrese email y contraseña ENTONCES el sistema DEBERÁ:
- Validar que email tenga formato válido
- Validar que contraseña no esté vacía
- Enviar credenciales al backend mediante POST `/auth/login`
- Recibir `access_token`, `refresh_token` y `expires_in`
- Almacenar tokens en Secure Storage
- Retornar usuario autenticado con información de perfil
- Notificar a toda la aplicación que el usuario está autenticado

**REQ-AUTH-002: Logout**

CUANDO un usuario solicite logout ENTONCES el sistema DEBERÁ:
- Eliminar access_token de Secure Storage
- Eliminar refresh_token de Secure Storage
- Cancelar cualquier renovación de token pendiente
- Notificar a toda la aplicación que el usuario está desautenticado
- Redirigir a pantalla de login

**REQ-AUTH-003: Validación de credenciales en cliente**

CUANDO un usuario intente login ENTONCES el sistema DEBERÁ validar:
- Email: Formato válido (RFC 5322 simplificado)
- Contraseña: Mínimo 8 caracteres
- Mostrar errores específicos al usuario

#### 3.1.2. Gestión de Tokens

**REQ-AUTH-004: Almacenamiento seguro de tokens**

CUANDO se reciban tokens del backend ENTONCES el sistema DEBERÁ:
- Almacenar `access_token` en Secure Storage con clave `auth_access_token`
- Almacenar `refresh_token` en Secure Storage con clave `auth_refresh_token`
- Almacenar `expires_in` (timestamp de expiración) con clave `auth_token_expiry`
- Almacenar información de usuario (email, roles) con clave `auth_user_info`
- Usar encriptación nativa del dispositivo (Keychain en iOS, Keystore en Android)

**REQ-AUTH-005: Recuperación de tokens al iniciar app**

CUANDO la aplicación inicie ENTONCES el sistema DEBERÁ:
- Intentar recuperar tokens de Secure Storage
- Si existen tokens válidos: Restaurar sesión automáticamente
- Si tokens expirados: Intentar renovación automática
- Si no hay tokens: Mostrar pantalla de login
- Notificar a la app el estado de autenticación

**REQ-AUTH-006: Renovación automática de tokens**

CUANDO un access_token esté próximo a expirar (< 5 minutos) ENTONCES el sistema DEBERÁ:
- Usar refresh_token para obtener nuevo access_token
- Enviar POST `/auth/refresh` con refresh_token
- Recibir nuevo access_token y expires_in
- Actualizar tokens en Secure Storage
- Continuar operación sin interrupciones
- Si refresh_token también expiró: Redirigir a login

**REQ-AUTH-007: Validación de JWT en cliente**

CUANDO se recupere un token ENTONCES el sistema DEBERÁ:
- Decodificar JWT sin validar firma (confianza en backend)
- Extraer información de usuario (email, roles, exp)
- Validar que no esté expirado localmente
- Validar que contenga campos requeridos (email, roles, exp)

#### 3.1.3. Inyección de Tokens en Requests

**REQ-AUTH-008: Interceptor mejorado para inyección de tokens**

CUANDO se realice un request HTTP ENTONCES el sistema DEBERÁ:
- Recuperar access_token de Secure Storage
- Añadir header `Authorization: Bearer {access_token}`
- Si no hay token: Permitir request sin autenticación (para endpoints públicos)
- Loguear el request con información de autenticación

**REQ-AUTH-009: Manejo de 401 Unauthorized**

CUANDO un request retorne 401 ENTONCES el sistema DEBERÁ:
- Intentar renovar el token automáticamente
- Reintentar el request original con nuevo token
- Si renovación falla: Redirigir a login
- Notificar al usuario sobre la re-autenticación

**REQ-AUTH-010: Manejo de 403 Forbidden**

CUANDO un request retorne 403 ENTONCES el sistema DEBERÁ:
- Mostrar mensaje de error "Acceso denegado"
- NO intentar renovar token (error de autorización, no autenticación)
- Permitir que usuario intente otra acción

#### 3.1.4. Detección de Anomalías

**REQ-AUTH-011: Bloqueo por intentos fallidos**

CUANDO un usuario falle login 5 veces consecutivas ENTONCES el sistema DEBERÁ:
- Bloquear temporalmente la cuenta por 15 minutos
- Mostrar mensaje: "Cuenta bloqueada temporalmente. Intente en 15 minutos"
- Registrar el evento para auditoría
- Notificar al backend sobre el bloqueo

**REQ-AUTH-012: Detección de actividad sospechosa**

CUANDO se detecte actividad sospechosa ENTONCES el sistema DEBERÁ:
- Registrar el evento (múltiples logins desde ubicaciones diferentes, etc.)
- Notificar al usuario mediante email/push
- Permitir que usuario revoque sesiones activas
- Requerir re-autenticación si es necesario

#### 3.1.5. Sincronización de Estado

**REQ-AUTH-013: Notificación de cambios de autenticación**

CUANDO cambie el estado de autenticación ENTONCES el sistema DEBERÁ:
- Notificar a todos los listeners (Riverpod providers)
- Actualizar UI automáticamente
- Redirigir a pantalla apropiada (login o home)
- Cancelar requests pendientes si es logout

**REQ-AUTH-014: Persistencia de sesión**

CUANDO el usuario cierre y reabra la app ENTONCES el sistema DEBERÁ:
- Restaurar sesión automáticamente si tokens son válidos
- Mostrar pantalla de home sin pasar por login
- Si tokens expirados: Renovar automáticamente
- Si no hay tokens: Mostrar pantalla de login

### 3.2. Requisitos No Funcionales

#### 3.2.1. Seguridad

**REQ-AUTH-SEC-001: Encriptación de tokens en almacenamiento**

CUANDO se almacenen tokens ENTONCES DEBERÁN:
- Usar Keychain (iOS) o Keystore (Android) nativo
- Estar encriptados con clave del dispositivo
- No ser accesibles a otras aplicaciones
- Ser eliminados si el dispositivo se resetea

**REQ-AUTH-SEC-002: Comunicación HTTPS**

CUANDO se comunique con backend ENTONCES DEBERÁ:
- Usar HTTPS con TLS 1.3 mínimo
- Validar certificados del servidor
- Implementar certificate pinning (futuro)
- Rechazar conexiones inseguras

**REQ-AUTH-SEC-003: No hardcodear credenciales**

CUANDO se configure el servicio ENTONCES DEBERÁ:
- Obtener URLs de endpoints desde EnvironmentManager
- No hardcodear claves de API o secretos
- Usar variables de entorno para configuración sensible
- Validar que no haya credenciales en logs

**REQ-AUTH-SEC-004: Logs seguros**

CUANDO se registren eventos de autenticación ENTONCES DEBERÁ:
- NUNCA loguear contraseñas o tokens completos
- Loguear solo últimos 4 caracteres de tokens (para debugging)
- Loguear email del usuario (sin PII sensible)
- Loguear eventos de seguridad (login, logout, bloqueos)

#### 3.2.2. Rendimiento

**REQ-AUTH-PERF-001: Tiempo de login**

CUANDO un usuario haga login ENTONCES:
- Validación de credenciales: < 100ms
- Request al backend: < 2 segundos
- Almacenamiento de tokens: < 50ms
- Tiempo total: < 2.5 segundos

**REQ-AUTH-PERF-002: Renovación de tokens**

CUANDO se renueve un token ENTONCES:
- Debe completarse en < 1 segundo
- No debe bloquear requests en progreso
- Debe ser transparente para el usuario

**REQ-AUTH-PERF-003: Recuperación de sesión**

CUANDO la app inicie ENTONCES:
- Recuperación de tokens: < 100ms
- Validación de tokens: < 50ms
- Restauración de sesión: < 200ms total

#### 3.2.3. Confiabilidad

**REQ-AUTH-REL-001: Manejo de errores de red**

CUANDO falle la conexión durante login ENTONCES:
- Mostrar error específico: "Sin conexión a internet"
- Permitir reintentar
- No perder datos ingresados

**REQ-AUTH-REL-002: Recuperación ante fallos**

CUANDO falle la renovación de token ENTONCES:
- Reintentar automáticamente hasta 3 veces
- Esperar con backoff exponencial (1s, 2s, 4s)
- Si falla definitivamente: Redirigir a login

**REQ-AUTH-REL-003: Sincronización de reloj**

CUANDO el reloj del dispositivo esté desincronizado ENTONCES:
- Validar tokens con tolerancia de ±5 minutos
- Mostrar advertencia si desincronización es > 10 minutos
- Permitir que usuario corrija hora del dispositivo

#### 3.2.4. Usabilidad

**REQ-AUTH-UX-001: Mensajes de error claros**

CUANDO ocurra un error ENTONCES mostrar:
- "Email o contraseña incorrectos" (no especificar cuál)
- "Cuenta bloqueada temporalmente. Intente en X minutos"
- "Sin conexión a internet"
- "Sesión expirada. Por favor, inicie sesión nuevamente"

**REQ-AUTH-UX-002: Indicadores visuales**

CUANDO se realice login ENTONCES:
- Mostrar indicador de carga durante validación
- Deshabilitar botón de login mientras se procesa
- Mostrar progreso de operación

**REQ-AUTH-UX-003: Recuperación de contraseña**

CUANDO un usuario olvide su contraseña ENTONCES:
- Mostrar opción "¿Olvidó su contraseña?"
- Redirigir a pantalla de recuperación
- Permitir reset mediante email

---

## 4. Casos de Uso

### 4.1. Caso de Uso: Login Exitoso

**Actor:** Usuario
**Precondición:** Usuario tiene cuenta registrada en backend

**Flujo Principal:**
1. Usuario abre la app
2. Sistema detecta que no hay sesión activa
3. Muestra pantalla de login
4. Usuario ingresa email y contraseña
5. Usuario toca botón "Iniciar Sesión"
6. Sistema valida credenciales localmente
7. Sistema envía POST `/auth/login` al backend
8. Backend valida credenciales y retorna tokens
9. Sistema almacena tokens en Secure Storage
10. Sistema notifica a la app que usuario está autenticado
11. App redirige a pantalla de home
12. Usuario ve su dashboard

**Postcondición:** Usuario autenticado, tokens almacenados, sesión activa

### 4.2. Caso de Uso: Renovación Automática de Token

**Actor:** Sistema
**Precondición:** Usuario tiene sesión activa, access_token próximo a expirar

**Flujo Principal:**
1. Sistema detecta que access_token expira en < 5 minutos
2. Sistema envía POST `/auth/refresh` con refresh_token
3. Backend valida refresh_token y retorna nuevo access_token
4. Sistema actualiza access_token en Secure Storage
5. Sistema continúa operación sin interrupciones
6. Usuario no se da cuenta de la renovación

**Postcondición:** Token renovado, sesión continúa activa

### 4.3. Caso de Uso: Logout

**Actor:** Usuario
**Precondición:** Usuario tiene sesión activa

**Flujo Principal:**
1. Usuario toca botón "Cerrar Sesión"
2. Sistema muestra confirmación
3. Usuario confirma
4. Sistema elimina tokens de Secure Storage
5. Sistema cancela renovaciones pendientes
6. Sistema notifica a la app que usuario está desautenticado
7. App redirige a pantalla de login
8. Todos los datos de usuario se limpian de memoria

**Postcondición:** Sesión cerrada, tokens eliminados, usuario en pantalla de login

### 4.4. Caso de Uso: Bloqueo por Intentos Fallidos

**Actor:** Usuario
**Precondición:** Usuario ha fallado login 4 veces

**Flujo Principal:**
1. Usuario ingresa email y contraseña incorrectos
2. Sistema valida y detecta que es el 5to intento fallido
3. Sistema bloquea la cuenta por 15 minutos
4. Sistema muestra mensaje: "Cuenta bloqueada. Intente en 15 minutos"
5. Sistema registra el evento para auditoría
6. Usuario espera 15 minutos
7. Sistema automáticamente desbloquea la cuenta
8. Usuario puede intentar login nuevamente

**Postcondición:** Cuenta desbloqueada, contador de intentos reiniciado

---

## 5. Criterios de Aceptación

### 5.1. Criterios de Aceptación Generales

- [ ] AuthService implementado con métodos login(), logout(), refreshToken()
- [ ] Tokens almacenados en Secure Storage (Keychain/Keystore)
- [ ] AuthInterceptor inyecta tokens en todos los requests
- [ ] Renovación automática de tokens funciona sin interrupciones
- [ ] Manejo de 401 y 403 implementado correctamente
- [ ] Bloqueo por intentos fallidos funciona
- [ ] Logs no contienen credenciales o tokens completos
- [ ] Todos los tests pasan (unit, widget, integration)
- [ ] Código cumple con análisis estático (flutter analyze)
- [ ] Documentación completa en código (dartdoc)

### 5.2. Criterios de Seguridad

- [ ] Tokens NUNCA se hardcodean en el código
- [ ] Credenciales NUNCA se almacenan en plain text
- [ ] Comunicación SIEMPRE es HTTPS/TLS 1.3
- [ ] Secure Storage usa encriptación nativa del dispositivo
- [ ] Logs no exponen información sensible
- [ ] Validación de entrada en credenciales

### 5.3. Criterios de Rendimiento

- [ ] Login completa en < 2.5 segundos
- [ ] Renovación de token en < 1 segundo
- [ ] Recuperación de sesión en < 200ms
- [ ] No hay bloqueos en UI durante operaciones

---

## 6. Dependencias

**Dependencias de Código:**
- flutter_secure_storage: ^9.0.0
- jwt_decoder: ^2.0.1
- http: ^1.2.0 (ya incluido)
- flutter_riverpod: ^2.5.1 (ya incluido)

**Dependencias de Servicios:**
- HttpClientService (completado en Task 4)
- LoggingService (completado en Task 4)
- EnvironmentManager (completado en Task 2)
- Backend API Gateway con endpoints `/auth/login` y `/auth/refresh`

**Dependencias de Infraestructura:**
- Secure Storage nativo (Keychain en iOS, Keystore en Android)
- HTTPS/TLS 1.3 en backend

---

## 7. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|--------|-----------|
| Tokens expiran sin renovación | Media | Alto | Implementar renovación automática con margen de 5 min |
| Secure Storage no disponible | Baja | Alto | Fallback a memoria (solo para sesión actual) |
| Reloj del dispositivo desincronizado | Media | Medio | Validar con tolerancia de ±5 minutos |
| Fallo de red durante login | Alta | Medio | Mostrar error claro, permitir reintentar |
| Tokens comprometidos | Baja | Crítico | Usar Secure Storage nativo, HTTPS, certificate pinning |
| Bloqueo de cuenta permanente | Baja | Medio | Implementar desbloqueo automático después de 15 min |

---

**Última actualización:** 17 de febrero de 2026
**Versión:** 1.0.0
**Estado:** 📋 Listo para Revisión
