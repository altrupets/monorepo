# Sprint 2 (v0.4.0): Ingresos B2G — Subsidios + Reportes + Dashboard

> **Tipo:** `Feature`
> **Tamaño:** `XL`
> **Estrategia:** `Team`
> **Componentes:** `Backend`, `Database`, `Frontend`, `Web Quality`
> **Impacto:** `🔥 Critical Path`, `💰 Revenue`
> **Banderas:** `📦 Epic`, `🚫 Blocked`
> **Branch:** `feat/sprint-2-revenue-b2g`
> **Fuente de Spec:** `specs/altrupets/tasks.md` (sección Sprint 2)
> **Estado:** `Blocked`
> **Dependencias:** `Sprint 1 (Entidad Animal, PostGIS, Autenticación, Perfil veterinario)`
> **Proyecto Linear:** `Backend` + `Mobile App` + `Web Quality`

---

## ⚠️ BLOQUEADORES

Este sprint está **BLOQUEADO** por la finalización del Sprint 1. Específicamente:

| Bloqueador | Requerido Para | Estado Actual |
|---------|-------------|----------------|
| T0-1 Entidad Animal | S1 (subsidio se vincula a animales) | NOT_STARTED |
| T0-2 CRUD de Casa Cuna | S2 (selección de inventario de animales) | PARTIAL (stub de UI) |
| T0-8 Perfil Veterinario | S2 (selección de veterinario por proximidad) | NOT_STARTED |
| T0-9 PostGIS + Jurisdicciones | S2, R1 (auto-municipalidad por GPS) | NOT_STARTED |
| T0-3 Fortalecimiento de autenticación | R1 (reportes de abuso requieren autenticación) | PARTIAL |

**No iniciar el Sprint 2 hasta que todas las tareas del Track A, C y D del Sprint 1 estén completas.**

---

## 👤 CAPA HUMANA

### Historia de Usuario

Como **comprador del gobierno municipal (P01 Gabriela)**, quiero **revisar y aprobar solicitudes de subsidio veterinario y ver reportes de abuso de mi jurisdicción** para que **pueda justificar un contrato B2G con AltruPets para gestión de bienestar animal**.

### Contexto / Por Qué

El Sprint 2 construye las dos funcionalidades que justifican los contratos B2G municipales — la fuente principal de ingresos (75% de $10K MRR). El flujo de trabajo de subsidios veterinarios (J4) es la funcionalidad individual más valiosa con $3,500/mes de ingresos en riesgo. El sistema de reportes de abuso (J5) agrega $1,425/mes. El dashboard municipal (J7) es la funcionalidad de "demostración" que cierra acuerdos a $1,900/mes.

En conjunto, estas tres funcionalidades representan $6,825/mes (68% del MRR objetivo). Sin ellas, no hay un producto B2G viable para vender. El framework SRD clasifica J4 como el recorrido de prioridad #1 y J7 como #2.

El sprint se estructura en tres fases paralelas: (A) flujo de trabajo de subsidios de principio a fin, (B) creación y seguimiento de reportes de abuso, (C) dashboard municipal que consume datos de A y B.

### Analogía

El Sprint 2 es como abrir la ventanilla de atención en una oficina gubernamental. La Fase A (subsidios) es la ventanilla principal de servicio donde las organizaciones de rescate envían solicitudes y la municipalidad las procesa. La Fase B (reportes de abuso) es el escritorio de recepción de quejas. La Fase C (dashboard) es la oficina de gestión que ve el panorama general de todas las operaciones.

### Referencia UX / Visual

```
Flujo de Trabajo de Subsidios (Fase A):
  Rescatista (Móvil) →  Sistema (PostGIS)  →  Coordinador (Web)  →  Vet (Móvil)
  ┌──────────────┐     ┌──────────────┐     ┌──────────────────┐    ┌────────────┐
  │Crear         │────▶│Auto-asignar  │────▶│Revisar + Aprobar/│───▶│Aceptar +   │
  │Solicitud     │     │Municipalidad │     │Rechazar + Expirar│    │Programar   │
  │Animal + Costo│     │              │     │                  │    │            │
  └──────────────┘     └──────────────┘     └──────────────────┘    └────────────┘

Reporte de Abuso (Fase B):
  Usuario (Móvil) → Sistema (PostGIS) → Funcionario (Web) → Usuario (Móvil)
  ┌────────────┐   ┌──────────────┐   ┌────────────┐   ┌────────────┐
  │Presentar   │──▶│Auto-enrutar  │──▶│Revisar +   │──▶│Seguimiento │
  │Reporte     │   │a Municipalidad│   │Investigar  │   │vía Código  │
  │GPS + Fotos │   │              │   │            │   │            │
  └────────────┘   └──────────────┘   └────────────┘   └────────────┘
```

