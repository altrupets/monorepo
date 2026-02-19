# Backend API

AltruPets Backend es una API GraphQL construida con NestJS 11 y Express 5.

## Información General

| Propiedad | Valor |
|-----------|-------|
| Framework | NestJS 11 |
| Runtime | Node.js 20 |
| API | GraphQL (Apollo Server 5.x) + REST |
| Base URL | `/graphql` |

## Endpoints

### GraphQL

```bash
POST /graphql
Content-Type: application/json
```

### REST

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/health` | GET | Health check |
| `/login` | GET/POST | Login web |
| `/logout` | POST | Logout web |
| `/admin/*` | GET | Panel admin (Inertia) |
| `/b2g/*` | GET | Panel B2G (Inertia) |

## Autenticación

La API usa JWT con passport-jwt.

### Headers requeridos

```
Authorization: Bearer <token>
```

### Login

```graphql
mutation Login($input: LoginInput!) {
  login(loginInput: $input) {
    access_token
    expires_in
  }
}
```

Variables:
```json
{
  "input": {
    "username": "usuario",
    "password": "contraseña"
  }
}
```

## Queries

| Query | Descripción | Auth |
|-------|-------------|------|
| `users` | Lista usuarios | Admin |
| `user(id)` | Usuario por ID | Admin |
| `currentUser` | Usuario autenticado | JWT |
| `profile` | Perfil del usuario | JWT |
| `searchOrganizations` | Buscar organizaciones | Público |
| `getCaptureRequests` | Lista de capturas | Autenticado |

## Mutations

| Mutation | Descripción | Auth |
|----------|-------------|------|
| `register` | Registrar usuario | Público |
| `login` | Autenticar usuario | Público |
| `createUser` | Crear usuario | Admin |
| `updateUser` | Actualizar usuario | Admin |
| `deleteUser` | Eliminar usuario | Admin |
| `updateUserProfile` | Actualizar perfil | JWT |
| `createCaptureRequest` | Crear captura | Público |

## Ejemplos

### Obtener usuario actual

```graphql
query {
  currentUser {
    id
    username
    email
    roles
  }
}
```

### Crear captura

```graphql
mutation CreateCapture($input: CreateCaptureInput!) {
  createCaptureRequest(input: $input) {
    id
    imageUrl
    latitude
    longitude
  }
}
```

## Errores

Los errores siguen el formato estándar de GraphQL:

```json
{
  "errors": [
    {
      "message": "Error description",
      "path": ["mutationName"],
      "extensions": {
        "code": "ERROR_CODE"
      }
    }
  ]
}
```

### Códigos de error comunes

| Código | Descripción |
|--------|-------------|
| `GRAPHQL_VALIDATION_FAILED` | Error de validación |
| `UNAUTHENTICATED` | Token faltante o inválido |
| `FORBIDDEN` | Permisos insuficientes |
| `INTERNAL_SERVER_ERROR` | Error del servidor |

## Rate Limiting

Actualmente no implementado. Planificado para v1.1.0.

## Más información

Ver [API Reference completo](api.md) para detalles de cada operación.
