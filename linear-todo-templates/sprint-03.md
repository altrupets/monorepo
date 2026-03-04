# Sprint 3 (v0.5.0): Entrega de Valor — Rescate + Adopciones + Push

> **Tipo:** `Feature`
> **Tamaño:** `XL`
> **Estrategia:** `Team`
> **Componentes:** `Backend`, `Database`, `Frontend`
> **Impacto:** `🔥 Critical Path`
> **Banderas:** `📦 Epic`, `🚫 Blocked`
> **Branch:** `feat/sprint-3-value-delivery`
> **Fuente de Spec:** `specs/altrupets/tasks.md` (sección Sprint 3)
> **Estado:** `Blocked`
> **Dependencias:** `Sprint 1 (Animal, CasaCuna, PostGIS) + Sprint 2 (parcial)`
> **Proyecto Linear:** `Backend` + `Mobile App`

---

## ⚠️ BLOQUEADORES

| Bloqueador | Requerido Para | Sprint |
|---------|-------------|--------|
| T0-1 Entidad Animal | Tareas 13-15, AD1-AD3 (todas necesitan animales) | Sprint 1 |
| T0-2 CRUD de Casa Cuna | AD1 (publicar desde inventario) | Sprint 1 |
| T0-9 PostGIS | Tarea 14 (coincidencia por proximidad) | Sprint 1 |
| T0-3 Autenticación (refreshToken) | 5d, 5d-b (extensión de autenticación) | Sprint 1 |
| Firebase Cloud Messaging | Tarea 26 (notificaciones push) | Configurado pero no conectado |

---

## 👤 CAPA HUMANA

### Historia de Usuario

Como **rescatista (P05 Sofía)**, quiero **coordinar rescates con centinelas y auxiliares, publicar animales para adopción y recibir notificaciones push** para que **la plataforma genere actividad real y engagement que demuestre valor a las municipalidades**.

### Contexto / Por Qué

El Sprint 3 es el sprint de "entrega de valor" — construye las funcionalidades que crean actividad visible en la plataforma. Mientras el Sprint 2 se enfocó en ingresos (contratos B2G), el Sprint 3 se enfoca en los flujos de trabajo diarios que hacen útil la plataforma: coordinación de rescates, adopciones y notificaciones push.

