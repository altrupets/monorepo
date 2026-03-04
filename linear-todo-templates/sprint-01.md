# Sprint 1 (v0.3.0): Fundación + Victorias Rápidas

> **Tipo:** `Feature`
> **Tamaño:** `L`
> **Estrategia:** `Team`
> **Componentes:** `Backend`, `Database`, `Frontend`, `Security`
> **Impacto:** `🔥 Critical Path`, `💰 Revenue`
> **Banderas:** `📦 Epic`
> **Branch:** `feat/sprint-1-foundation`
> **Fuente de Spec:** `specs/altrupets/tasks.md` (sección Sprint 1)
> **Estado:** `Partially Done`
> **Dependencias:** `Ninguna`
> **Proyecto Linear:** `Backend` + `Mobile App` + `Infrastructure & DevOps`

---

## 👤 CAPA HUMANA

### Historia de Usuario

Como **equipo de desarrollo**, quiero **las entidades fundacionales (Animal, CasaCuna, VetProfile), autenticación sólida y PostGIS** para que **todas las funcionalidades generadoras de ingresos del Sprint 2+ puedan construirse sobre una base estable**.

### Contexto / Por Qué

El Sprint 1 es el sprint más crítico porque crea la base de datos fundacional (entidad Animal, gestión de Casa Cuna, perfiles de veterinarios) y fortalece la autenticación — dos prerrequisitos que bloquean $9,372/mes de potencial de ingresos. Sin la entidad Animal, no hay subsidios, adopciones ni donaciones. Sin una autenticación sólida, cada interacción móvil es poco confiable.

El framework SRD identificó que cada persona (P01-P10) se encuentra actualmente en nivel "BROKEN". El Sprint 1 aborda las causas raíz estableciendo el modelo de datos del que dependen todos los recorridos futuros. Las Victorias Rápidas (QW-1 a QW-5) parchean brechas de seguridad inmediatas que existen en el código listo para producción.

La habilitación de PostGIS (Track D) es específicamente crítica para la ruta de ingresos B2G — los municipios necesitan enrutamiento basado en jurisdicción para solicitudes de subsidio y reportes de abuso, lo cual requiere consultas espaciales.

### Analogía

El Sprint 1 es como construir los cimientos y la plomería de una casa antes de poder amueblar cualquier habitación. La entidad Animal es la pared de carga central — subsidios, adopciones, rescates y donaciones se conectan a ella. El fortalecimiento de la autenticación es el cableado eléctrico — invisible pero todo falla sin él.

### Referencia UX / Visual

```
                    ┌─────────────────┐
                    │   Animal Entity  │
                    │  (Nodo Central)  │
                    └───────┬─────────┘
                ┌───────────┼───────────┐
                │           │           │
        ┌───────▼──┐  ┌─────▼────┐  ┌──▼────────┐
        │CasaCuna  │  │Subsidio  │  │Adopción   │
        │(Sprint 1)│  │(Sprint 2)│  │(Sprint 3) │
        └──────────┘  └──────────┘  └───────────┘
```

### Errores Conocidos y Advertencias

1. **Conflicto del sistema dual de autenticación (5c):** `AuthService` (sealed class) y `AuthNotifier`/`AuthRepository` (Freezed) coexisten con diferentes claves de almacenamiento (`auth_access_token` vs potencialmente `auth_token`). La consolidación debe ocurrir ANTES de agregar lógica de refresh de token.
2. **PostGIS en Minikube:** PostgreSQL necesita la extensión PostGIS instalada. El módulo actual de Terraform podría no incluirla — verificar el Helm chart o Dockerfile de la imagen de Postgres.
3. **Orden de migraciones:** `Animal` depende de FKs de `User` y `Organization`. `FosterHome` depende de `User` y `Organization`. `NeedsListItem` depende de `FosterHome`. Las migraciones deben ejecutarse en este orden.
4. **Dependencia de Redis para QW-5:** El paquete `cache-manager-redis` (o `cache-manager-redis-yet`) debe agregarse al `package.json`. El CacheModule actual advierte explícitamente pero cae a in-memory.
5. **Migración de coordenadas (D1):** Convertir columnas `decimal(10,7)` a `geography(Point, 4326)` es una migración de datos que requiere preservar los datos existentes. La migración debe manejar tanto User.latitude/longitude como CaptureRequest.latitude/longitude.

