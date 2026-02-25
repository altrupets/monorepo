# ⚙️ Core

## GraphQL Client

```dart
final client = GraphQLClientService.getClient();

// Query
final result = await client.query(QueryOptions(
  document: gql(myQuery),
  variables: {'id': '123'},
));

// Token management
await GraphQLClientService.saveToken(token);
await GraphQLClientService.clearToken();
final hasSession = await GraphQLClientService.hasActiveSession();
```

## Network

### Circuit Breaker

Implementa el patrón **REQ-REL-002: Circuit Breaker ante fallas**. Protege contra fallos en cascada.

```dart
// Configuración (default)
final breaker = CircuitBreaker(
  failureThreshold: 7,    // fallos antes de abrir
  successThreshold: 2,    // éxitos para cerrar
  timeout: Duration(seconds: 30),
);
```

**Estados:**
- `closed` - Normal, permite peticiones
- `open` - Bloquea todas las peticiones
- `half-open` - Permite pruebas para recuperar

**Uso:**
```dart
final manager = CircuitBreakerManager(); // usa defaults

// Antes de cada petición
if (!manager.isAvailable('/api/users')) {
  throw Exception('Servicio no disponible');
}

// Después de cada respuesta
manager.recordSuccess('/api/users');
manager.recordFailure('/api/users');
```

### Interceptors

- `AuthInterceptor` - JWT headers
- `ErrorInterceptor` - Error handling
- `LoggingInterceptor` - Request/response logging
- `RetryInterceptor` - Auto retry

### Network Info

```dart
final isConnected = await networkInfo.isConnected;
```

## Storage

### Secure Storage (tokens)

```dart
await secureStorage.write(key, value);
final value = await secureStorage.read(key);
```

### Profile Cache

```dart
await ProfileCacheStore.cacheProfile(user);
final cached = await ProfileCacheStore.getCachedProfile();
```

## Payments (LATAM)

Gateways: OnvoPay, Tilopay (CR), Wompi (CO), Conekta (MX), MercadoPago (BR)

```dart
final gateway = PaymentGatewayFactory.create(
  type: PaymentGatewayType.onvoPay,
  config: PaymentGatewayConfiguration(publicKey: 'pk_...'),
);

final token = await gateway.tokenizeCard(...);
final result = await gateway.processPayment(amount: 50000, currency: Currency.crc);
```

## Widgets (Atomic Design)

### Atoms

- `AppCircularButton`
- `AppRoleBadge`
- `SyncStatusIndicator`

### Molecules

- `AppInputCard`
- `AppNavItem`
- `AppServiceCard`
- `HomeWelcomeHeader`
- `ProfileMenuOption`

### Organisms

- `MainNavigationBar`
- `ProfileHeader`
- `StickyActionFooter`
- `SecureCardInputWidget`

## Services

- `AuthService` - Sesiones
- `GeolocationService` - GPS
- `LoggingService` - Logs
