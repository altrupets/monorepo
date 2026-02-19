# Arquitectura - Visión General

## Arquitectura Completa

```mermaid
flowchart TB
    subgraph Clients
        Browser[Browser]
        Mobile[Flutter App]
        API[API Clients]
    end

    subgraph Gateway
        NGINX[NGINX Gateway API]
    end

    subgraph Apps
        Admin[CRUD Superusers<br/>Express+Vue]
        B2G[B2G Government<br/>Express+Vue]
        Backend[Backend API<br/>NestJS+GraphQL]
    end

    subgraph Data
        Postgres[(PostgreSQL)]
        Valkey[(Valkey)]
        Storage[(S3/MinIO)]
    end

    Browser --> NGINX
    Mobile --> NGINX
    API --> NGINX
    NGINX --> Admin
    NGINX --> B2G
    NGINX --> Backend
    Admin -.-> Backend
    B2G -.-> Backend
    Backend --> Postgres
    Backend --> Valkey
    Backend --> Storage
```

## Capas de la Arquitectura

### 1. Presentation Layer

| Aplicación | Tecnología | Puerto | Roles |
|------------|------------|--------|-------|
| CRUD Superusers | Express+Vue+Inertia | 3002 | `SUPER_USER` |
| B2G Government | Express+Vue+Inertia | 3003 | `GOVERNMENT_ADMIN` |
| Flutter Mobile | Flutter+Riverpod | - | Todos |

### 2. Gateway Layer

| Componente | Tecnología |
|------------|------------|
| Ingress | NGINX Gateway API |
| HTTPRoutes | Gateway API |

### 3. API Layer

| Componente | Tecnología |
|------------|------------|
| Framework | NestJS |
| API | GraphQL |
| ORM | Prisma |

### 4. Data Layer

| Componente | Tecnología |
|------------|------------|
| Database | PostgreSQL |
| Cache | Valkey |
| Storage | S3/MinIO |

### 5. Infrastructure Layer

| Componente | Tecnología |
|------------|------------|
| Orchestration | Kubernetes |
| IaC | Terraform |
| CI/CD | GitHub Actions |
| GitOps | ArgoCD |

## Principios Arquitectónicos

### Clean Architecture

```mermaid
flowchart LR
    subgraph Core
        Payments[payments]
        Network[network]
        Services[services]
    end

    subgraph Features
        Auth[auth]
        Pets[pets]
        Rescues[rescues]
    end

    Core --> Features
```

### Backend Modules

```mermaid
flowchart TB
    Auth --> Shared
    Users --> Shared
    Pets --> Shared
    Rescues --> Shared

    subgraph Shared
        Guards[Guards]
        Decorators[Decorators]
    end
```

## Seguridad

```mermaid
flowchart LR
    subgraph Security
        JWT[JWT Auth]
        RBAC[RBAC]
        Rate[Rate Limiting]
        SSL[SSL/TLS]
    end

    subgraph Roles
        Super[SUPER_USER]
        Gov[GOVERNMENT_ADMIN]
        Rescuer[RESCUER]
    end

    Security --> Roles
```