---

## 🤖 CAPA AGENTE

### Objetivo

Establecer el esquema fundacional de base de datos (entidades Animal, FosterHome, VetProfile, Jurisdiction), parchear 5 victorias rápidas de seguridad, fortalecer la autenticación móvil y habilitar PostGIS para consultas espaciales — desbloqueando todas las funcionalidades de ingresos del Sprint 2+.

### Auditoría del Estado Actual

#### Ya Existe

- `apps/backend/src/auth/auth.service.ts` — AuthService con método `refreshToken()` (completo, línea 179-224)
- `apps/backend/src/captures/captures.resolver.ts` — Resolver existe pero falta auth guard en la mutación
- `apps/backend/src/app.module.ts` — CacheModule configurado con detección de Redis URL pero fallback a in-memory
- `apps/backend/src/auth/auth.module.ts` — Módulo JWT con secret fallback hardcodeado
- `apps/mobile/lib/features/profile/presentation/pages/foster_homes_management_page.dart` — Shell de UI (hardcodeado, sin integración con backend)
- `apps/mobile/lib/core/services/auth_service.dart` — Sistema de autenticación con sealed class (parcial)
- `apps/mobile/lib/features/auth/presentation/providers/auth_provider.dart` — Sistema de autenticación con Freezed (parcial)
- `apps/mobile/lib/core/network/interceptors/auth_interceptor.dart` — Solo detección de 401 (sin recuperación)
- `apps/backend/src/auth/auth.service.spec.ts` — Cobertura mínima de tests

#### Necesita Creación

- `apps/backend/src/animals/` — Módulo completo (entity, resolver, service, module)
- `apps/backend/src/foster-homes/` — Módulo completo
- `apps/backend/src/vet-profiles/` — Módulo completo
- `apps/backend/src/jurisdictions/` — Módulo completo con PostGIS
- `apps/backend/src/needs-list/` — Módulo completo
- `apps/backend/src/migrations/XXXXXX-CreateAnimalEntity.ts` — Migración
- `apps/backend/src/migrations/XXXXXX-CreateFosterHomeEntity.ts` — Migración
- `apps/backend/src/migrations/XXXXXX-CreateVetProfileEntity.ts` — Migración
- `apps/backend/src/migrations/XXXXXX-CreateJurisdictionEntity.ts` — Migración
- `apps/backend/src/migrations/XXXXXX-CreateNeedsListItemEntity.ts` — Migración
- `apps/backend/src/migrations/XXXXXX-AddReportedByIdToCaptureRequests.ts` — Migración
- `apps/backend/src/migrations/XXXXXX-EnablePostGIS.ts` — Migración
- `apps/backend/src/migrations/XXXXXX-MigrateCoordinatesToGeography.ts` — Migración
- `apps/mobile/lib/features/animals/` — Carpeta de feature
- `apps/mobile/lib/features/foster_homes/` — Carpeta de feature

#### Necesita Modificación

- `apps/backend/src/captures/captures.resolver.ts` — Agregar `@UseGuards(JwtAuthGuard)` a `createCaptureRequest`
- `apps/backend/src/captures/entities/capture-request.entity.ts` — Agregar FK `reportedById` + `@ManyToOne` a User
- `apps/backend/src/auth/auth.resolver.ts` — Agregar mutación `refreshToken`
- `apps/backend/src/auth/auth.module.ts` — Eliminar fallback de JWT secret hardcodeado
- `apps/backend/src/app.module.ts` — Conectar adaptador Redis de caché, registrar nuevos módulos
- `apps/backend/package.json` — Agregar `cache-manager-redis-yet`, `ioredis`, dependencias de PostGIS
- `apps/mobile/lib/core/services/auth_service.dart` — Agregar `refreshToken()` público, temporizador proactivo
- `apps/mobile/lib/core/network/interceptors/auth_interceptor.dart` — Implementar reintento en 401 + manejo de 403
- `apps/mobile/lib/features/profile/presentation/pages/foster_homes_management_page.dart` — Conectar al backend

### Archivos de Contexto

