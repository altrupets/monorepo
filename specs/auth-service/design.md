# Diseño: Servicio de Autenticación y Gestión de Tokens JWT

**Versión:** 1.0.0
**Sprint:** 1 (v0.3.0)
**Tarea:** 5 - Implementar servicio de autenticación y gestión de tokens JWT
**Estado:** 📐 Diseño en Revisión

---

## 1. Visión General

El **AuthService** es un componente central que gestiona la autenticación de usuarios y el ciclo de vida de tokens JWT. Proporciona una interfaz simple para login/logout, almacenamiento seguro de tokens, renovación automática y sincronización de estado en toda la aplicación.

### Arquitectura de Alto Nivel

```
┌─────────────────────────────────────────────────────────────┐
│                    Aplicación Flutter                        │
│  (Pantallas, BLoCs, ViewModels)                              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              AuthService (Riverpod Provider)                 │
│  - login(email, password)                                    │
│  - logout()                                                  │
│  - refreshToken()                                            │
│  - getAccessToken()                                          │
│  - isAuthenticated()                                         │
└────────────────────────┬────────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ HttpClient   │ │ SecureStorage│ │ LoggingService
│ Service      │ │              │ │
└──────────────┘ └──────────────┘ └──────────────┘
        │                │
        └────────────────┼────────────────┐
                         │                │
                         ▼                ▼
                    ┌──────────────┐ ┌──────────────┐
                    │ Backend API  │ │ Keychain/    │
                    │ Gateway      │ │ Keystore     │
                    └──────────────┘ └──────────────┘
```

---

## 2. Componentes y Interfaces

### 2.1. AuthService

**Responsabilidad:** Gestionar autenticación, tokens y sesiones de usuario

**Métodos Públicos:**

```dart
class AuthService {
  /// Login con credenciales
  Future<User> login(String email, String password)

  /// Logout del usuario actual
  Future<void> logout()

  /// Renovar access token usando refresh token
  Future<void> refreshToken()

  /// Obtener access token actual
  Future<String?> getAccessToken()

  /// Obtener refresh token actual
  Future<String?> getRefreshToken()

  /// Verificar si usuario está autenticado
  Future<bool> isAuthenticated()

  /// Obtener información del usuario actual
  Future<User?> getCurrentUser()

  /// Restaurar sesión al iniciar app
  Future<void> restoreSession()

  /// Stream de cambios de autenticación
  Stream<AuthState> get authStateStream
}
```

**Propiedades:**

```dart
class AuthService {
  // Configuración
  final EnvironmentManager _environmentManager;
  final HttpClientService _httpClientService;
  final LoggingService _loggingService;

  // Almacenamiento seguro
  final FlutterSecureStorage _secureStorage;

  // Estado
  late AuthState _currentState;
  late StreamController<AuthState> _authStateController;

  // Timers
  Timer? _tokenRefreshTimer;

  // Constantes
  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _tokenExpiryKey = 'auth_token_expiry';
  static const String _userInfoKey = 'auth_user_info';
  static const int _maxLoginAttempts = 5;
  static const int _lockoutDurationMinutes = 15;
  static const int _tokenRefreshThresholdMinutes = 5;
}
```

### 2.2. AuthState

**Responsabilidad:** Representar el estado actual de autenticación

```dart
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  final String accessToken;

  const AuthAuthenticated({
    required this.user,
    required this.accessToken,
  });
}

class AuthUnauthenticated extends AuthState {
  final String? message;

  const AuthUnauthenticated({this.message});
}

class AuthError extends AuthState {
  final String message;
  final Exception? exception;

  const AuthError({
    required this.message,
    this.exception,
  });
}

class AuthLocked extends AuthState {
  final DateTime unlockedAt;

  const AuthLocked({required this.unlockedAt});
}
```

### 2.3. User Model

**Responsabilidad:** Representar información del usuario autenticado

```dart
class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final List<String> roles;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    required this.roles,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

### 2.4. AuthInterceptor (Mejorado)

**Responsabilidad:** Inyectar tokens en requests y manejar 401/403

```dart
class AuthInterceptor extends Interceptor {
  final AuthService _authService;
  final LoggingService _loggingService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Obtener token actual
    final token = await _authService.getAccessToken();

