# 🏗️ Arquitectura - Visión General

## Arquitectura Completa

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                    CLIENTES                                          │
│                                                                                      │
│   ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐            │
│   │   🖥️ Navegador    │     │   📱 Flutter App  │     │   🔌 API Clients  │            │
│   │   (Web Users)     │     │   (Mobile)        │     │   (Integraciones) │            │
│   └────────┬─────────┘     └────────┬─────────┘     └────────┬─────────┘            │
└────────────┼─────────────────────────┼─────────────────────────┼─────────────────────┘
             │                         │                         │
             │ HTTP/HTTPS              │ GraphQL                 │ GraphQL
             ▼                         ▼                         ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              GATEWAY LAYER                                           │
│                         NGINX Gateway API (Kubernetes)                               │
│                                                                                      │
│   HTTPRoutes:                                                                        │
│   • /admin/*     ──► web-superusers (Express + Vue)                                 │
│   • /b2g/*       ──► web-b2g (Express + Vue)                                        │
│   • /graphql     ──► backend (NestJS + Apollo)                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                        │
            ┌───────────────────────────┼───────────────────────────┐
            │                           │                           │
            ▼                           ▼                           ▼
┌───────────────────────┐  ┌───────────────────────┐  ┌───────────────────────┐
│  📋 CRUD SUPERUSERS   │  │  🏛️ B2G GOVERNMENT    │  │  ⚙️ BACKEND API       │
│                       │  │                       │  │                       │
│  Express.js + Vue 3   │  │  Express.js + Vue 3   │  │  NestJS + GraphQL     │
│  (Inertia.js)         │  │  (Inertia.js)         │  │  (Apollo Server)      │
│                       │  │                       │  │                       │
│  🔐 SUPER_USER        │  │  🔐 GOVERNMENT_ADMIN  │  │  📊 Business Logic    │
│                       │  │     SUPER_USER        │  │                       │
│  Puerto: 3002         │  │  Puerto: 3003         │  │  Puerto: 3001         │
└───────────────────────┘  └───────────────────────┘  └───────────┬───────────┘
                                                                  │
                                           ┌──────────────────────┼──────────────────────┐
                                           │                      │                      │
                                           ▼                      ▼                      ▼
                                   ┌─────────────┐         ┌─────────────┐        ┌─────────────┐
                                   │ PostgreSQL  │         │   Valkey    │        │   Storage   │
                                   │  (Primary)  │         │   (Cache)   │        │   (S3/MinIO)│
                                   └─────────────┘         └─────────────┘        └─────────────┘
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

### 1. Clean Architecture (Flutter)

```
lib/
├── core/                    # Compartido entre features
│   ├── payments/        # Paquete de pagos LATAM
│   ├── network/          # Cliente HTTP
│   └── services/         # Servicios globales
├── features/             # Features del dominio
│   ├── auth/
│   ├── pets/
│   ├── rescues/
│   ├── adoptions/
│   └── donations/
└── shared/               # Utilidades comunes
```

### 2. Modular Monolith (Backend)

```
backend/
├── modules/
│   ├── auth/
│   ├── users/
│   ├── pets/
│   ├── rescues/
│   ├── adoptions/
│   └── donations/
└── shared/
```

### 3. Micro-Frontends (Web Apps)

```
apps/web/
├── crud-superusers/         # Admin Panel
│   ├── src/server/          # Express.js server
│   └── package.json         # Solo Express dependencies
│
├── b2g/                     # Government Portal
│   ├── src/server/          # Express.js server
│   └── package.json         # Solo Express dependencies
│
└── shared/                  # Shared utilities (futuro)
```

## 🛡️ Seguridad

- **JWT Authentication** con refresh tokens
- **RBAC** (Role-Based Access Control)
- **Rate Limiting** por endpoint
- **Tokenización PCI** para pagos
- **SSL/TLS** en todos los endpoints

## Próximos Pasos

- [Micro-Frontends](micro-frontends.md) - Detalle de cada web app
- [Tecnologías](technologies.md) - Stack tecnológico completo
- [Data Flow](data-flow.md) - Flujo de datos entre servicios
