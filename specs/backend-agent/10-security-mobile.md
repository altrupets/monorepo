# PASO 10: Seguridad Mobile -> Agent

## 10.1 JWT Compartido

El backend y el agent comparten el mismo `JWT_SECRET` via Kubernetes Secrets.
El mobile obtiene su token del backend con `login()`, y ese mismo Bearer token es valido para queries al agent.

**Flujo:**

```
Mobile -> login(username, password) -> Backend -> AuthPayload { access_token }
Mobile -> recommendRescuers(Bearer token) -> Agent -> valida con mismo JWT_SECRET
```

## 10.2 Ejemplo Query GraphQL desde Flutter

### lib/features/agent/data/agent_graphql_queries.dart

```dart
const String recommendRescuersMutation = r'''
  mutation RecommendRescuers(
    $captureRequestId: String!
    $latitude: Float!
    $longitude: Float!
    $animalType: String!
  ) {
    recommendRescuers(
      captureRequestId: $captureRequestId
      latitude: $latitude
      longitude: $longitude
      animalType: $animalType
    ) {
      sessionId
      message
      recommendations {
        userId
        username
        roles
        distanceKm
        score
        reasoning
      }
    }
  }
''';
```

### lib/features/agent/data/agent_service.dart

```dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AgentGraphQLClient {
  static GraphQLClient create({required String agentUrl, required String token}) {
    final authLink = AuthLink(getToken: () => 'Bearer $token');
    final httpLink = HttpLink(agentUrl);
    return GraphQLClient(
      link: authLink.concat(httpLink),
      cache: GraphQLCache(),
    );
  }
}
```

## 10.3 Network Utils — Agent URL

En `apps/mobile/lib/core/utils/network_utils.dart`, agregar helper:

```dart
static String getAgentGraphQLUrl() {
  if (kDebugMode) {
    return '${getBaseUrl().replaceAll(':3001', ':3002')}/graphql';
  }
  return 'https://agent.altrupets.app/graphql';
}
```

## 10.4 CORS en Agent

Configurado en `src/main.ts` del agent (PASO 3):

```ts
app.enableCors({
  origin: ['http://localhost:3001', 'http://localhost:5173', 'http://192.168.1.81:*'],
  credentials: true,
});
```

Para acceso desde dispositivo fisico en la misma red WiFi, el mobile usa la IP del host que hace port-forward.