El SRD los identifica como "entrega de valor, no críticos para ingresos" (Regla #6), pero son esenciales para la retención y credibilidad de la plataforma. Una municipalidad no renovará un contrato si ningún rescatista está usando la app. Las adopciones generan contenido (historias felices) y donaciones. Las notificaciones push son el sistema nervioso que mantiene todo responsivo.

Las funcionalidades complementarias de autenticación (restablecimiento de contraseña, verificación de email) se incluyen porque son correcciones de bajo esfuerzo que reducen la fricción en el recorrido de incorporación (J1).

### Analogía

El Sprint 3 es como abrir la cocina en un restaurante después de que el Sprint 2 construyó la recepción. La cocina (coordinación de rescates + adopciones) produce las comidas (animales rescatados, adopciones exitosas) que la recepción (municipalidades) puede mostrar como resultados. Las notificaciones push son los tickets de pedido que mantienen la cocina en movimiento.

### Referencia UX / Visual

```
Pipeline de Rescate:
  Centinela ──▶ Auxiliar ──▶ Rescatista ──▶ Casa Cuna ──▶ Adopción
  (Reportar)   (Responder)  (Recibir)     (Cuidar)      (Colocar)

Flujo de Adopción:
  Rescatista publica ──▶ Adoptante navega ──▶ Solicita ──▶ Visita ──▶ Aprobado
```

### Errores Conocidos y Advertencias

1. **Permisos de notificaciones push:** Android 13+ requiere permiso explícito de notificación. iOS requiere solicitar vía `requestPermission()`. Debe manejar la denegación de forma elegante.
2. **Complejidad de coincidencia por proximidad:** Encontrar auxiliares cercanos requiere `ST_DWithin` de PostGIS con un parámetro de radio. Si nadie está cerca, debe existir lógica de escalación (expandir radio, notificar al coordinador de la organización).
3. **Configuración de Firebase Cloud Messaging:** FCM requiere registro de token del dispositivo al iniciar sesión. El token debe almacenarse en el backend y actualizarse en la rotación de token FCM.
4. **Longitud del flujo de adopción:** El flujo PENDING_REVIEW → VISIT_SCHEDULED → VISIT_COMPLETED → APPROVED tiene 4+ estados. Considerar usar el mismo patrón de máquina de estados de los subsidios del Sprint 2.
5. **Servicio de email:** El restablecimiento de contraseña y la verificación de email requieren un mailer. Opciones: @nestjs-modules/mailer con SMTP, o servicio de email transaccional (SendGrid, Mailgun). Debe integrarse con Infisical para las credenciales.
6. **Dependencia de chat:** La Tarea 15 hace referencia a "comunicación vía chat existente." El sistema de chat (Firebase Firestore) existe pero no está vinculado a los flujos de trabajo de rescate todavía. Esta vinculación es del Sprint 4 (Tarea 25).

---

## 🤖 CAPA AGENTE

### Objetivo

Construir el pipeline de coordinación de rescate (alertas de centinela → coincidencia de auxiliar → transferencia a rescatista), el ciclo de vida de adopción (publicar → navegar → solicitar → aprobar), infraestructura de notificaciones push y funcionalidades complementarias de autenticación (restablecimiento de contraseña, verificación de email).

### Auditoría del Estado Actual

#### Ya Existe

- `apps/mobile/lib/features/rescues/presentation/pages/rescues_page.dart` — Shell de UI con 6 botones stub (todos `onTap: () {}`)
- `apps/backend/src/captures/` — Entidad CaptureRequest (básica, 8 columnas)
- `firebase_options.dart` — Firebase configurado para Android/iOS/Web
- `firebase_messaging: ^15.2.4` — Dependencia en pubspec.yaml (NO conectada)
- `apps/mobile/lib/features/messages/` — Feature de chat (basado en Firestore, independiente)
- `apps/backend/src/users/entities/user.entity.ts` — Entidad User con campo booleano `isVerified`
- `apps/backend/src/auth/auth.service.ts` — AuthService (sin envío de email)

#### Necesita Creación

- `apps/backend/src/rescues/` — Módulo completo de coordinación de rescate
- `apps/backend/src/adoptions/` — Módulo completo de adopción
- `apps/backend/src/push-notifications/` — Módulo de integración FCM
- `apps/backend/src/email/` — Módulo de servicio de email (mailer)
- `apps/backend/src/migrations/XXXXXX-CreateRescueEntities.ts`
- `apps/backend/src/migrations/XXXXXX-CreateAdoptionEntities.ts`
- `apps/mobile/lib/features/rescues/` — UI completa de coordinación de rescate
- `apps/mobile/lib/features/adoptions/` — Feature completo de adopción
- `apps/mobile/lib/core/services/push_notification_service.dart`
- `apps/mobile/lib/features/auth/presentation/pages/forgot_password_page.dart`

#### Necesita Modificación

- `apps/backend/src/auth/auth.resolver.ts` — Agregar mutaciones resetPassword, verifyEmail
- `apps/backend/src/auth/auth.service.ts` — Agregar lógica de verificación de email y restablecimiento de contraseña
- `apps/backend/src/app.module.ts` — Registrar nuevos módulos
- `apps/mobile/lib/main.dart` — Inicializar FirebaseMessaging
- `apps/mobile/lib/features/rescues/presentation/pages/rescues_page.dart` — Reemplazar stubs con UI funcional

### Archivos de Contexto

- `apps/mobile/lib/features/rescues/presentation/pages/rescues_page.dart` — Stub actual de UI de rescate
- `apps/backend/src/captures/entities/capture-request.entity.ts` — Patrón de entidad existente
- `apps/mobile/lib/features/messages/` — Patrón de chat como referencia
- `firebase_options.dart` — Configuración de Firebase
- `apps/backend/src/auth/auth.service.ts` — Servicio de autenticación a extender
- `apps/backend/src/users/entities/user.entity.ts` — Entidad User con campo isVerified

### Criterios de Aceptación

#### Coordinación de Rescate (Tareas 13-15)
- [ ] Centinela crea alerta con GPS + fotos + urgencia en <3 minutos
- [ ] Sistema encuentra auxiliares cercanos dentro de radio de 10km (PostGIS)
- [ ] Auxiliar recibe notificación push dentro de 30 segundos
- [ ] Auxiliar acepta/rechaza con justificación
- [ ] Rescatista ve solicitudes de transferencia entrantes
- [ ] Navegación GPS a la ubicación de rescate
- [ ] Actualizaciones de estado del animal durante todo el flujo de trabajo

#### Adopciones (Tareas AD1-AD3)
- [ ] Rescatista marca animal como READY_FOR_ADOPTION desde inventario de casa cuna
- [ ] Galería navegable con filtros de especie/tamaño/edad/ubicación/apto-para-niños
- [ ] Adoptante envía solicitud con cuestionario del hogar
- [ ] Rescatista revisa, programa visita, aprueba/rechaza
- [ ] Estado del animal cambia a ADOPTED al ser aprobado

#### Notificaciones Push (Tarea 26)
- [ ] Integración FCM maneja registro de token del dispositivo + rotación
- [ ] Notificaciones diferenciadas por rol (rescatista, auxiliar, centinela, municipalidad, veterinario)
- [ ] Preferencias de notificación configurables por el usuario
- [ ] Centro de notificaciones in-app como respaldo

#### Autenticación Complementaria (Tareas 5d, 5d-b)
- [ ] "Olvidé mi contraseña" envía email de restablecimiento con enlace de token
- [ ] Verificación de email enviada al registrarse
- [ ] Endpoint de confirmación valida token y marca usuario como verificado

### Restricciones Técnicas

- Notificaciones push: Usar paquete firebase_messaging ya incluido en pubspec.yaml
- Coincidencia de rescate: PostGIS `ST_DWithin(geography, ST_MakePoint(lon, lat), radius_meters)` dentro de 10km
- Escalación: Si ningún auxiliar responde dentro de 15 minutos, expandir radio a 25km y notificar al coordinador de la organización
- Estados de adopción: PENDING_REVIEW → VISIT_SCHEDULED → VISIT_COMPLETED → APPROVED / REJECTED
- Email: Usar @nestjs-modules/mailer con credenciales SMTP de Infisical
- Restablecimiento de contraseña basado en token: Generar token de corta duración (1 hora), enviar enlace por email, verificar + permitir nueva contraseña

### Comandos de Verificación

```bash
# Pre-vuelo
cd apps/backend && npm run build
cd apps/mobile && flutter analyze

# Tests
cd apps/backend && npm run test -- --testPathPattern=rescue
cd apps/backend && npm run test -- --testPathPattern=adoption
cd apps/backend && npm run test -- --testPathPattern=notification

# Test de notificaciones push
# (requiere token de dispositivo de prueba FCM)

# Test de email
cd apps/backend && npm run test -- --testPathPattern=email

# Build móvil
cd apps/mobile && flutter build apk --debug 2>&1 | tail -5
```

### Estrategia del Agente

**Modo:** `Team`

**Rol líder:** Coordinador

**Compañeros de equipo:**
- Compañero 1: **Servicios Backend** → responsable de módulos de rescate, adopción, notificaciones push, email (`apps/backend/src/rescues/`, `apps/backend/src/adoptions/`, `apps/backend/src/push-notifications/`, `apps/backend/src/email/`)
- Compañero 2: **Features Móviles** → responsable de UI de rescate, UI de adopción, servicio de notificaciones push, página de olvidé contraseña (`apps/mobile/lib/features/rescues/`, `apps/mobile/lib/features/adoptions/`, `apps/mobile/lib/core/services/push_notification_service.dart`)
- Compañero 3: **Extensión de Autenticación** → responsable de restablecimiento de contraseña + verificación de email backend + móvil (`apps/backend/src/auth/`, `apps/mobile/lib/features/auth/`)

**Modo de visualización:** `tab`
**Aprobación de plan requerida:** sí
**Propiedad de archivos:** Explícita

---

## Plan de Implementación

### Acciones Paso a Paso

#### Fase D: Coordinación de Rescate (Tareas 13-15)

1. **Crear entidades de rescate (backend)**
   - **Herramienta:** Write
   - **Objetivo:** `apps/backend/src/rescues/entities/rescue-request.entity.ts`
   - **Descripción:** Entidad que extiende CaptureRequest con urgencia, flujo de trabajo de estado (CREATED→ASSIGNED→ACCEPTED→IN_PROGRESS→TRANSFERRED→COMPLETED), FKs auxiliary_id, rescuer_id

2. **Crear servicio de coincidencia de rescate**
   - **Herramienta:** Write
   - **Objetivo:** `apps/backend/src/rescues/rescue-matching.service.ts`
   - **Descripción:** Consulta de proximidad PostGIS dentro de 10km, ordenar por distancia + calificación, escalación después de 15min

3. **Crear páginas móviles de rescate**
   - **Herramienta:** Write + Edit
   - **Objetivo:** `apps/mobile/lib/features/rescues/`
   - **Descripción:** Formulario de creación de alerta, página de respuesta del auxiliar, página de transferencia del rescatista, navegación GPS

#### Fase E: Adopciones (Tareas AD1-AD3)

4. **Crear entidades de adopción**
   - **Herramienta:** Write
   - **Objetivo:** `apps/backend/src/adoptions/`
   - **Descripción:** Entidad AdoptionListing, entidad AdoptionRequest con cuestionario, flujo de trabajo de estados

5. **Crear galería de adopción + UI de solicitud**
   - **Herramienta:** Write
   - **Objetivo:** `apps/mobile/lib/features/adoptions/`
   - **Descripción:** Galería navegable con filtros, formulario de solicitud, interfaz de revisión

#### Fase F: Notificaciones Push (Tarea 26)

6. **Crear servicio de notificaciones push**
   - **Herramienta:** Write + Bash
   - **Objetivo:** `apps/backend/src/push-notifications/`, `apps/mobile/lib/core/services/push_notification_service.dart`
   - **Descripción:** Integración FCM, gestión de tokens de dispositivo, envío basado en roles, gestión de preferencias

#### Fase G: Autenticación Complementaria (Tareas 5d, 5d-b)

7. **Implementar restablecimiento de contraseña + verificación de email**
   - **Herramienta:** Write + Edit
   - **Objetivo:** `apps/backend/src/auth/`, `apps/backend/src/email/`, feature de autenticación móvil
   - **Descripción:** Servicio de mailer, generación de token de restablecimiento, endpoint de verificación, página móvil ForgotPasswordPage

### Verificación Post-vuelo

```bash
cd apps/backend && npm run test -- --coverage
cd apps/mobile && flutter test
make dev-backend-build
```

---

## 🔀 Recomendación de Paralelización

**Mecanismo recomendado:** `Agent Teams`

**Razonamiento:** 4 fases paralelas (D, E, F, G) a través de backend y móvil. Cada fase toca entidades y funcionalidades diferentes sin superposición de archivos.

**Mapeo Tamaño → Mecanismo:** XL → Descomponer en 4 flujos de tamaño M

**Estimación de costo:** ~3-4x costo base de tokens

---

## Recomendaciones de Issues en Linear

### Issue 1: Pipeline de Coordinación de Rescate (Tareas 13-15)
**Título:** Construir coordinación de rescate: alertas de centinela, coincidencia de auxiliar, transferencia a rescatista
**Proyecto:** Backend + Mobile App
**Prioridad:** High
**Etiquetas:** Feature, L, Team, Backend, Frontend, 🔥 Critical Path

### Issue 2: Ciclo de Vida de Adopción (Tareas AD1-AD3)
**Título:** Construir flujo de adopción: publicar, navegar, solicitar, evaluar, aprobar
**Proyecto:** Backend + Mobile App
**Prioridad:** High
**Etiquetas:** Feature, L, Team, Backend, Frontend

### Issue 3: Notificaciones Push (Tarea 26)
**Título:** Implementar Firebase Cloud Messaging con notificaciones basadas en roles
**Proyecto:** Backend + Mobile App
**Prioridad:** High
**Etiquetas:** Feature, M, Solo, Backend, Frontend

### Issue 4: Autenticación Complementaria (Tareas 5d, 5d-b)
**Título:** Implementar flujos de restablecimiento de contraseña y verificación de email
**Proyecto:** Backend + Mobile App
**Prioridad:** Medium
**Etiquetas:** Feature, S, Solo, Backend, Frontend, Security

---

## Resumen de Archivos Modificados

| Acción | Ruta | Líneas Cambiadas (est.) |
|--------|------|---------------------|
| Crear | `apps/backend/src/rescues/` (5 archivos) | ~450 |
| Crear | `apps/backend/src/adoptions/` (5 archivos) | ~400 |
| Crear | `apps/backend/src/push-notifications/` (3 archivos) | ~250 |
| Crear | `apps/backend/src/email/` (3 archivos) | ~150 |
| Crear | `apps/backend/src/migrations/` (2 archivos) | ~80 |
| Modificar | `apps/backend/src/auth/auth.resolver.ts` | ~40 |
| Modificar | `apps/backend/src/auth/auth.service.ts` | ~80 |
| Modificar | `apps/backend/src/app.module.ts` | ~20 |
| Crear | `apps/mobile/lib/features/adoptions/` (8 archivos) | ~600 |
| Modificar | `apps/mobile/lib/features/rescues/` (6 archivos) | ~500 |
| Crear | `apps/mobile/lib/core/services/push_notification_service.dart` | ~150 |
| Crear | `apps/mobile/lib/features/auth/.../forgot_password_page.dart` | ~100 |
| Crear | Tests | ~400 |

---

### Comentarios Adicionales de Síntesis

#### Validación Lógica MECE

* **Mutuamente Excluyente:** Cada fase (D/E/F/G) crea entidades y resolvers separados sin superposición de archivos. El único servicio compartido es el módulo de notificaciones que la Fase F crea y D/E consumirán.

* **Colectivamente Exhaustivo:** Cubre todas las tareas del Sprint 3 de tasks.md: T1-1 (rescate), T1-2 (adopción), T1-3 (push), T1-6 (autenticación complementaria).

#### Síntesis Ejecutiva (Pirámide de Minto)

1. **Liderar con la Respuesta:** El Sprint 3 entrega las funcionalidades operativas diarias (coordinación de rescate + adopciones + push) que crean actividad en la plataforma, justifican la renovación de contratos municipales del Sprint 2 y generan historias de adopción para engagement de donantes.

2. **Argumentos de Soporte:**
   - **Pipeline de Rescate:** Completa el flujo de trabajo centinela→auxiliar→rescatista que es el "producto" visible que les importa a las municipalidades
   - **Adopciones:** Crea el contenido de resultados positivos (adopciones exitosas) que demuestra el valor de la plataforma
   - **Notificaciones Push:** Hace todo en tiempo real y responsivo, crítico para la urgencia de los rescates

3. **Datos:** 4 nuevos módulos backend, 2 nuevos features móviles, ~3,220 líneas de código nuevo.

#### Pareto 80/20

* Las notificaciones push (Tarea 26) entregan un valor de engagement desproporcionado — un solo módulo habilita la capacidad de respuesta en tiempo real en TODOS los flujos de trabajo.
* La coordinación de rescate (Tareas 13-15) es compleja pero el 80% del valor está en el flujo "centinela crea alerta → auxiliar recibe notificación push". La navegación GPS y las actualizaciones de estado son pulido.

#### Pensamiento de Segundo Orden

* **Escalabilidad:** FCM maneja 100K+ notificaciones/día. La consulta de coincidencia de rescate (PostGIS dentro de 10km) necesita un índice espacial (GiST) o se degradará a escala.
* **Mantenimiento Futuro:** La máquina de estados de adopción agrega un 3er flujo de trabajo (junto con subsidios y reportes de abuso). Considerar abstraer un servicio genérico de flujo de trabajo/máquina de estados.