- `apps/backend/src/app.module.ts` — Registro de módulos, configuración de CacheModule
- `apps/backend/src/auth/auth.module.ts` — Configuración JWT con secret hardcodeado
- `apps/backend/src/auth/auth.service.ts` — Método refreshToken() existente
- `apps/backend/src/auth/auth.resolver.ts` — Mutación refreshToken faltante
- `apps/backend/src/captures/captures.resolver.ts` — Auth guard faltante
- `apps/backend/src/captures/entities/capture-request.entity.ts` — reportedById faltante
- `apps/backend/src/users/entities/user.entity.ts` — Patrón de entidad User + campos lat/lon
- `apps/backend/src/organizations/entities/organization.entity.ts` — Patrón de entidad Org
- `apps/backend/package.json` — Dependencias actuales
- `apps/mobile/lib/core/services/auth_service.dart` — Autenticación con sealed class
- `apps/mobile/lib/features/auth/presentation/providers/auth_provider.dart` — Autenticación con Freezed
- `apps/mobile/lib/core/network/interceptors/auth_interceptor.dart` — Manejo de 401/403
- `apps/mobile/lib/features/profile/presentation/pages/foster_homes_management_page.dart` — Shell de UI
- `Makefile` — Convenciones de nomenclatura y targets existentes

### Criterios de Aceptación

- [ ] QW-1: La mutación `createCaptureRequest` requiere autenticación JWT
- [ ] QW-2: La tabla `capture_requests` tiene FK `reportedById` hacia `users`
- [ ] QW-3: Mutación `refreshToken` expuesta en el esquema GraphQL
- [ ] QW-4: Sin fallback de JWT secret hardcodeado en auth.module.ts
- [ ] QW-5: Adaptador Redis conectado en CacheModule cuando REDIS_URL está configurado
- [ ] A1: Tabla `animals` creada con todas las columnas especificadas + coordenadas preparadas para PostGIS
- [ ] A2: Tabla `foster_homes` creada con todas las columnas especificadas
- [ ] A3: Resolvers CRUD de GraphQL para foster homes + inventario de animales funcionando
- [ ] A3: Página móvil foster_homes_management_page conectada al backend
- [ ] A4: Tabla `needs_list_items` creada + resolvers CRUD
- [ ] 5a: AuthService móvil tiene `refreshToken()` público con temporizador proactivo
- [ ] 5b: AuthInterceptor reintenta en 401 con nuevo token, muestra error en 403
- [ ] 5c: Sistema de autenticación único y unificado (basado en Riverpod)
- [ ] 5f: Cobertura de tests de autenticación ≥90% para AuthService
- [ ] C1: Tabla `vet_profiles` creada + formulario de registro
- [ ] D1: PostGIS habilitado, coordenadas migradas a tipo geography con índice GiST
- [ ] D2: Tabla `jurisdictions` con límites de polígono + consulta `getJurisdictionByLocation`

### Restricciones Técnicas

- Seguir el patrón existente de entidades TypeORM (ver `user.entity.ts`, `capture-request.entity.ts`)
- Seguir el patrón de módulos NestJS: entity → service → resolver → module
- API GraphQL-first (sin REST para entidades nuevas, REST solo para web/Inertia)
- Móvil: Riverpod para gestión de estado, estructura de carpetas feature-first
- Los targets del Makefile usan la convención `env-recurso-verbo`
- K8s: Patrón base/overlays de Kustomize
- Secrets: Usar Infisical (nunca hardcodear secrets en YAML)
- PostGIS: Usar tipo `geography(Point, 4326)`, no decimales raw de lat/lon
- Migraciones: Archivos de migración TypeORM con timestamps

### Comandos de Verificación

```bash
# Pre-vuelo (verificación de prerrequisitos)
kubectl get pods -n altrupets-dev | grep postgres
cd apps/backend && npm run build

# Build/Aplicar
cd apps/backend && npm run migration:run
cd apps/backend && npm run build && npm test

# Tests
cd apps/backend && npm run test -- --coverage
cd apps/mobile && flutter test

# Lint
cd apps/backend && npm run lint
cd apps/mobile && flutter analyze

# Verificación K8s
kubectl get pods -n altrupets-dev
kubectl logs -n altrupets-dev -l app=backend --tail=20

# Verificación de salud
curl -s http://localhost:3001/health | jq
curl -s http://localhost:3001/graphql -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name } } }"}' | jq '.data.__schema.types[].name' | grep -i animal
```

