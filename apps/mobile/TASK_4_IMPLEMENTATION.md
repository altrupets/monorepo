# Task 4: HTTP Client Base y Manejo de Errores - Implementación Completa

**Sprint:** 1 (v0.3.0)  
**Requisitos Asociados:** REQ-FLT-031, REQ-FLT-020, REQ-REL-002, REQ-REL-004  
**Estado:** ✅ Completado

## Resumen de Implementación

Se ha implementado un cliente HTTP robusto y completo que cumple con todos los requisitos de comunicación con microservicios backend, incluyendo:

- ✅ Cliente HTTP base con Dio
- ✅ Interceptores para logging, autenticación y manejo de errores
- ✅ Reintentos automáticos con backoff exponencial (REQ-REL-004)
- ✅ Patrón Circuit Breaker para prevenir cascadas de errores (REQ-REL-002)
- ✅ Logging estructurado siguiendo principios cloud-native (REQ-FLT-020)
- ✅ Manejo centralizado de excepciones
- ✅ Configuración de timeouts y reintentos
- ✅ Tests unitarios completos

## Archivos Creados/Modificados

### Nuevos Archivos

#### 1. `lib/core/network/interceptors/retry_interceptor.dart`
**Propósito:** Implementar reintentos automáticos con backoff exponencial

**Características:**
- Reintentos configurables (máximo 3 por defecto)
- Backoff exponencial con jitter para evitar "thundering herd"
- Códigos de estado retryables: 408, 429, 500, 502, 503, 504
- Tipos de excepción retryables: SocketException, TimeoutException
- Logging de intentos de reintento

**Requisito:** REQ-REL-004 - Reintentos con backoff exponencial

```dart
// Uso automático en HttpClientService
RetryInterceptor(
  maxRetries: 3,
  initialDelayMs: 100,
  maxDelayMs: 10000,
  backoffMultiplier: 2.0,
)
```

#### 2. `lib/core/network/circuit_breaker.dart`
**Propósito:** Implementar patrón Circuit Breaker para prevenir cascadas de errores

**Características:**
- Estados: Closed, Open, Half-Open
- Transiciones automáticas basadas en éxitos/fallos
- Timeout configurable para intentar recuperación
- CircuitBreakerManager para gestionar múltiples endpoints
- Callbacks para cambios de estado

**Requisito:** REQ-REL-002 - Circuit Breaker ante fallas

```dart
// Uso en HttpClientService
final breaker = circuitBreakerManager.getBreaker('/api/users');
if (!breaker.isOpen) {
  // Realizar request
}
```

#### 3. `lib/core/services/logging_service.dart`
**Propósito:** Servicio de logging estructurado siguiendo principios cloud-native

**Características:**
- Niveles de log: debug, info, warning, error, critical
- Contexto estructurado con metadatos
- Observadores de logs para extensibilidad
- Emojis para identificación visual rápida
- Exportación de logs a JSON

**Requisito:** REQ-FLT-020 - Logging estructurado

```dart
// Uso
logger.info(
  'HTTP Client initialized',
  tag: 'HttpClientService',
  context: {
    'baseUrl': environment.apiBaseUrl,
    'timeout': environment.requestTimeoutSeconds,
  },
);
```

### Archivos Modificados

#### 1. `lib/core/network/http_client_service.dart`
**Cambios:**
- Integración de RetryInterceptor
- Integración de CircuitBreakerManager
- Logging estructurado en todos los métodos HTTP
- Verificación de circuit breaker antes de requests
- Grabación de éxitos/fallos en circuit breaker
- Mejor manejo de errores con contexto

**Orden de Interceptores (crítico):**
1. LoggingInterceptor - Registra todas las requests
2. AuthInterceptor - Inyecta tokens JWT
3. RetryInterceptor - Reintentos con backoff exponencial
4. ErrorInterceptor - Manejo centralizado de errores

### Tests

#### 1. `test/core/network/http_client_service_test.dart`
**Cobertura:**
- Inicialización correcta del cliente HTTP
- Presencia de todos los interceptores requeridos
- Comportamiento del Circuit Breaker (open, half-open, closed)
- Recuperación automática del Circuit Breaker
- Manejo de diferentes tipos de errores
- Lógica de reintentos
- Logging estructurado

**Ejecución:**
```bash
flutter test test/core/network/http_client_service_test.dart
```

## Flujo de Comunicación HTTP

```
┌─────────────────────────────────────────────────────────────┐
│                    Aplicación Flutter                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              HttpClientService.get/post/put/delete           │
│  - Verifica Circuit Breaker                                  │
│  - Realiza request                                           │
│  - Registra éxito/fallo en Circuit Breaker                   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Interceptor Chain                         │
│  1. LoggingInterceptor      - Registra request/response      │
│  2. AuthInterceptor         - Inyecta JWT token              │
│  3. RetryInterceptor        - Reintentos con backoff         │
│  4. ErrorInterceptor        - Convierte errores              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Dio HTTP Client                           │
│  - Configura timeouts                                        │
│  - Maneja certificados SSL/TLS                               │
│  - Compresión de datos                                       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Backend Microservices (API Gateway)             │
└─────────────────────────────────────────────────────────────┘
```

## Manejo de Errores

### Jerarquía de Excepciones

```
NetworkException (base)
├── NetworkConnectionException    - Sin conexión a internet
├── NetworkTimeoutException       - Request timeout
├── ServerException               - Errores 4xx/5xx
├── GraphQLException              - Errores GraphQL
├── ParseException                - Fallo al parsear respuesta
├── ValidationException           - Errores de validación
├── AuthenticationException       - 401 Unauthorized
├── AuthorizationException        - 403 Forbidden
├── NotFoundException             - 404 Not Found
├── CancelledException            - Request cancelado
└── UnknownException              - Error desconocido
```

