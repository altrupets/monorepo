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
