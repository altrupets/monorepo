# Propuesta: Pipeline de Coordinacion de Rescate

**Change ID:** `rescue-coordination`
**SRD Task:** T1-1
**Linear:** ALT-13
**Sprint:** 3 (v0.5.0)
**Etiquetas:** Feature, L, Team, Frontend, Backend, Database

---

## Que

Construir el pipeline completo de coordinacion de rescate que conecta a centinelas, auxiliares y rescatistas en un flujo de trabajo unificado: alerta del centinela, busqueda y notificacion de auxiliares cercanos, aceptacion y navegacion del auxiliar, documentacion del animal, busqueda de rescatistas con capacidad, transferencia al rescatista y registro en casa cuna.

El pipeline cubre los 10 pasos del Journey J2 del SRD, transformando la entidad `CaptureRequest` existente (basica, sin flujo de estados, sin auth guard) en un sistema completo de coordinacion con maquina de estados, matching por proximidad y notificaciones push.

---

## Por Que

### Impacto en valor

El pipeline de rescate es la **funcionalidad core de entrega de valor** de AltruPets. Sin ella, la plataforma es solo un sistema administrativo. El rescate coordinado es lo que demuestra a las municipalidades (clientes B2G) que la plataforma genera actividad real y resultados medibles (animales rescatados, adoptados, subsidiados).

- **Ingresos en riesgo:** $255/mes directos (J2 al 15%) + impacto indirecto en renovacion de contratos B2G
- **Personas afectadas:** P05 (Sofia, rescatista), P06 (Miguel, lider ONG), P07 (Andrea, centinela), P08 (Diego, auxiliar)
- **Dependencia downstream:** T1-2 (adopciones), T2-5 (reputacion), T2-6 (offline-first) dependen de este pipeline

### Estado actual

- `CaptureRequest` existe con 8 columnas basicas (lat, lon, description, animalType, status, imageUrl) pero sin flujo de estados, sin FK a userId con guard, sin urgencia
- `rescues_page.dart` en movil: cuadricula de 6 tarjetas de servicio, todas con `onTap: () {}` no-ops
- PostGIS habilitado (migracion `EnablePostGIS` completada, ALT-9 Done)
- Entidad `Animal` con campo `location` tipo geometry Point y relacion a `CasaCuna` (ALT-6 Done)
- Auth con JWT, guards y RBAC funcionando (ALT-7 Done)
- Firebase configurado en movil (`firebase_options.dart`, `firebase_messaging: ^15.2.4`) pero NO conectado al backend
- Roles `CENTINELA`, `AUXILIAR`, `RESCATISTA` definidos en el enum `UserRole` del schema GraphQL

### Prerequisito completados

| Dependencia | Estado | Descripcion |
|-------------|--------|-------------|
| T0-1 (ALT-6) | Done | Entidad Animal con PostGIS location |
| T0-2 (ALT-?) | Done | CRUD de Casa Cuna |
| T0-9 (ALT-9) | Done | Extension PostGIS habilitada |

---

## Alcance

### Incluido

1. **Backend — Modulo de rescate** (`apps/backend/src/rescues/`)
   - Entidad `RescueAlert` con maquina de estados (CREATED -> ASSIGNED -> ACCEPTED -> IN_PROGRESS -> TRANSFERRED -> COMPLETED -> CANCELLED)
   - Servicio `RescueService` con logica de negocio y transiciones de estado
   - Servicio `RescueMatchingService` con busqueda por proximidad PostGIS (auxiliares 10km, rescatistas 15km)
   - Resolvers GraphQL: mutations para crear alerta, aceptar, rechazar, actualizar estado, transferir
   - Queries GraphQL: alertas por estado, alertas cercanas, detalle de alerta
   - Migracion TypeORM para tabla `rescue_alerts`

2. **Backend — Integracion de notificaciones push**
   - Envio de push a auxiliares cercanos cuando se crea alerta (REQ-NOT-001)
   - Escalacion automatica a 25km si sin respuesta en 15 minutos (REQ-NOT-002 parcial)
   - Push a rescatistas cuando auxiliar solicita transferencia (REQ-NOT-003)
   - Push de actualizaciones de estado a todos los participantes

3. **Movil — Pantallas de rescate** (`apps/mobile/lib/features/rescues/`)
   - Pantalla de creacion de alerta: GPS automatico, carga de fotos, nivel de urgencia, descripcion
   - Pantalla de detalle de alerta: fotos, ubicacion, urgencia, participantes, estado
   - Pantalla de navegacion: mapa con ruta hacia la ubicacion del animal
   - Pantalla de actualizacion: documentacion del animal (fotos, evaluacion de condicion)
   - Pantalla de confirmacion de transferencia: aceptar/rechazar recepcion del animal
   - State management con Riverpod para el flujo de rescate

4. **Base de datos**
   - Tabla `rescue_alerts` con columnas de geometria PostGIS
   - Indices espaciales GiST para consultas de proximidad eficientes
   - FKs a `users` (reportedBy, auxiliarId, rescuerId) y `animals` (animalId)

### Excluido (fuera de alcance de T1-1)

- Chat vinculado a flujos de trabajo de rescate (T1-4, Sprint 4)
- Sistema de reputacion/calificacion (T2-5, Sprint 5)
- Modo offline-first (T2-6, Sprint 6)
- Actualizaciones en tiempo real via WebSocket (T1-4)
- Creacion automatica de solicitud de atencion veterinaria (depende del modulo de subsidios)

---

## Criterios de Aceptacion (del SRD Journey J2)

- [ ] El centinela crea alerta con GPS + fotos en <3 minutos
- [ ] Auxiliares cercanos (10km) reciben push en <30 segundos
- [ ] El auxiliar acepta y navega a la ubicacion GPS exacta
- [ ] El auxiliar documenta al animal con fotos y evaluacion
- [ ] El sistema encuentra rescatistas con espacio disponible en 15km
- [ ] El rescatista acepta la transferencia y recibe al animal
- [ ] Animal registrado en casa cuna con codigo de seguimiento
- [ ] Todos los participantes pueden ver el estado actual de la alerta

---

## Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Nadie disponible en radio de 10km | Alta (CR rural) | Bloquea rescate | Escalacion automatica a 25km + notificacion al coordinador de ONG |
| Latencia en consultas PostGIS a escala | Baja (MVP) | Degradacion de UX | Indice GiST + cache de ubicaciones activas |
| Permisos de notificaciones denegados (Android 13+) | Media | Auxiliar no se entera | Centro de notificaciones in-app como fallback + polling periodico |
| Complejidad del flujo de 10 pasos | Media | Bugs de estado | Maquina de estados explicita con transiciones validadas |

---

## Estimacion

- **Tamano:** L (semanas)
- **Estrategia de agente:** Team (3 companeros: backend, movil, integracion)
- **Backend:** ~450 lineas (entidad, servicio, matching, resolvers, migracion)
- **Movil:** ~500 lineas (5 pantallas, state management, servicios)
- **Tests:** ~300 lineas (unit + integration)
