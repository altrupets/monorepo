# AltruPets Backend API Documentation

## Overview

The AltruPets Backend provides a GraphQL API for managing users, organizations, captures, and authentication.

**Base URL:** `http://localhost:3001/graphql` (dev)

## Authentication

All authenticated requests require a JWT token in the Authorization header:

```
Authorization: Bearer <access_token>
```

## GraphQL API

### Queries

| Query | Description | Auth Required |
|-------|-------------|---------------|
| `users` | List all users | SUPER_USER, GOVERNMENT_ADMIN |
| `user(id: ID!)` | Get user by ID | SUPER_USER, GOVERNMENT_ADMIN |
| `currentUser` | Get authenticated user | Yes |
| `profile` | Get user profile | Yes |
| `adminOnlyData` | Admin-only test query | GOVERNMENT_ADMIN |
| `searchOrganizations` | Search organizations | No |
| `organization(id: ID!)` | Get organization by ID | No |
| `organizationMemberships(orgId: ID!)` | Get org members | Yes |
| `myMemberships` | Get user's memberships | Yes |
| `getCaptureRequests` | List capture requests | WATCHER, GOVERNMENT_ADMIN, SUPER_USER |

### Mutations

| Mutation | Description | Auth Required |
|----------|-------------|---------------|
| `register` | Register new user | No |
| `login` | Authenticate user | No |
| `createUser` | Create user (admin) | SUPER_USER, GOVERNMENT_ADMIN |
| `updateUser` | Update user (admin) | SUPER_USER, GOVERNMENT_ADMIN |
| `deleteUser` | Delete user (admin) | SUPER_USER, GOVERNMENT_ADMIN |
| `updateUserProfile` | Update own profile | Yes |
| `registerOrganization` | Register new org | Yes |
| `requestMembership` | Request org membership | Yes |
| `approveMembership` | Approve membership request | Yes |
| `rejectMembership` | Reject membership request | Yes |
| `assignRole` | Assign org role | Yes |
| `createCaptureRequest` | Submit capture | No |

## Types

### User

```graphql
type User {
  id: ID!
  username: String!
  email: String
  firstName: String
  lastName: String
  bio: String
  roles: [UserRole!]!
  isActive: Boolean!
  isVerified: Boolean!
  avatarBase64: String
  avatarUrl: String
  organizationId: ID
  latitude: Float
  longitude: Float
  occupation: String
  incomeSource: String
  createdAt: DateTime!
  updatedAt: DateTime!
}
```

### UserRole

```graphql
enum UserRole {
  SUPER_USER
  GOVERNMENT_ADMIN
  WATCHER
}
```

### AuthPayload

```graphql
type AuthPayload {
  access_token: String!
  expires_in: Int!
  refresh_token: String
}
```

### Organization

```graphql
type Organization {
  id: ID!
  name: String!
  description: String
  type: String
  address: String
  latitude: Float
  longitude: Float
  createdAt: DateTime!
  updatedAt: DateTime!
}
```

### CaptureRequest

```graphql
type CaptureRequest {
  id: ID!
  imageUrl: String!
  latitude: Float!
  longitude: Float!
  capturedAt: DateTime!
  notes: String
  createdAt: DateTime!
}
```

## Example Queries

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
    "username": "admin",
    "password": "yourpassword"
  }
}
```

### Get Current User

```graphql
query {
  currentUser {
    id
    username
    email
    roles
    firstName
    lastName
  }
}
```

### List Users (Admin)

```graphql
query {
  users {
    id
    username
    email
    roles
    isActive
    createdAt
  }
}
```

### Update Profile

```graphql
mutation UpdateProfile($input: UpdateUserInput!) {
  updateUserProfile(input: $input) {
    id
    firstName
    lastName
    email
    bio
  }
}
```

### Create Capture Request

```graphql
mutation CreateCapture($input: CreateCaptureInput!) {
  createCaptureRequest(input: $input) {
    id
    imageUrl
    latitude
    longitude
    capturedAt
  }
}
```

## REST Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Health check (returns "Hello World!") |
| `/health` | GET | Detailed health status |
| `/login` | GET | Login page (Inertia) |
| `/login` | POST | Web login form |
| `/logout` | POST | Web logout |
| `/admin` | GET | Admin panel (Inertia) |
| `/admin/users` | GET | Admin users list (Inertia) |
| `/b2g` | GET | B2G panel (Inertia) |
| `/b2g/captures` | GET | B2G captures list (Inertia) |

## Error Handling

GraphQL errors follow this format:

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
  ],
  "data": null
}
```

### Common Error Codes

| Code | Description |
|------|-------------|
| `GRAPHQL_VALIDATION_FAILED` | Invalid query syntax |
| `INTERNAL_SERVER_ERROR` | Server-side error |
| `UNAUTHENTICATED` | Missing or invalid token |
| `FORBIDDEN` | Insufficient permissions |

## Rate Limiting

Currently not implemented. Will be added in v1.1.0.

## Database Migrations

| Migration | Description |
|-----------|-------------|
| `AddUserFields1708152000000` | Adds email, bio, organizationId, geolocation, status fields |
| `AddDonorFields1708153000000` | Adds occupation, incomeSource fields |
| `MigrateAvatarToUrl1771407449000` | Adds avatarUrl, avatarStorageProvider fields |

Run migrations:
```bash
cd apps/backend
npm run migration:run
```

## Development

### Running Locally

```bash
# Start dependencies
make dev-postgres-port-forward

# Run backend
cd apps/backend
npm run start:dev
```

### Running Tests

```bash
make dev-backend-test      # Unit tests
make dev-backend-test-e2e  # E2E tests
```

### Sync Secrets

```bash
make dev-infisical-sync-cli  # Sync from Infisical CLI
```