### Errores Conocidos y Advertencias

1. **Complejidad de la máquina de estados:** Las transiciones de estado del subsidio (CREATED→IN_REVIEW→APPROVED→REJECTED→EXPIRED→INVOICED) necesitan cumplimiento estricto. Considerar usar una librería como `typeorm-state-machine` o implementar un patrón de guard.
2. **Trabajo de auto-expiración:** Requiere una cola de trabajos (Bull/BullMQ) o cron (@nestjs/schedule). El backend actual NO tiene infraestructura de trabajos.
3. **Aislamiento multi-tenant:** Los datos del dashboard deben estar delimitados por `municipality_tenant_id`. Las consultas SQL SIEMPRE deben incluir filtro de tenant para prevenir fugas de datos entre municipalidades.
4. **Patrón de Inertia.js:** La app web B2G usa Inertia.js (server-side rendering vía NestJS → Vue 3). Las nuevas páginas deben seguir el patrón existente en `apps/web/b2g/` y el controlador B2G.
5. **Dependencia de PostGIS:** La auto-asignación GPS→jurisdicción requiere el mapeo de jurisdicciones PostGIS del Sprint 1 (D2). Si D2 está incompleto, la auto-asignación debe reemplazarse con selección manual de municipalidad.
6. **Sin servicio de email:** Las notificaciones de cambio de estado (subsidio aprobado/rechazado, estado de reporte de abuso) requieren un servicio de email/notificación que aún no existe. Considerar usar @nestjs-modules/mailer o Firebase Cloud Messaging como solución temporal.

---

## 🤖 CAPA AGENTE

### Objetivo

Construir el flujo completo de solicitud de subsidio veterinario (envío móvil → auto-enrutamiento por jurisdicción → revisión en dashboard web → aceptación del veterinario), el sistema de reportes de abuso (formulario móvil autenticado → código de seguimiento → enrutamiento por jurisdicción → gestión en dashboard), y el dashboard municipal que agrega ambas fuentes de datos con KPIs delimitados por jurisdicción.

### Auditoría del Estado Actual

#### Ya Existe

- `apps/web/b2g/` — Scaffold de app web Vue 3 con integración Inertia.js
- `apps/backend/src/web/b2g/b2g.controller.ts` — Rutas: `/b2g`, `/b2g/captures`, `/b2g/captures/:id`
- `apps/web/b2g/src/pages/Dashboard.vue` — Stub (solo mensaje de bienvenida)
- `apps/web/b2g/src/pages/Requests/Index.vue` — Muestra solicitudes de captura, NO subsidios
- `apps/backend/src/main.ts` (línea 52) — `app.use(inertiaMiddleware)` configurado
- Autenticación JWT para web (gestión de sesión basada en cookies)
- Control de acceso basado en roles con `CAPTURE_VIEWER_ROLES`
- Targets del Makefile: `dev-b2g-start`, `dev-b2g-stop`, `dev-b2g-tf-deploy`

#### Necesita Creación

- `apps/backend/src/subsidies/` — Módulo completo (entity, service, resolver, controller)
- `apps/backend/src/abuse-reports/` — Módulo completo
- `apps/backend/src/notifications/` — Servicio de notificaciones (email + push)
- `apps/backend/src/jobs/` — Cola de trabajos para auto-expiración
- `apps/backend/src/migrations/XXXXXX-CreateSubsidyRequestEntity.ts`
- `apps/backend/src/migrations/XXXXXX-CreateAbuseReportEntity.ts`
- `apps/web/b2g/src/pages/Subsidies/Index.vue` — Página de cola de subsidios
- `apps/web/b2g/src/pages/Subsidies/Show.vue` — Detalle de subsidio + aprobar/rechazar
- `apps/web/b2g/src/pages/AbuseReports/Index.vue` — Lista de reportes de abuso
- `apps/web/b2g/src/pages/AbuseReports/Show.vue` — Detalle de reporte de abuso
- `apps/mobile/lib/features/subsidies/` — Feature móvil de subsidios
- `apps/mobile/lib/features/abuse_reports/` — Feature móvil de reportes de abuso