    if (token != null) {
      // Inyectar token en header
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Manejar 401 Unauthorized
    if (err.response?.statusCode == 401) {
      // Intentar renovar token
      try {
        await _authService.refreshToken();

        // Reintentar request original
        final options = err.requestOptions;
        final token = await _authService.getAccessToken();
        options.headers['Authorization'] = 'Bearer $token';

        final response = await Dio().request(
          options.path,
          options: Options(
            method: options.method,
            headers: options.headers,
          ),
          data: options.data,
          queryParameters: options.queryParameters,
        );

        handler.resolve(response);
      } catch (e) {
        // Renovación falló, redirigir a login
        await _authService.logout();
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}
```

---

## 3. Flujos de Operación

### 3.1. Flujo de Login

```
Usuario ingresa credenciales
        │
        ▼
┌─────────────────────────────────┐
│ Validar credenciales localmente │
│ - Email válido                  │
│ - Contraseña no vacía           │
└─────────────────────────────────┘
        │
        ├─ Validación falla ──→ Mostrar error
        │
        ▼
┌─────────────────────────────────┐
│ Verificar bloqueo de cuenta     │
│ - ¿Cuenta bloqueada?            │
│ - ¿Tiempo de bloqueo expirado?  │
└─────────────────────────────────┘
        │
        ├─ Bloqueada ──→ Mostrar "Cuenta bloqueada"
        │
        ▼
┌─────────────────────────────────┐
│ POST /auth/login                │
│ - Email                         │
│ - Contraseña                    │
└─────────────────────────────────┘
        │
        ├─ Error de red ──→ Mostrar "Sin conexión"
        │
        ├─ 401 ──→ Incrementar contador, mostrar error
        │
        ▼
┌─────────────────────────────────┐
│ Almacenar tokens en Secure      │
│ Storage                         │
│ - access_token                  │
│ - refresh_token                 │
│ - expires_in                    │
│ - user_info                     │
└─────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────┐
│ Programar renovación automática │
│ - Calcular tiempo de renovación │
│ - Crear timer                   │
└─────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────┐
│ Notificar a la app              │
│ - Emitir AuthAuthenticated      │
│ - Redirigir a home              │
└─────────────────────────────────┘
```

### 3.2. Flujo de Renovación Automática de Token

```
Timer dispara (5 min antes de expiración)
        │
        ▼
┌─────────────────────────────────┐
│ Obtener refresh_token           │
│ de Secure Storage               │
└─────────────────────────────────┘
        │
        ├─ No existe ──→ Redirigir a login
        │
        ▼
┌─────────────────────────────────┐
│ POST /auth/refresh              │
│ - refresh_token                 │
└─────────────────────────────────┘
        │
        ├─ Error de red ──→ Reintentar en 5s
        │
        ├─ 401 ──→ Redirigir a login
        │
        ▼
┌─────────────────────────────────┐
│ Actualizar access_token         │
│ en Secure Storage               │
└─────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────┐
│ Programar próxima renovación    │
│ - Calcular nuevo tiempo         │
│ - Crear nuevo timer             │
└─────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────┐
│ Continuar operación             │
│ (Usuario no se da cuenta)       │
└─────────────────────────────────┘
```

### 3.3. Flujo de Logout

```
Usuario toca "Cerrar Sesión"
        │
        ▼
┌─────────────────────────────────┐
│ Mostrar confirmación            │
└─────────────────────────────────┘
        │
        ├─ Cancelar ──→ Volver a pantalla anterior
        │
        ▼
┌─────────────────────────────────┐
│ Cancelar timer de renovación    │
└─────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────┐
│ Eliminar tokens de Secure       │
│ Storage                         │
│ - access_token                  │
│ - refresh_token                 │
│ - expires_in                    │
│ - user_info                     │
└─────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────┐
│ Limpiar estado en memoria       │
│ - Cancelar requests pendientes  │
│ - Limpiar caché                 │
└─────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────┐
│ Notificar a la app              │
│ - Emitir AuthUnauthenticated    │
│ - Redirigir a login             │
└─────────────────────────────────┘
```

### 3.4. Flujo de Restauración de Sesión al Iniciar App

```
App inicia
        │
        ▼
┌─────────────────────────────────┐
│ Intentar recuperar tokens de    │
│ Secure Storage                  │
└─────────────────────────────────┘
        │
        ├─ No existen ──→ Mostrar login
        │
        ▼
┌─────────────────────────────────┐
│ Validar que tokens no estén     │
│ expirados                       │
└─────────────────────────────────┘
        │
        ├─ Expirados ──→ Intentar renovación
        │
        ▼
┌─────────────────────────────────┐
│ Decodificar JWT y extraer info  │
│ de usuario                      │
└─────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────┐
│ Restaurar sesión                │
│ - Emitir AuthAuthenticated      │
│ - Programar renovación          │
│ - Mostrar home                  │
└─────────────────────────────────┘
```

---

## 4. Modelos de Datos

### 4.1. Estructura de JWT

```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "sub": "user-id-123",
    "email": "user@example.com",
    "roles": ["sentinela", "donante"],
    "iat": 1708100000,
    "exp": 1708186400,
    "iss": "altrupets-backend"
  },
  "signature": "..."
}
```

### 4.2. Respuesta de Login

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 86400,
  "token_type": "Bearer",
  "user": {
    "id": "user-id-123",
    "email": "user@example.com",
    "firstName": "Juan",
    "lastName": "Pérez",
    "roles": ["sentinela", "donante"],
    "createdAt": "2024-02-17T10:00:00Z",
    "lastLoginAt": "2024-02-17T15:30:00Z"
  }
}
```

### 4.3. Respuesta de Refresh

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 86400,
  "token_type": "Bearer"
}
```

---

## 5. Almacenamiento Seguro

### 5.1. Estructura en Secure Storage

```
Keychain (iOS) / Keystore (Android)
├── auth_access_token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
├── auth_refresh_token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
├── auth_token_expiry: "1708186400"
└── auth_user_info: "{\"id\": \"user-id-123\", \"email\": \"user@example.com\", ...}"
```

### 5.2. Encriptación

- **iOS:** Keychain con protección de clase `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- **Android:** Keystore con encriptación de dispositivo
- **Ambos:** Encriptación nativa del SO, no accesible a otras apps