### Estrategia del Agente

**Modo:** `Team`

**Rol líder:** Coordinador — asigna tareas, revisa, sintetiza. Sin ediciones directas de archivos.

**Compañeros de equipo:**
- Compañero 1: **Backend Victorias Rápidas** → responsable de QW-1 a QW-5 (`apps/backend/src/captures/`, `apps/backend/src/auth/`, `apps/backend/src/app.module.ts`)
- Compañero 2: **Backend Entidades** → responsable de A1-A4, C1, D1-D2 (módulos nuevos: `animals/`, `foster-homes/`, `vet-profiles/`, `jurisdictions/`, `needs-list/`, migraciones)
- Compañero 3: **Autenticación Móvil + UI** → responsable de 5a-5c, 5f, UI móvil de A3 (`apps/mobile/lib/core/`, `apps/mobile/lib/features/auth/`, `apps/mobile/lib/features/profile/`)

**Modo de visualización:** `tab`
**Aprobación de plan requerida:** sí
**Propiedad de archivos:** Explícita — sin ediciones de archivos superpuestas entre compañeros de equipo

### Notificación de Slack

Al terminar, enviar un resumen al usuario vía Slack MCP con:
- Qué se completó (cantidad de QW, cantidad de entidades, correcciones de autenticación)
- Archivos modificados
- Cualquier problema o decisión necesaria

---

## Plan de Implementación

### Verificaciones Pre-vuelo

```bash
# Verificar que el backend compila
cd apps/backend && npm run build

# Verificar que la base de datos es accesible
kubectl port-forward -n altrupets-dev svc/postgres-dev-service 5432:5432 &
sleep 2 && psql -h localhost -U postgres -d altrupets -c "SELECT 1"

# Verificar que el móvil compila
cd apps/mobile && flutter analyze
```

### Acciones Paso a Paso

#### Victorias Rápidas (Compañero 1, ~4 horas)

1. **QW-1: Agregar auth guard a createCaptureRequest**
   - **Herramienta:** Edit
   - **Objetivo:** `apps/backend/src/captures/captures.resolver.ts`
   - **Descripción:** Agregar decorador `@UseGuards(JwtAuthGuard)` sobre `@Mutation(() => CaptureRequest)` en `createCaptureRequest`

2. **QW-2: Agregar FK reportedById**
   - **Herramienta:** Write + Edit
   - **Objetivo:** `apps/backend/src/captures/entities/capture-request.entity.ts`, nueva migración
   - **Descripción:** Agregar relación `@ManyToOne(() => User)` y columna `reportedById`. Crear migración.

3. **QW-3: Exponer mutación refreshToken**
   - **Herramienta:** Edit
   - **Objetivo:** `apps/backend/src/auth/auth.resolver.ts`
   - **Descripción:** Agregar `@Mutation(() => AuthResponse) refreshToken(@Args('refreshToken') refreshToken: string)` que llame a `authService.refreshToken()`

4. **QW-4: Eliminar fallback de JWT secret**
   - **Herramienta:** Edit
   - **Objetivo:** `apps/backend/src/auth/auth.module.ts`
   - **Descripción:** Eliminar fallback `'super-secret-altrupets-key-2026'` de `configService.get()`. Lanzar error si JWT_SECRET no está configurado.

5. **QW-5: Conectar adaptador Redis de caché**
   - **Herramienta:** Bash + Edit
   - **Objetivo:** `apps/backend/package.json`, `apps/backend/src/app.module.ts`
   - **Descripción:** Instalar `cache-manager-redis-yet` + `ioredis`. Configurar Redis store en CacheModule cuando REDIS_URL esté disponible.

#### Track A: Animal + Casa Cuna (Compañero 2, ~2 días)

6. **A1: Crear entidad Animal + módulo + migración**
   - **Herramienta:** Write
   - **Objetivo:** `apps/backend/src/animals/entities/animal.entity.ts`, `animals.module.ts`, `animals.service.ts`, `animals.resolver.ts`, migración
   - **Descripción:** Módulo CRUD completo con entidad que contiene: id, species, breed, name, age_estimate, sex, weight, photos (JSON), description, medical_notes, behavior_notes, adoptability_score, status (enum), fostered_by_id FK, organization_id FK, lat/lon como decimal (preparado para PostGIS)

