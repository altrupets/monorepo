# 🎨 Micro-Frontends

AltruPets utiliza una arquitectura de **micro-frontends** donde cada aplicación web tiene su propio servidor Express.js independiente con Vue.js renderizado vía Inertia.js.

## Arquitectura de Micro-Frontends

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                    CLIENTES                                          │
│                                                                                      │
│   ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐            │
│   │   🖥️ Navegador    │     │   📱 Flutter App  │     │   🔌 API Clients  │            │
│   │   (Usuarios)      │     │   (Mobile)        │     │   (Integraciones) │            │
│   └────────┬─────────┘     └────────┬─────────┘     └────────┬─────────┘            │
└────────────┼─────────────────────────┼─────────────────────────┼─────────────────────┘
             │                         │                         │
             │ HTTP/HTTPS              │ GraphQL                 │ GraphQL
             │                         │                         │
┌────────────▼─────────────────────────▼─────────────────────────▼─────────────────────┐
│                              NGINX GATEWAY API                                        │
│                         (Gateway API + HTTPRoutes)                                    │
│                                                                                       │
│   ┌─────────────────────────────────────────────────────────────────────────────┐    │
│   │  HTTPRoute Routing Table                                                     │    │
│   │                                                                              │    │
│   │  /admin/*     ──► web-superusers-service:3002                               │    │
│   │  /b2g/*       ──► web-b2g-service:3003                                      │    │
│   │  /graphql     ──► backend-service:3001                                      │    │
│   │  /health      ──► backend-service:3001                                      │    │
│   └─────────────────────────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────────────────────────┘
                                        │
            ┌───────────────────────────┼───────────────────────────┐
            │                           │                           │
            ▼                           ▼                           ▼
┌───────────────────────┐  ┌───────────────────────┐  ┌───────────────────────┐
│  📋 CRUD SUPERUSERS   │  │  🏛️ B2G GOVERNMENT    │  │  ⚙️ BACKEND API       │
│                       │  │                       │  │                       │
│  ┌─────────────────┐  │  │  ┌─────────────────┐  │  │  ┌─────────────────┐  │
│  │   Express.js    │  │  │  │   Express.js    │  │  │  │   NestJS        │  │
│  │   (puerto 3002) │  │  │  │   (puerto 3003) │  │  │  │   (puerto 3001) │  │
│  └────────┬────────┘  │  │  └────────┬────────┘  │  │  └────────┬────────┘  │
│           │           │  │           │           │  │           │           │
│  ┌────────▼────────┐  │  │  ┌────────▼────────┐  │  │  ┌────────▼────────┐  │
│  │  Vue 3 + Inertia│  │  │  │  Vue 3 + Inertia│  │  │  │  GraphQL API    │  │
│  │  (desde CDN)    │  │  │  │  (desde CDN)    │  │  │  │  Apollo Server  │  │
│  └─────────────────┘  │  │  └─────────────────┘  │  │  └─────────────────┘  │
│                       │  │                       │  │                       │
│  🔐 Roles: SUPER_USER │  │  🔐 Roles: GOVERNMENT │  │  📊 Business Logic    │
│                       │  │         _ADMIN,       │  │                       │
│  📄 Páginas:          │  │         SUPER_USER    │  │  🔗 Conecta a:        │
│  • Dashboard          │  │                       │  │  • PostgreSQL        │
│  • Usuarios           │  │  📄 Páginas:          │  │  • Valkey (Cache)    │
│  • Reportes           │  │  • Dashboard          │  │                       │
│                       │  │  • Capturas           │  │  📦 Módulos:         │
│  🎨 Tema: Gris/Azul   │  │  • Estadísticas       │  │  • Auth              │
│                       │  │                       │  │  • Users             │
└───────────────────────┘  │  🎨 Tema: Azul/Cyan   │  │  • Pets              │
                           │                       │  │  • Rescues           │
                           └───────────────────────┘  │  • Adoptions         │
                                                      │  • Donations         │
                                                      │                       │
                                                      └───────────────────────┘
                                    │                              │
                                    │ HTTP (fetch)                 │
                                    │ /graphql, /login, /logout    │
                                    └──────────────────────────────┘
```

## Flujo de Request

```
┌─────────┐      ┌─────────────┐      ┌──────────────────┐      ┌─────────────┐
│ Usuario │      │   Gateway   │      │  Micro-Frontend  │      │   Backend   │
│         │      │   (NGINX)   │      │   (Express.js)   │      │  (NestJS)   │
└────┬────┘      └──────┬──────┘      └────────┬─────────┘      └──────┬──────┘
     │                  │                      │                       │
     │ GET /admin/login │                      │                       │
     │─────────────────►│                      │                       │
     │                  │ proxy_pass           │                       │
     │                  │─────────────────────►│                       │
     │                  │                      │ renderPage()          │
     │                  │                      │ (HTML + Vue CDN)      │
     │                  │                      │                       │
     │                  │◄─────────────────────│                       │
     │◄─────────────────│ HTML Response        │                       │
     │                  │                      │                       │
     │ POST /admin/login│                      │                       │
     │─────────────────►│                      │                       │
     │                  │─────────────────────►│                       │
     │                  │                      │ POST /login           │
     │                  │                      │──────────────────────►│
     │                  │                      │                       │
     │                  │                      │◄──────────────────────│
     │                  │                      │ Set-Cookie: jwt       │
     │                  │◄─────────────────────│                       │
     │◄─────────────────│ Redirect /admin      │                       │
     │ Set-Cookie: jwt  │                      │                       │
     │                  │                      │                       │
```

## Tecnologías por Micro-Frontend

### CRUD Superusers (`/admin/*`)

| Componente | Tecnología | Descripción |
|------------|------------|-------------|
| Servidor | Express.js | Servidor Node.js minimalista |
| Frontend | Vue 3 (CDN) | Sin build step, carga desde CDN |
| SPA | Inertia.js | Navegación sin recargar página |
| Estilos | CSS inline | Sin Tailwind, estilos básicos |
| Puerto | 3002 | Puerto interno del contenedor |
| Roles | `SUPER_USER` | Solo administradores |

### B2G Government (`/b2g/*`)

| Componente | Tecnología | Descripción |
|------------|------------|-------------|
| Servidor | Express.js | Servidor Node.js minimalista |
| Frontend | Vue 3 (CDN) | Sin build step, carga desde CDN |
| SPA | Inertia.js | Navegación sin recargar página |
| Estilos | CSS inline | Tema azul/cyan para gobierno |
| Puerto | 3003 | Puerto interno del contenedor |
| Roles | `GOVERNMENT_ADMIN`, `SUPER_USER` | Funcionarios gubernamentales |

## Ventajas de esta Arquitectura

### ✅ Separación de Responsabilidades

- Cada micro-frontend es **independiente**
- **Deploy independiente** por aplicación
- **Escalado independiente** según demanda

### ✅ Sin Build Step para Frontend

- Vue 3 cargado desde **CDN**
- **Sin Vite, Webpack o bundlers**
- **Desarrollo más rápido**
- **Dockerfiles simples** (solo compilan TypeScript del servidor)

### ✅ Seguridad

- Cada app maneja su propia **autenticación**
- **Roles específicos** por aplicación
- Backend como **única fuente de verdad**

### ✅ Developer Experience

- **Hot reload** con `tsx watch`
- **Un solo comando** para desarrollo local
- **Logs centralizados** por servicio

## Despliegue en Kubernetes

```yaml
Namespace: altrupets-dev
├── Deployment: web-superusers
│   ├── Image: localhost/altrupets-web-crud-superusers:dev
│   ├── Port: 3002
│   └── Env: BACKEND_URL=http://backend-service:3001
│
├── Deployment: web-b2g
│   ├── Image: localhost/altrupets-web-b2g:dev
│   ├── Port: 3003
│   └── Env: BACKEND_URL=http://backend-service:3001
│
├── Deployment: backend
│   ├── Image: localhost/altrupets-backend:dev
│   ├── Port: 3001
│   └── Env: DATABASE_URL, VALKEY_URL, JWT_SECRET
│
└── Deployment: dev-gateway-nginx
    ├── Image: nginx-gateway-fabric
    └── HTTPRoutes: /admin/*, /b2g/*, /graphql
```

## Comandos de Desarrollo

```bash
# Iniciar entorno local completo
make dev-minikube-deploy      # 1. Crear cluster
make dev-gateway-deploy       # 2. Deploy Gateway API
make dev-backend-build        # 3. Build backend
make dev-superusers-deploy    # 4. Deploy Admin
make dev-b2g-deploy           # 5. Deploy B2G
make dev-gateway-start        # 6. Port-forward

# URLs locales
http://localhost:3001/admin/login   # CRUD Superusers
http://localhost:3001/b2g/login     # B2G Government
http://localhost:3001/graphql       # GraphQL Playground
```