---

## 6. Manejo de Errores

### 6.1. Errores de Autenticación

| Error | Causa | Acción |
|-------|-------|--------|
| 401 Unauthorized | Credenciales inválidas | Mostrar "Email o contraseña incorrectos" |
| 403 Forbidden | Usuario sin permisos | Mostrar "Acceso denegado" |
| 429 Too Many Requests | Rate limiting | Mostrar "Demasiados intentos. Intente más tarde" |
| 500 Server Error | Error del backend | Mostrar "Error del servidor. Intente más tarde" |

### 6.2. Errores de Red

| Error | Causa | Acción |
|-------|-------|--------|
| SocketException | Sin conexión | Mostrar "Sin conexión a internet" |
| TimeoutException | Timeout | Mostrar "Tiempo de espera agotado" |
| CertificateException | Certificado inválido | Mostrar "Error de seguridad" |

### 6.3. Errores de Almacenamiento

| Error | Causa | Acción |
|-------|-------|--------|
| Secure Storage no disponible | Dispositivo sin Keychain/Keystore | Fallback a memoria (solo sesión actual) |
| Token corrupto | Datos dañados | Limpiar y redirigir a login |

---

## 7. Seguridad

### 7.1. Principios de Seguridad

1. **Defensa en Profundidad:** Múltiples capas de protección
2. **Principio de Menor Privilegio:** Solo permisos necesarios
3. **Encriptación en Tránsito:** HTTPS/TLS 1.3
4. **Encriptación en Reposo:** Secure Storage nativo
5. **No Confiar en Cliente:** Validación siempre en backend

### 7.2. Protecciones Implementadas

- ✅ Tokens en Secure Storage (no en SharedPreferences)
- ✅ HTTPS/TLS 1.3 para comunicación
- ✅ Validación de credenciales en cliente (UX)
- ✅ Validación de credenciales en backend (seguridad)
- ✅ Bloqueo por intentos fallidos
- ✅ Logs sin credenciales o tokens completos
- ✅ Renovación automática de tokens
- ✅ Manejo de 401 con re-autenticación

### 7.3. Futuras Mejoras

