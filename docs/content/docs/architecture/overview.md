# 🏗️ Arquitectura - Visión General

## Arquitectura Completa

```mermaid
flowchart TB
    subgraph Clients["Clients"]
        Browser["Browser"]
        Mobile["Flutter App"]
        API["API Clients"]
    end

    subgraph Gateway["Gateway Layer"]
        NGINX["NGINX Gateway API<br/>HTTPRoutes"]
    end

    subgraph Apps["Application Layer"]
        subgraph WebApps["Micro-Frontends"]
            Admin["CRUD Superusers<br/>Express + Vue<br/>:3002"]
            B2G["B2G Government<br/>Express + Vue<br/>:3003"]
        end
        Backend["Backend API<br/>NestJS + GraphQL<br/>:3001"]
    end

    subgraph Data["Data Layer"]
        Postgres[("PostgreSQL")]
        Valkey[("Valkey")]
        Storage[("S3/MinIO")]
    end

    subgraph Infra["Infrastructure"]
        K8s["Kubernetes<br/>(OVHCloud)"]
        TF["Terraform"]
        GH["GitHub Actions"]
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
    K8s --> Apps
    TF --> K8s
    GH --> TF
```

## Capas de la Arquitectura

### 1. Presentation Layer (Micro-Frontends)

Ver documentación detallada en [Micro-Frontends](micro-frontends.md).

| Aplicación | Tecnología | Puerto | Roles |
|------------|------------|--------|-------|
| CRUD Superusers | Express.js + Vue 3 + Inertia.js | 3002 | `SUPER_USER` |
| B2G Government | Express.js + Vue 3 + Inertia.js | 3003 | `GOVERNMENT_ADMIN`, `SUPER_USER` |
| Flutter Mobile | Flutter + Riverpod | - | Todos los usuarios |

### 2. Gateway Layer

| Componente | Tecnología | Función |
|------------|------------|---------|
| Ingress | NGINX Gateway API | Routing, SSL, Rate Limiting |
| HTTPRoutes | Gateway API | Path-based routing |

### 3. API Layer (Backend)

| Componente | Tecnología | Función |
|------------|------------|---------|
| Framework | NestJS | Dependency Injection, Modules |
| API | GraphQL (Apollo) | Query unificada, Subscriptions |
| ORM | Prisma | Database access |

### 4. Data Layer

| Componente | Tecnología | Función |
|------------|------------|---------|
| Database | PostgreSQL | Almacenamiento persistente |
| Cache | Valkey | Sesiones, Rate Limiting |
| Storage | S3/MinIO | Archivos, imágenes |

### 5. Infrastructure Layer

Ver documentación detallada en [Infrastructure](../deployment/infrastructure.md).

| Componente | Tecnología | Función |
|------------|------------|---------|
| Orchestration | Kubernetes | Container orchestration |
| IaC | Terraform/OpenTofu | Infrastructure as Code |
| CI/CD | GitHub Actions | Pipelines automatizados |
| GitOps | ArgoCD | Declarative deployments |

## Principios Arquitectónicos

### Clean Architecture (Flutter)

```mermaid
flowchart LR
    subgraph Core["Core"]
        Payments["payments/<br/>LATAM Package"]
        Network["network/<br/>HTTP Client"]
        Services["services/<br/>Global Services"]
    end

    subgraph Features["Features"]
        Auth["auth/"]
        Pets["pets/"]
        Rescues["rescues/"]
        Adoptions["adoptions/"]
        Donations["donations/"]
    end

    subgraph Shared["Shared"]
        Utils["Utils"]
        Widgets["Widgets"]
    end

    Core --> Features
    Shared --> Features
```

### Modular Monolith (Backend)

```mermaid
flowchart TB
    subgraph Backend["NestJS Backend"]
        subgraph Modules["Modules"]
            Auth["auth/"]
            Users["users/"]
            Pets["pets/"]
            Rescues["rescues/"]
            Adoptions["adoptions/"]
            Donations["donations/"]
        end

        subgraph Shared["Shared"]
            Guards["Guards"]
            Decorators["Decorators"]
            Interceptors["Interceptors"]
        end
    end

    Modules --> Shared
```

### Micro-Frontends (Web Apps)

```mermaid
flowchart TB
    subgraph WebApps["apps/web/"]
        subgraph CRUDSuperusers["crud-superusers/"]
            Server1["src/server/<br/>Express.js"]
            Pkg1["package.json<br/>Solo Express deps"]
        end

        subgraph B2G["b2g/"]
            Server2["src/server/<br/>Express.js"]
            Pkg2["package.json<br/>Solo Express deps"]
        end

        subgraph Shared["shared/"]
            Utils["Utilidades"]
        end
    end
```

## 🛡️ Seguridad

```mermaid
flowchart LR
    subgraph Security["Security Layer"]
        JWT["JWT Auth<br/>Refresh Tokens"]
        RBAC["RBAC<br/>Role-Based Access"]
        Rate["Rate Limiting<br/>Por Endpoint"]
        PCI["PCI Tokenization<br/>Para Pagos"]
        SSL["SSL/TLS<br/>Todos Endpoints"]
    end

    subgraph Roles["Roles"]
        Super["SUPER_USER<br/>Admin Total"]
        Gov["GOVERNMENT_ADMIN<br/>Portal Gobierno"]
        Rescuer["RESCUER<br/>Rescatista"]
        Adopter["ADOPTER<br/>Adoptante"]
    end

    Security --> Roles
```

## Próximos Pasos

- [Micro-Frontends](micro-frontends.md) - Detalle de cada web app
- [Tecnologías](technologies.md) - Stack tecnológico completo
- [Data Flow](data-flow.md) - Flujo de datos entre servicios