7. **A2: Crear entidad FosterHome + módulo + migración**
   - **Herramienta:** Write
   - **Objetivo:** `apps/backend/src/foster-homes/` (módulo completo)
   - **Descripción:** Entidad con: id, name, location, capacity, species_accepted, photos, description, is_active, owner_id FK, organization_id FK

8. **A3: Resolvers CRUD para Casa Cuna + inventario de animales**
   - **Herramienta:** Edit + Write
   - **Objetivo:** `apps/backend/src/foster-homes/foster-homes.resolver.ts`
   - **Descripción:** Mutaciones/consultas GraphQL: createFosterHome, updateFosterHome, addAnimal, updateAnimal, removeAnimal, myFosterHomes, fosterHomeAnimals, fosterHomeCapacity

9. **A4: Crear entidad NeedsListItem + resolvers**
   - **Herramienta:** Write
   - **Objetivo:** `apps/backend/src/needs-list/` (módulo completo)
   - **Descripción:** Entidad con: id, foster_home_id FK, category enum, description, quantity, urgency enum, is_fulfilled

#### Track B: Fortalecimiento de Autenticación (Compañero 3, ~2 días)

10. **5c: Unificar sistemas de autenticación (HACER PRIMERO)**
    - **Herramienta:** Edit + Write
    - **Objetivo:** `apps/mobile/lib/core/services/auth_service.dart`, `apps/mobile/lib/features/auth/`
    - **Descripción:** Consolidar en un sistema único basado en Riverpod. Crear `authServiceProvider`. Mover `currentUserProvider` al feature de autenticación.

11. **5a: Implementar refresh de token**
    - **Herramienta:** Edit
    - **Objetivo:** `apps/mobile/lib/core/services/auth_service.dart`
    - **Descripción:** Agregar método público `refreshToken()`, temporizador proactivo (5 min antes de expiración), reintento con backoff (1s, 2s, 4s, 3 máx), redirección a login en caso de fallo

12. **5b: Implementar manejo de 401/403**
    - **Herramienta:** Edit
    - **Objetivo:** `apps/mobile/lib/core/network/interceptors/auth_interceptor.dart`
    - **Descripción:** En 401: llamar refreshToken, reintentar solicitud original. En 403: mostrar "Acceso denegado", no reintentar.

13. **5f: Tests de autenticación**
    - **Herramienta:** Write
    - **Objetivo:** Tests en backend y móvil
    - **Descripción:** Tests unitarios para AuthService, AuthInterceptor, GraphQLClientService. Test de integración para flujo completo. Objetivo ≥90% de cobertura.

#### Track C: Perfil Veterinario (Compañero 2, ~1 día)

14. **C1: Crear entidad VetProfile + módulo**
    - **Herramienta:** Write
    - **Objetivo:** `apps/backend/src/vet-profiles/` (módulo completo)
    - **Descripción:** Entidad con: license_number, specialties, clinic_name, clinic_photos, clinic_hours (JSON), location, services_offered, pricing_tier enum

#### Track D: PostGIS (Compañero 2, ~1 día)

15. **D1: Habilitar PostGIS + migrar coordenadas**
    - **Herramienta:** Write
    - **Objetivo:** Archivos de migración
    - **Descripción:** Habilitar extensión PostGIS, migrar lat/lon de User y CaptureRequest a geography(Point, 4326), crear índices GiST

16. **D2: Crear entidad Jurisdictions + consulta**
    - **Herramienta:** Write
    - **Objetivo:** `apps/backend/src/jurisdictions/` (módulo completo)
    - **Descripción:** Entidad con geometría de polígono como límite. Consulta: getJurisdictionByLocation(lat, lon)

### Verificación Post-vuelo

```bash
# Verificar que todas las migraciones se ejecutaron
cd apps/backend && npm run migration:show

# Verificar que el esquema GraphQL tiene los nuevos tipos
curl -s http://localhost:3001/graphql -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name } } }"}' | jq '.data.__schema.types[].name' | sort

# Verificar que los tests de autenticación pasan
cd apps/backend && npm run test -- --testPathPattern=auth --coverage

# Verificar que el móvil compila
cd apps/mobile && flutter build apk --debug 2>&1 | tail -5

# Verificar que no hay secrets hardcodeados
grep -r "super-secret" apps/backend/src/ && echo "FALLO: secret aún presente" || echo "PASA: sin secret hardcodeado"
```