#### Necesita Modificación

- `apps/backend/src/app.module.ts` — Registrar nuevos módulos, agregar @nestjs/schedule
- `apps/backend/src/web/b2g/b2g.controller.ts` — Agregar rutas de subsidios y reportes de abuso
- `apps/web/b2g/src/pages/Dashboard.vue` — Reemplazar stub con dashboard de KPIs
- `apps/backend/package.json` — Agregar @nestjs/schedule, @nestjs/bull (o @nestjs-modules/mailer)

### Archivos de Contexto

- `apps/backend/src/web/b2g/b2g.controller.ts` — Rutas B2G existentes y patrón de renderizado Inertia
- `apps/web/b2g/src/pages/Dashboard.vue` — Stub de dashboard a reemplazar
- `apps/web/b2g/src/pages/Requests/Index.vue` — Patrón existente de página Inertia como referencia
- `apps/backend/src/main.ts` — Configuración de middleware Inertia
- `apps/backend/src/app.module.ts` — Registro de módulos
- `apps/backend/package.json` — Dependencias actuales
- `apps/backend/src/users/entities/user.entity.ts` — Entidad User para referencias FK
- `apps/backend/src/organizations/entities/organization.entity.ts` — Patrón multi-tenant
- `Makefile` — Convenciones de nomenclatura para nuevos targets

### Criterios de Aceptación