- 🔄 Certificate pinning
- 🔄 Autenticación biométrica
- 🔄 Autenticación de dos factores
- 🔄 OAuth 2.0 / OpenID Connect

---

## 8. Integración con Otros Componentes

### 8.1. Integración con HttpClientService

```dart
// AuthService usa HttpClientService para requests
final response = await _httpClientService.post<LoginResponse>(
  '/auth/login',
  data: {
    'email': email,
    'password': password,
  },
);
```

### 8.2. Integración con AuthInterceptor

```dart
// AuthInterceptor usa AuthService para obtener tokens
final token = await _authService.getAccessToken();
options.headers['Authorization'] = 'Bearer $token';
```

### 8.3. Integración con Riverpod

```dart
// AuthService como provider
final authServiceProvider = Provider<AuthService>((ref) {
  final httpClient = ref.watch(httpClientServiceProvider);
  final logger = ref.watch(loggingServiceProvider);
  final environment = ref.watch(environmentManagerProvider);
  return AuthService(
    httpClientService: httpClient,
    loggingService: logger,
    environmentManager: environment,
  );
});

// Estado de autenticación como provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateStream;
});

// Usuario actual como provider
final currentUserProvider = FutureProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUser();
});
```

---

## 9. Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### 9.1. Propiedades de Autenticación

**Property 1: Login Success Invariant**

*For any* valid email and password combination, after successful login:
- Access token must be stored in Secure Storage
- Refresh token must be stored in Secure Storage
- User information must be stored in Secure Storage
- AuthState must be AuthAuthenticated
- Token refresh timer must be scheduled

**Validates: REQ-AUTH-001, REQ-AUTH-004**

**Property 2: Token Expiration Invariant**

*For any* access token, if current time >= token expiration time:
- Token must be considered expired
- System must attempt automatic renewal
- If renewal fails, user must be redirected to login

**Validates: REQ-AUTH-006, REQ-AUTH-007**

**Property 3: Logout Cleanup Invariant**

*For any* authenticated session, after logout:
- All tokens must be removed from Secure Storage
- Token refresh timer must be cancelled
- AuthState must be AuthUnauthenticated
- All user data must be cleared from memory

**Validates: REQ-AUTH-002, REQ-AUTH-013**

**Property 4: Session Restoration Round-Trip**

*For any* valid session with stored tokens:
- Restoring session at app startup must recover the same user
- Tokens must be valid and not expired
- User information must match what was stored

**Validates: REQ-AUTH-005, REQ-AUTH-014**

**Property 5: Failed Login Attempt Tracking**

*For any* sequence of failed login attempts:
- After 5 consecutive failures, account must be locked
- Lock duration must be exactly 15 minutes
- After lock expires, counter must reset to 0
- Successful login must reset counter to 0

**Validates: REQ-AUTH-011**

**Property 6: Token Injection Consistency**

*For any* HTTP request made while authenticated:
- Authorization header must contain "Bearer {access_token}"
- Token must be the current valid access token
- If token is expired, it must be renewed before request

**Validates: REQ-AUTH-008, REQ-AUTH-009**

**Property 7: 401 Automatic Recovery**

*For any* request that returns 401 Unauthorized:
- System must attempt token renewal automatically
- If renewal succeeds, original request must be retried
- If renewal fails, user must be redirected to login
- No request should fail with 401 if renewal is possible

**Validates: REQ-AUTH-009**

**Property 8: Secure Storage Encryption**

*For any* token stored in Secure Storage:
- Token must be encrypted using device's native encryption
- Token must not be readable by other applications
- Token must be deleted if device is reset

**Validates: REQ-AUTH-SEC-001**

---

## 10. Testing Strategy

### 10.1. Unit Tests

**AuthService Tests:**
- Login with valid credentials
- Login with invalid credentials
- Login with network error
- Logout clears all data
- Token refresh updates tokens
- Session restoration works
- Failed login attempts increment counter
- Account locks after 5 failures
- Account unlocks after timeout

**AuthState Tests:**
- State transitions are correct
- State equality works
- State serialization works

**User Model Tests:**
- JSON serialization/deserialization
- Equality comparison
- Required fields validation

### 10.2. Widget Tests

