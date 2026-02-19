# Autenticación

El backend utiliza JWT (JSON Web Tokens) para autenticación.

## Flujo de Autenticación

```
┌─────────────┐     POST /graphql          ┌─────────────┐
│   Cliente   │ ─────────────────────────▶ │   Backend   │
└─────────────┘    {login mutation}        └─────────────┘
                        │
                        ▼
                 { access_token }
                        │
        ┌───────────────┴───────────────┐
        │                               │
        ▼                               ▼
┌───────────────┐              ┌───────────────┐
│ GraphQL Query │              │  REST Call    │
│ Authorization │              │ Authorization │
│ Bearer <jwt>  │              │ Bearer <jwt>  │
└───────────────┘              └───────────────┘
```

## Login

### GraphQL

```graphql
mutation Login($username: String!, $password: String!) {
  login(loginInput: { username: $username, password: $password }) {
    access_token
    expires_in
  }
}
```

### REST (Web)

```bash
POST /login
Content-Type: application/json

{
  "username": "usuario",
  "password": "contraseña"
}
```

## Uso del Token

Incluir en headers:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## Roles

| Rol | Descripción |
|-----|-------------|
| `SUPER_USER` | Acceso total |
| `GOVERNMENT_ADMIN` | Admin gubernamental |
| `WATCHER` | Solo lectura |

## Expiración

- Token expira en 1 hora
- Refresh token disponible para renovación

## Almacenamiento Seguro

- Tokens almacenados en httpOnly cookies (web)
- AsyncStorage con encriptación (mobile)
- Nunca en localStorage