- [ ] S1: Entidad SubsidyRequest con máquina de estados que impone transiciones válidas
- [ ] S2: Formulario móvil crea solicitud de subsidio con selección de animal, estimación de costo, auto-jurisdicción por GPS
- [ ] S3: Dashboard web muestra subsidios pendientes por jurisdicción con botones de aprobar/rechazar
- [ ] S3: Trabajo de auto-expiración marca solicitudes CREATED como EXPIRED después de max_response_hours
- [ ] S4: Veterinario recibe notificación de subsidio aprobado con detalles
- [ ] R1: Usuario autenticado presenta reporte de abuso con GPS, fotos y asignación automática de municipalidad
- [ ] R1: Código de seguimiento generado y mostrado al enviar
- [ ] R2: Usuario puede verificar estado del reporte de abuso usando código de seguimiento
- [ ] R2: Actualizaciones de estado disparan notificaciones al denunciante
- [ ] G1: Dashboard muestra KPIs delimitados por jurisdicción (cantidad de rescates, gasto en subsidios, reportes de abuso, tasa de adopción)
- [ ] G1: Dashboard muestra los datos que estén disponibles (Regla #7: sin estados vacíos)
- [ ] G1: Aislamiento multi-tenant — cada municipalidad solo ve sus datos
- [ ] G2: Reportes de abuso gestionables desde el dashboard (clasificar, priorizar, asignar investigador)

### Restricciones Técnicas

- Las transiciones de la máquina de estados deben imponerse a nivel de servicio (no solo validación)
- Las consultas multi-tenant DEBEN incluir filtro `municipality_tenant_id`
- Las páginas Inertia siguen el patrón de server-side rendering (controller pasa datos, Vue renderiza)
- La auto-expiración requiere @nestjs/schedule con decorador @Cron
- GPS→jurisdicción usa consulta PostGIS `ST_Contains(boundary, ST_MakePoint(lon, lat))`
- Los reportes de abuso son AUTENTICADOS (Regla SRD #9) — no hay reportes anónimos
- El dashboard debe mostrar "los datos que existan" (Regla SRD #7) — nunca estados vacíos

### Comandos de Verificación

```bash
# Pre-vuelo
# Verificar que las entidades del Sprint 1 existen
curl -s http://localhost:3001/graphql -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name } } }"}' | jq '.data.__schema.types[].name' | grep -i "animal\|jurisdiction\|vet"

# Build
cd apps/backend && npm run build && npm run migration:run
cd apps/web/b2g && npm run build

# Tests
cd apps/backend && npm run test -- --testPathPattern=subsid
cd apps/backend && npm run test -- --testPathPattern=abuse

# K8s
make dev-images-build
make dev-b2g-tf-deploy

# Dashboard
curl -s http://localhost:3001/b2g -H "Cookie: session=..." | head -20
```

### Estrategia del Agente

**Modo:** `Team`

**Rol líder:** Coordinador — asigna tareas, revisa, sintetiza. Sin ediciones directas de archivos.

**Compañeros de equipo:**
- Compañero 1: **Backend Entidades + Máquina de Estados** → responsable de entidades S1, R1, migraciones, máquina de estados, trabajo de auto-expiración (`apps/backend/src/subsidies/`, `apps/backend/src/abuse-reports/`, `apps/backend/src/jobs/`)
- Compañero 2: **Dashboard Web (Vue/Inertia)** → responsable de páginas web S3, G1, G2 + rutas del controlador B2G (`apps/web/b2g/src/pages/`, `apps/backend/src/web/b2g/`)
- Compañero 3: **Features Móviles** → responsable de S2, S4, R1 móvil, R2 móvil (`apps/mobile/lib/features/subsidies/`, `apps/mobile/lib/features/abuse_reports/`)

**Modo de visualización:** `tab`
**Aprobación de plan requerida:** sí
**Propiedad de archivos:** Explícita — Backend entidades (Compañero 1), UI Web (Compañero 2), UI Móvil (Compañero 3)

### Notificación de Slack

Al terminar, enviar un resumen al usuario vía Slack MCP con:
- Estado del flujo de trabajo de subsidios (funcionando/parcial)
- Estado del sistema de reportes de abuso
- KPIs disponibles en el dashboard
- Cualquier dependencia faltante del Sprint 1 que haya bloqueado trabajo

---

## Plan de Implementación

### Verificaciones Pre-vuelo

```bash
# Verificar que las dependencias del Sprint 1 se cumplen
cd apps/backend && npm run migration:show | grep -i "animal\|jurisdiction\|vet"
# Las tres deben mostrarse como "executed"

# Verificar que PostGIS está disponible
kubectl exec -n altrupets-dev deploy/postgres -- psql -U postgres -d altrupets -c "SELECT PostGIS_Version();"
```

### Acciones Paso a Paso

#### Fase A: Flujo de Trabajo de Subsidios (Compañero 1 + 3, ~5 días)

1. **S1: Crear entidad SubsidyRequest + máquina de estados**
   - **Herramienta:** Write
   - **Objetivo:** `apps/backend/src/subsidies/entities/subsidy-request.entity.ts`
   - **Descripción:** Entidad con todos los campos del spec. Enum para estado con validación de transiciones en la capa de servicio.

2. **S1: Crear trabajo de auto-expiración**
   - **Herramienta:** Write + Bash
   - **Objetivo:** `apps/backend/src/subsidies/subsidies-expiration.service.ts`
   - **Descripción:** Instalar @nestjs/schedule. Crear trabajo @Cron que encuentre solicitudes CREATED que hayan pasado max_response_hours y las marque como EXPIRED.

3. **S2: Crear feature móvil de solicitud de subsidio**
   - **Herramienta:** Write
   - **Objetivo:** `apps/mobile/lib/features/subsidies/`
   - **Descripción:** Feature completo: presentation/pages/create_subsidy_request_page.dart, data/repositories/subsidy_repository.dart, domain/models/

4. **S3: Crear páginas web de revisión de subsidios**
   - **Herramienta:** Write + Edit
   - **Objetivo:** `apps/web/b2g/src/pages/Subsidies/`, `apps/backend/src/web/b2g/b2g.controller.ts`
   - **Descripción:** Páginas Vue para cola y vista de detalle. Endpoints del controlador para aprobar/rechazar.

5. **S4: Crear flujo de notificación al veterinario**
   - **Herramienta:** Write
   - **Objetivo:** `apps/backend/src/notifications/notification.service.ts`
   - **Descripción:** Servicio que envía notificación push (FCM) cuando el estado del subsidio cambia a APPROVED.

#### Fase B: Reportes de Abuso (Compañero 1 + 3, en paralelo con Fase A, ~3 días)

6. **R1: Crear entidad AbuseReport + código de seguimiento**
   - **Herramienta:** Write
   - **Objetivo:** `apps/backend/src/abuse-reports/`
   - **Descripción:** Entidad con generación de código de seguimiento (nanoid), ubicación GPS, enum de tipo de abuso, array de fotos.

7. **R1: Crear formulario móvil de reporte de abuso**
   - **Herramienta:** Write
   - **Objetivo:** `apps/mobile/lib/features/abuse_reports/`
   - **Descripción:** Formulario autenticado con captura automática de GPS, subida de fotos, selector de tipo de abuso.

8. **R2: Crear interfaz de seguimiento de reportes**
   - **Herramienta:** Write
   - **Objetivo:** `apps/mobile/lib/features/abuse_reports/presentation/pages/track_report_page.dart`
   - **Descripción:** Ingresar código de seguimiento, mostrar línea de tiempo de estado, notificación push al cambiar.

#### Fase C: Dashboard Municipal (Compañero 2, después de que A y B tengan entidades, ~3 días)

9. **G1: Reemplazar stub de Dashboard.vue con dashboard de KPIs**
   - **Herramienta:** Edit
   - **Objetivo:** `apps/web/b2g/src/pages/Dashboard.vue`
   - **Descripción:** Tarjetas de KPI: cantidad de rescates, gasto en subsidios, reportes de abuso, tasa de adopción, tiempos de respuesta. Todo delimitado por jurisdicción.

10. **G2: Crear páginas de gestión de reportes de abuso**
    - **Herramienta:** Write
    - **Objetivo:** `apps/web/b2g/src/pages/AbuseReports/`
    - **Descripción:** Lista con filtros, detalle con acciones de clasificar/priorizar/asignar.

### Verificación Post-vuelo

```bash
# Verificar flujo de subsidios
cd apps/backend && npm run test -- --testPathPattern=subsid

# Verificar reportes de abuso
cd apps/backend && npm run test -- --testPathPattern=abuse

# Verificar que el dashboard se renderiza
curl -s http://localhost:3001/b2g | grep -i "dashboard\|KPI"

# Verificar auto-expiración
cd apps/backend && npm run test -- --testPathPattern=expir
```

---

## 🔀 Recomendación de Paralelización

**Mecanismo recomendado:** `Agent Teams`

**Razonamiento:**

El Sprint 2 tiene 3 fases paralelas (A: Subsidios, B: Reportes de Abuso, C: Dashboard) a través de 3 capas tecnológicas (backend, web, móvil). Las fases son mayormente independientes (A y B producen datos, C los consume). La creación de entidades del backend puede proceder en paralelo con el desarrollo de UI web/móvil.

- **Agent Teams** — Mejor opción. 3 compañeros de equipo con propiedad clara de archivos:
  - Backend (entidades + máquina de estados + trabajos)
  - Web (dashboard Vue/Inertia + páginas de gestión)
  - Móvil (formulario de subsidio + formulario de reporte de abuso + seguimiento)

**Mapeo Tamaño → Mecanismo:** XL → Descomponer en 3 flujos paralelos de tamaño M, cada uno como miembro de Agent Team

**Estimación de costo:** ~3-4x costo base de tokens

---

## Recomendaciones de Issues en Linear

### Issue 1: Flujo de Trabajo de Subsidio Veterinario (S1-S4)
**Título:** Construir flujo de solicitud de subsidio veterinario: creación, auto-enrutamiento, revisión, aprobación
**Proyecto:** Backend
**Prioridad:** Urgent
**Etiquetas:** Feature, L, Team, Backend, Database, Frontend, 🔥 Critical Path, 💰 Revenue

### Issue 2: Sistema de Reportes de Abuso (R1-R2)
**Título:** Construir formulario de reporte de abuso con GPS, código de seguimiento y rastreo de estado
**Proyecto:** Backend + Mobile App
**Prioridad:** Urgent
**Etiquetas:** Feature, M, Team, Backend, Frontend, 🔥 Critical Path, 💰 Revenue

### Issue 3: Dashboard Municipal (G1-G2)
**Título:** Construir dashboard municipal con KPIs delimitados por jurisdicción y gestión de reportes de abuso
**Proyecto:** Web Quality
**Prioridad:** High
**Etiquetas:** Feature, M, Team, Backend, Web Quality, 🔥 Critical Path, 💰 Revenue

---

## Resumen de Archivos Modificados

| Acción | Ruta | Líneas Cambiadas (est.) |
|--------|------|---------------------|
| Crear | `apps/backend/src/subsidies/` (5 archivos) | ~500 |
| Crear | `apps/backend/src/abuse-reports/` (5 archivos) | ~350 |
| Crear | `apps/backend/src/notifications/` (3 archivos) | ~200 |
| Crear | `apps/backend/src/jobs/` (2 archivos) | ~100 |
| Crear | `apps/backend/src/migrations/` (2 archivos) | ~100 |
| Modificar | `apps/backend/src/app.module.ts` | ~20 |
| Modificar | `apps/backend/src/web/b2g/b2g.controller.ts` | ~80 |
| Modificar | `apps/backend/package.json` | ~5 |
| Modificar | `apps/web/b2g/src/pages/Dashboard.vue` | ~200 |
| Crear | `apps/web/b2g/src/pages/Subsidies/` (2 archivos) | ~300 |
| Crear | `apps/web/b2g/src/pages/AbuseReports/` (2 archivos) | ~250 |
| Crear | `apps/mobile/lib/features/subsidies/` (6 archivos) | ~400 |
| Crear | `apps/mobile/lib/features/abuse_reports/` (6 archivos) | ~350 |
| Crear | Tests (backend + móvil) | ~400 |

---

### Comentarios Adicionales de Síntesis

#### Validación Lógica MECE

* **Mutuamente Excluyente:** La Fase A (subsidios), Fase B (reportes de abuso) y Fase C (dashboard) tocan dominios de entidades completamente separados. El único componente compartido es el servicio de notificaciones, que debe ser responsabilidad del compañero de Backend Entidades. El controlador B2G es compartido entre el Compañero 1 (endpoints de API) y el Compañero 2 (renderizado Inertia), requiriendo coordinación cuidadosa.

* **Colectivamente Exhaustivo:** Todos los requisitos SRD T0-4, T0-5, T0-6, T0-7 están cubiertos. El sprint aborda el 100% de los requisitos del Sprint 2 de tasks.md incluyendo máquina de estados, auto-expiración, aislamiento multi-tenant y enrutamiento por jurisdicción basado en GPS.

#### Síntesis Ejecutiva (Pirámide de Minto)

1. **Liderar con la Respuesta:** El Sprint 2 entrega las dos funcionalidades generadoras de ingresos (subsidios veterinarios y reportes de abuso) más el dashboard municipal que las demuestra — valoradas colectivamente en $6,825/mes y críticas para cerrar contratos B2G.

2. **Argumentos de Soporte:**
   - **Flujo de Trabajo de Subsidios (Fase A):** Flujo de principio a fin desde el envío móvil del rescatista hasta la aprobación web municipal hasta la aceptación del veterinario — la funcionalidad de ingresos #1
   - **Reportes de Abuso (Fase B):** Presentación autenticada de reportes con auto-enrutamiento por GPS y código de seguimiento — la funcionalidad de ingresos #2
   - **Dashboard (Fase C):** Visualización de KPIs delimitados por jurisdicción que vende la plataforma a las municipalidades — la "demostración" que cierra acuerdos

3. **Datos y Evidencia:** 2 entidades nuevas, 3 páginas web nuevas, 2 features móviles nuevos, 1 cola de trabajos, 1 servicio de notificaciones. Estimado de 3,255 líneas de código nuevo.

#### Revisión de Eficiencia Pareto 80/20

* **80% de valor con 20% de esfuerzo:** La creación de solicitud de subsidio (S1) + vista de KPIs del dashboard (G1) juntos forman la "demostración" que las municipalidades necesitan ver. Construir solo estos dos da el 80% del valor de ventas incluso sin el flujo completo de aprobación.
* **Posible simplificación para desarrollo:** La auto-expiración (trabajo cron S3) podría reemplazarse inicialmente con un botón manual de "Expirar" en el dashboard. Esto evita agregar @nestjs/schedule como dependencia.
* **⚠️ Advertencia de descomposición XL:** Este sprint tiene tamaño XL ($6,825/mes en riesgo, 3+ semanas, 3 capas tecnológicas). Debe descomponerse en 3 issues separados de Linear (uno por fase) para mejor seguimiento.

#### Pensamiento de Segundo Orden y Evaluación de Riesgos

* **Escalabilidad:** El trabajo cron de auto-expiración verifica TODAS las solicitudes CREATED en cada ejecución. A escala (>10K solicitudes), necesita paginación o una cola dedicada con retraso respaldada por Redis (Bull). Para MVP, un simple @Cron con consulta TypeORM es suficiente.
* **Efectos Aguas Abajo:** Las entidades del Sprint 2 (SubsidyRequest, AbuseReport) se convierten en la fuente de datos para el Sprint 4 (facturación), Sprint 5 (reportes de transparencia) y Sprint 7 (analítica). El esquema de entidades debe diseñarse para extensibilidad.
* **Mantenimiento Futuro:** El patrón de Inertia.js (controlador NestJS → renderizado Vue) no es estándar. Los desarrolladores futuros deben entender este enfoque híbrido de SSR. Considerar documentar el patrón en un CONTRIBUTING.md o registro de decisión arquitectónica.