---

## 🔀 Recomendación de Paralelización

**Mecanismo recomendado:** `Agent Teams`

**Razonamiento:**

El Sprint 1 tiene 4 tracks paralelos (A, B, C, D) más Victorias Rápidas que son mayormente independientes. El Track A (entidades) y el Track B (autenticación) tocan archivos completamente diferentes. El Track C (perfil veterinario) sigue el mismo patrón que el Track A pero es independiente. El Track D (PostGIS) es a nivel de base de datos e independiente.

- **Subagents** — No suficiente. Demasiados archivos para crear en múltiples dominios.
- **Git Worktrees** — No necesario. Los cambios no generan conflictos entre tracks.
- **Agent Teams** — Mejor opción. 3 compañeros de equipo trabajando en paralelo:
  - Backend Victorias Rápidas + Seguridad (QW-1..5)
  - Backend Entidades + PostGIS (A1-A4, C1, D1-D2)
  - Autenticación Móvil + UI (5a-5c, 5f, A3 móvil)
- **None (Solo)** — Demasiado grande para un solo agente.

**Mapeo Tamaño → Mecanismo:** L → Agent Teams (3 compañeros de equipo)

**Estimación de costo:** ~3x costo base de tokens

---

## Recomendaciones de Issues en Linear

### Issue 1: Victorias Rápidas (QW-1 a QW-5)
**Título:** Corregir 5 victorias rápidas de seguridad (auth guard, JWT secret, Redis, reportedById, refreshToken)
**Proyecto:** Backend
**Prioridad:** Urgent
**Etiquetas:** Bug, S, Solo, Backend, Security, 🔥 Critical Path, ⚡ Quick Win

### Issue 2: Entidad Animal + Casa Cuna
**Título:** Crear entidad Animal, gestión de Casa Cuna y lista de necesidades
**Proyecto:** Backend
**Prioridad:** Urgent
**Etiquetas:** Feature, M, Solo, Backend, Database, 🔥 Critical Path, 💰 Revenue

### Issue 3: Fortalecimiento de Autenticación
**Título:** Unificar sistemas de autenticación, implementar refresh de token, manejo de 401/403 y tests
**Proyecto:** Mobile App
**Prioridad:** High
**Etiquetas:** Improvement, M, Solo, Frontend, Security, 🔥 Critical Path

### Issue 4: Registro de Perfil Veterinario
**Título:** Crear entidad VetProfile con registro de clínica
**Proyecto:** Backend
**Prioridad:** High
**Etiquetas:** Feature, S, Solo, Backend, Database, 💰 Revenue

### Issue 5: PostGIS + Jurisdicciones
**Título:** Habilitar PostGIS, migrar coordenadas, crear tabla de jurisdicciones
**Proyecto:** Infrastructure & DevOps
**Prioridad:** High
**Etiquetas:** Feature, M, Solo, Database, Infra, 🔥 Critical Path

---

## Resumen de Archivos Modificados

| Acción | Ruta | Líneas Cambiadas (est.) |
|--------|------|---------------------|
| Modificar | `apps/backend/src/captures/captures.resolver.ts` | ~5 |
| Modificar | `apps/backend/src/captures/entities/capture-request.entity.ts` | ~15 |
| Modificar | `apps/backend/src/auth/auth.resolver.ts` | ~20 |
| Modificar | `apps/backend/src/auth/auth.module.ts` | ~10 |
| Modificar | `apps/backend/src/app.module.ts` | ~30 |
| Modificar | `apps/backend/package.json` | ~5 |
| Crear | `apps/backend/src/animals/` (4 archivos) | ~300 |
| Crear | `apps/backend/src/foster-homes/` (4 archivos) | ~250 |
| Crear | `apps/backend/src/vet-profiles/` (4 archivos) | ~200 |
| Crear | `apps/backend/src/jurisdictions/` (4 archivos) | ~200 |
| Crear | `apps/backend/src/needs-list/` (4 archivos) | ~150 |
| Crear | `apps/backend/src/migrations/` (8 archivos) | ~400 |
| Modificar | `apps/mobile/lib/core/services/auth_service.dart` | ~100 |
| Modificar | `apps/mobile/lib/core/network/interceptors/auth_interceptor.dart` | ~50 |
| Modificar | `apps/mobile/lib/features/auth/` (múltiples archivos) | ~200 |
| Modificar | `apps/mobile/lib/features/profile/.../foster_homes_management_page.dart` | ~100 |
| Crear | Tests (backend + móvil) | ~500 |