**Login Screen Tests:**
- Email validation shows error
- Password validation shows error
- Loading indicator shows during login
- Error message displays on failure
- Success redirects to home

**Auth State Listeners:**
- UI updates when auth state changes
- Redirect to login on logout
- Redirect to home on login

### 10.3. Integration Tests

**Complete Login Flow:**
- User enters credentials
- System validates and sends to backend
- Backend returns tokens
- Tokens stored in Secure Storage
- User redirected to home
- User can access protected resources

**Token Renewal Flow:**
- User logged in with valid token
- Wait for token to expire
- System automatically renews token
- User continues using app without interruption

**Logout Flow:**
- User logged in
- User taps logout
- Tokens deleted from Secure Storage
- User redirected to login
- User cannot access protected resources

### 10.4. Property-Based Tests

**Property 1: Login Success Invariant**
- Generate random valid email/password
- Perform login
- Verify all tokens stored
- Verify AuthState is AuthAuthenticated

**Property 2: Token Expiration Invariant**
- Generate random token with expiration
- Verify expiration detection
- Verify renewal attempt

**Property 3: Logout Cleanup Invariant**
- Generate random authenticated session
- Perform logout
- Verify all tokens removed
- Verify AuthState is AuthUnauthenticated

**Property 4: Session Restoration Round-Trip**
- Generate random valid session
- Store tokens
- Restore session
- Verify same user recovered

**Property 5: Failed Login Attempt Tracking**
- Generate sequence of 5 failed attempts
- Verify account locked
- Verify lock duration
- Verify counter reset after lock expires

**Property 6: Token Injection Consistency**
- Generate random authenticated session
- Make multiple requests
- Verify all have Authorization header
- Verify token is current valid token

**Property 7: 401 Automatic Recovery**
- Generate request that returns 401
- Verify automatic renewal attempt
- Verify request retry
- Verify success without user intervention

**Property 8: Secure Storage Encryption**
- Generate random token
- Store in Secure Storage
- Verify encrypted
- Verify not readable by other apps

---

## 11. Error Handling

### 11.1. Estrategia de Manejo de Errores

```dart
try {
  final response = await _httpClientService.post<LoginResponse>(
    '/auth/login',
    data: {'email': email, 'password': password},
  );

  // Procesar respuesta exitosa
  await _storeTokens(response);
  _scheduleTokenRefresh();
  _authStateController.add(AuthAuthenticated(...));

} on AuthenticationException catch (e) {
  // Credenciales inválidas
  _incrementFailedAttempts();
  if (_failedAttempts >= 5) {
    _lockAccount();
    _authStateController.add(AuthLocked(...));
  } else {
    _authStateController.add(AuthError(message: 'Email o contraseña incorrectos'));
  }

} on NetworkConnectionException catch (e) {
  // Sin conexión
  _authStateController.add(AuthError(message: 'Sin conexión a internet'));

} on NetworkTimeoutException catch (e) {
  // Timeout
  _authStateController.add(AuthError(message: 'Tiempo de espera agotado'));

} catch (e) {
  // Error desconocido
  _loggingService.error('Login failed', exception: e);
  _authStateController.add(AuthError(message: 'Error desconocido'));
}
```

---

## 12. Observabilidad

### 12.1. Logging

```dart
// Login exitoso
logger.info(
  'User logged in successfully',
  tag: 'AuthService',
  context: {'email': email, 'roles': user.roles},
);

// Login fallido
logger.warning(
  'Login failed - invalid credentials',
  tag: 'AuthService',
  context: {'email': email, 'attempt': failedAttempts},
);

// Token renovado
logger.debug(
  'Token refreshed successfully',
  tag: 'AuthService',
  context: {'expiresIn': expiresIn},
);

// Cuenta bloqueada
logger.error(
  'Account locked due to failed attempts',
  tag: 'AuthService',
  context: {'email': email, 'unlockedAt': unlockedAt},
);
```

### 12.2. Métricas

- Tiempo de login (ms)
- Tasa de éxito de login (%)
- Tasa de renovación de tokens (%)
- Número de cuentas bloqueadas
- Tiempo promedio de renovación (ms)

---

**Última actualización:** 17 de febrero de 2026
**Versión:** 1.0.0
**Estado:** 📐 Listo para Revisión