### Ejemplo de Manejo de Errores

```dart
try {
  final response = await httpClientService.get<User>('/api/users/123');
  // Procesar respuesta
} on AuthenticationException catch (e) {
  // Redirigir a login
} on NetworkConnectionException catch (e) {
  // Mostrar modo offline
} on ServerException catch (e) {
  // Mostrar error del servidor
} on NetworkException catch (e) {
  // Mostrar error genérico de red
}
```

## Circuit Breaker - Estados y Transiciones

```
                    ┌─────────────┐
                    │   CLOSED    │
                    │ (Requests   │
                    │  allowed)   │
                    └──────┬──────┘
                           │
                    Failures >= 5
                           │
                           ▼
                    ┌─────────────┐
                    │    OPEN     │
                    │ (Requests   │
                    │  blocked)   │
                    └──────┬──────┘
                           │
                    Timeout >= 30s
                           │
                           ▼
                    ┌─────────────┐
                    │ HALF-OPEN   │
                    │ (Testing)   │
                    └──────┬──────┘
                           │
                ┌──────────┴──────────┐
                │                     │
         Success >= 2          Failure
                │                     │
                ▼                     ▼
           CLOSED              OPEN (restart)
```

## Configuración de Timeouts

```dart
// Configuración por entorno
Development:
  - connectTimeout: 30 segundos
  - receiveTimeout: 30 segundos
  - sendTimeout: 30 segundos

Production:
  - connectTimeout: 30 segundos
  - receiveTimeout: 30 segundos
  - sendTimeout: 30 segundos
```

## Logging Estructurado

### Niveles de Log

```
🔵 DEBUG   - Información detallada para debugging
ℹ️  INFO    - Información general del sistema
⚠️  WARNING - Advertencias que no impiden operación
❌ ERROR   - Errores que requieren atención
🔴 CRITICAL - Errores críticos que afectan funcionalidad
```

### Ejemplo de Log Estructurado

```
ℹ️ INFO [HttpClientService] 2024-02-17T10:30:45.123Z
   HTTP Client initialized
   Context: {baseUrl: https://api.example.com, timeout: 30}

🔄 Retrying request (attempt 1/3) after 100ms: /api/users

❌ ERROR [HttpClientService] 2024-02-17T10:30:46.456Z
   POST request failed
   Context: {path: /api/users, statusCode: 500}
   Exception: ServerException: Server error: 500
```

## Requisitos Cumplidos

### REQ-FLT-031: Cliente HTTP robusto con Dio
- ✅ Uso de Dio como cliente HTTP
- ✅ Interceptores para logging, retry y headers automáticos
- ✅ Manejo de errores centralizado
- ✅ Configuración de timeouts

### REQ-FLT-020: Logging estructurado
- ✅ Servicio de logging centralizado
- ✅ Niveles de log configurables
- ✅ Contexto estructurado con metadatos
- ✅ Observadores extensibles

### REQ-REL-002: Circuit Breaker ante fallas
- ✅ Implementación de patrón Circuit Breaker
- ✅ Prevención de cascadas de errores
- ✅ Recuperación automática
- ✅ Gestión por endpoint

### REQ-REL-004: Reintentos con backoff exponencial
- ✅ Reintentos automáticos configurables
- ✅ Backoff exponencial con jitter
- ✅ Códigos de estado retryables
- ✅ Tipos de excepción retryables

## Próximos Pasos

### Task 5: Servicio de Autenticación y Gestión de Tokens JWT
- Implementar AuthService con login/logout
- Almacenamiento seguro de tokens
- Renovación automática de tokens
- Interceptor mejorado para inyección de tokens

### Task 6: Servicio de Geolocalización
- Captura de ubicación GPS
- Permisos de ubicación
- Caché local de ubicaciones
- Selección manual en mapa

## Dependencias Utilizadas

```yaml
# Networking
dio: ^5.4.0              # Cliente HTTP
http: ^1.2.0             # Alternativa HTTP

# State Management
flutter_riverpod: ^2.5.1 # Inyección de dependencias

# Testing
mockito: ^5.4.4          # Mocking
mocktail: ^1.0.1         # Mocking alternativo
```

## Notas de Implementación

1. **Orden de Interceptores:** El orden es crítico. LoggingInterceptor debe ser primero para capturar todas las requests.

2. **Circuit Breaker por Endpoint:** Cada endpoint tiene su propio circuit breaker para evitar bloquear todo el sistema si un servicio falla.

3. **Jitter en Backoff:** Se añade jitter al backoff exponencial para evitar que múltiples clientes reintenten simultáneamente.

4. **Logging en Producción:** El logging se puede configurar para enviar a servicios como Sentry o Datadog.

5. **Seguridad:** Se implementa HTTPS obligatorio y validación de certificados SSL/TLS.

## Validación

Para validar que la implementación es correcta:

```bash
# Ejecutar tests
flutter test test/core/network/http_client_service_test.dart

# Verificar análisis estático
flutter analyze

# Verificar formato de código
dart format lib/core/network/ lib/core/services/

# Ejecutar la aplicación
flutter run
```

## Referencias

- [Dio Documentation](https://pub.dev/packages/dio)
- [Circuit Breaker Pattern](https://martinfowler.com/bliki/CircuitBreaker.html)
- [Exponential Backoff](https://en.wikipedia.org/wiki/Exponential_backoff)
- [12-Factor App - Logging](https://12factor.net/logs)
- [Cloud-Native Logging Best Practices](https://www.splunk.com/en_us/blog/learn/cloud-native-logging.html)

---

**Implementado por:** Kiro Agent  
**Fecha:** 17 de febrero de 2026  
**Versión:** 1.0.0