---

### Comentarios Adicionales de Síntesis

#### Validación Lógica MECE

* **Mutuamente Excluyente:** Los 4 tracks (A-D) y las Victorias Rápidas están claramente separados. El Track A crea entidades, el Track B corrige autenticación, el Track C crea perfiles veterinarios, el Track D habilita consultas espaciales. No se detectaron conflictos de archivos. El único punto de contacto compartido es `app.module.ts` que necesita registrar todos los módulos nuevos — esto debe hacerlo un solo compañero de equipo (Backend Entidades) al final.

* **Colectivamente Exhaustivo:** Todas las correcciones de nivel T0 del SRD están cubiertas: T0-1 (Animal), T0-2 (Casa Cuna), T0-3 (Autenticación), T0-8 (Perfil Veterinario), T0-9 (PostGIS), más QW-1..5. El sprint cubre el 100% de los requisitos del Sprint 1 de tasks.md.

#### Síntesis Ejecutiva (Pirámide de Minto)

1. **Liderar con la Respuesta:** El Sprint 1 entrega el esquema fundacional de base de datos y el fortalecimiento de autenticación que desbloquea $9,372/mes en potencial de ingresos a través de las 10 personas.

2. **Argumentos de Soporte:**
   - **Fundación de Base de Datos (Tracks A, C):** 5 nuevas entidades (Animal, FosterHome, NeedsListItem, VetProfile, Jurisdiction) crean el modelo de datos para subsidios, adopciones y donaciones
   - **Fortalecimiento de Seguridad (QW + Track B):** 5 victorias rápidas parchean vulnerabilidades inmediatas; la unificación de autenticación previene bugs de gestión de sesiones
   - **Inteligencia Espacial (Track D):** PostGIS habilita enrutamiento basado en jurisdicción, crítico para contratos B2G municipales

3. **Datos y Evidencia:** 8 archivos de migración, 5 nuevos módulos NestJS (~20 archivos), 3 actualizaciones de features móviles, estimado de 2,500 líneas de código nuevo en backend y móvil.

#### Revisión de Eficiencia Pareto 80/20

* **80% de valor con 20% de esfuerzo:** Las Victorias Rápidas (QW-1..5) entregan un valor de seguridad desproporcionado en ~4 horas de trabajo. La entidad Animal (A1) + Casa Cuna (A2) desbloquean todo el pipeline de subsidios y adopciones.
* **Potencial sobreingeniería:** Los límites de polígono de PostGIS para jurisdicciones (D2) podrían simplificarse inicialmente a un enfoque de punto-en-bounding-box con una tabla de búsqueda, en lugar de geometrías complejas de polígonos. Sin embargo, los límites de polígono son la solución correcta a largo plazo para los 82 cantones de Costa Rica.
* **Alternativa más simple para desarrollo:** VetProfile (C1) podría comenzar solo con los campos esenciales (license_number, specialties, location) y diferir clinic_hours, pricing_tier y photos al Sprint 4 cuando se construya la gestión de pacientes veterinarios.

#### Pensamiento de Segundo Orden y Evaluación de Riesgos

* **Escalabilidad:** La migración PostGIS es compatible hacia adelante con OVHCloud managed K8s (PostgreSQL en bases de datos gestionadas soporta PostGIS). El patrón de entidades sigue convenciones TypeORM que escalan a 100K+ filas sin problemas.
* **Efectos Aguas Abajo:** Cada funcionalidad del Sprint 2-8 depende de las entidades del Sprint 1. Un retraso aquí se propaga en cascada a todos los cronogramas de ingresos. La unificación de autenticación (5c) es particularmente sensible — si se hace mal, rompe el login para todos los usuarios.
* **Mantenimiento Futuro:** El sistema dual de autenticación (5c) es el mayor riesgo de mantenimiento. Si no se consolida ahora, cada nueva funcionalidad de autenticación necesitará implementarse dos veces. La migración de coordenadas PostGIS (D1) es un costo único sin deuda futura.
