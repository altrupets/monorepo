# Plan de Implementacion - AltruPets (8 Sprints)

**Version:** 0.3.0 (Sprint 1) -> 1.0.0 (Sprint 8)
**Duracion Total:** 6 meses | **Objetivo:** MVP funcional con revenue B2G ($10K MRR)
**Priorizado por:** SRD Framework (ver `srd/gap-audit.md`)

> **Nota:** Las tareas 1-10 originales (configuracion base, modelos, servicios core, auth basica, organizaciones, roles) fueron completadas y removidas. La numeracion continua desde la tarea 5a (auth hardening) y 11+.

> **Cambio de enfoque (SRD):** El orden original priorizaba coordinacion de rescate (value-delivery). El SRD identifica que el **subsidio veterinario municipal** y los **reportes de abuso** son los revenue drivers (#1 y #2). El rescue coordination pipeline es value-delivery, no revenue-critical. Se reorganizan los sprints para construir revenue primero.

---

## Indice de Sprints

1. [Sprint 1 (v0.3.0) - Foundation + Quick Wins](#sprint-1-v030---foundation--quick-wins)
2. [Sprint 2 (v0.4.0) - Revenue B2G: Subsidios + Reportes + Dashboard](#sprint-2-v040---revenue-b2g)
3. [Sprint 3 (v0.5.0) - Value Delivery: Rescate + Adopciones + Push](#sprint-3-v050---value-delivery)
4. [Sprint 4 (v0.6.0) - Ecosistema Vet + Donaciones](#sprint-4-v060---ecosistema-vet--donaciones)
5. [Sprint 5 (v0.7.0) - Retencion](#sprint-5-v070---retencion)
6. [Sprint 6 (v0.8.0) - Hardening](#sprint-6-v080---hardening)
7. [Sprint 7 (v0.9.0) - Infraestructura Cloud](#sprint-7-v090---infraestructura-cloud)
8. [Sprint 8 (v1.0.0) - Release Produccion](#sprint-8-v100---release-produccion)

---

# SPRINT 1 (v0.3.0) - Foundation + Quick Wins

**Duracion:** 2 semanas | **Prioridad:** CRITICA
**Objetivo:** Construir la base de datos y auth que desbloquea todo lo demas
**SRD Phase:** 1 (Foundation) | **Revenue at risk si no se completa:** $9,372/mo (todo)
**Tracks paralelos:** A (Animal + Casa Cuna), B (Auth), C (Vet Profile), D (PostGIS)

## Quick Wins (hacer PRIMERO, horas no dias)

> Codigo existente que solo necesita exponerse o corregirse. "Revenue gratis."

- [ ] QW-1. Agregar `@UseGuards(JwtAuthGuard)` a mutation `createCaptureRequest`
  - Archivo: `apps/backend/src/captures/captures.resolver.ts`
  - El mutation actualmente NO tiene auth guard — cualquiera puede crear capture requests
  - Fix: una linea
  - _SRD: Security gap identificado en codebase audit_

- [ ] QW-2. Agregar `userId` FK a tabla `capture_requests`
  - Crear migration TypeORM: agregar columna `reportedById` con FK a `users`
  - Actualizar `CaptureRequestEntity` con relacion `@ManyToOne`
  - _SRD: Data integrity — actualmente no se puede rastrear quien reporto_

- [ ] QW-3. Exponer `refreshToken()` existente como mutation GraphQL
  - El metodo `AuthService.refreshToken()` YA EXISTE en backend
  - Falta: agregar mutation en `auth.resolver.ts` que lo exponga
  - _SRD: T0-3 parcial, desbloquea token refresh en mobile_

- [ ] QW-4. Eliminar JWT secret hardcoded de fallback
  - Archivo: `apps/backend/src/auth/auth.module.ts`
  - Remover fallback `'super-secret-altrupets-key-2026'` — forzar uso de variable de entorno
  - _SRD: Security — secret por defecto en produccion = vulnerabilidad critica_

- [ ] QW-5. Conectar Redis adapter para cache
  - `REDIS_URL` ya esta configurado pero el adapter nunca se conecta (cae a in-memory)
  - Fix: wiring del adapter en `CacheModule` config
  - Impacto: refresh tokens sobreviven restart de pods
  - _SRD: Reliability — tokens se pierden en cada deploy_

## Track A: Entidad Animal + Gestion de Casa Cuna (T0-1, T0-2)

> Fundacion para TODO: subsidios, adopciones, rescates, donaciones, metricas municipales.

- [ ] A1. Crear entidad Animal con migration PostGIS-ready
  - Tabla `animals` con: id, species, breed, name, age_estimate, sex, weight, photos (JSON array), description, medical_notes, behavior_notes, adoptability_score, status (enum: IN_CARE, READY_FOR_ADOPTION, ADOPTED, TRANSFERRED, DECEASED)
  - Coordenadas como `decimal` (compatible con PostGIS futuro)
  - FK `fostered_by_id` -> users (rescatista), FK `organization_id` -> organizations
  - Timestamps: created_at, updated_at
  - _SRD: T0-1 | J6, J2, J3, J4 | $3,500/mo at risk_
  - _Requerimientos: 7.1, 7.2_

- [ ] A2. Crear entidad CasaCuna (Foster Home)
  - Tabla `foster_homes`: id, name, location (lat/lon), capacity, species_accepted (array), photos, description, is_active
  - FK `owner_id` -> users, FK `organization_id` -> organizations
  - _SRD: T0-2 parcial | J6_

- [ ] A3. Implementar CRUD de Casa Cuna + inventario de animales
  - GraphQL resolvers: createFosterHome, updateFosterHome, addAnimal, updateAnimal, removeAnimal
  - Queries: myFosterHomes, fosterHomeAnimals, fosterHomeCapacity
  - Mobile UI: reemplazar stub en `foster_homes_management_page.dart` con funcionalidad real
  - Incluir: registro con ubicacion GPS, fotos, capacidad, especies aceptadas
  - _SRD: T0-2 | J6 | P05, P06_
  - _Requerimientos: 7.1, 7.2, 7.3, 7.4_

- [ ] A4. Implementar lista de necesidades para donantes
  - Entidad `needs_list_items`: id, foster_home_id, category (FOOD, MEDICINE, SUPPLIES, TOYS, CASH), description, quantity, urgency (LOW, MEDIUM, HIGH), is_fulfilled
  - Resolver: publishNeedsList, fulfillNeed
  - Mobile UI: seccion "Lo que necesitamos" en perfil de casa cuna
  - Visible para donantes (P10) y publico desde perfil de organizacion
  - _SRD: T0-2 extension | Rule #10 (in-kind donations first-class) | J8_
  - _Requerimientos: 7.5, 7.6_

## Track B: Auth Hardening (T0-3)

> Silent revenue blocker — auth roto = todo roto.

- [ ] 5a. Implementar renovacion automatica de tokens JWT
  - Crear metodo publico `refreshToken()` en AuthService mobile (actualmente falta)
  - Implementar timer proactivo que renueve 5 min antes de expiracion
  - POST a mutation `refreshToken` (expuesto en QW-3)
  - Actualizar tokens en Secure Storage sin interrumpir operacion
  - Reintentos con backoff exponencial (1s, 2s, 4s) hasta 3 veces
  - Si renovacion falla: redirigir a login
  - _SRD: T0-3 | J1 | ALL personas_
  - _Requisitos: REQ-AUTH-006, REQ-AUTH-007_

- [ ] 5b. Implementar manejo de 401/403 en AuthInterceptor
  - En `onError()` para 401: intentar renovar token, reintentar request original con nuevo token
  - En `onError()` para 403: mostrar "Acceso denegado", NO intentar renovar
  - Reemplazar el actual `// TODO` en `auth_interceptor.dart`
  - _SRD: T0-3 | J1_
  - _Requisitos: REQ-AUTH-009, REQ-AUTH-010_

- [ ] 5c. Unificar sistemas de autenticacion duplicados
  - Actualmente coexisten `AuthService` (sealed class) y `AuthNotifier`/`AuthRepository` (Freezed)
  - Dos claves de token en secure storage (`auth_access_token` vs `auth_token`)
  - Consolidar en un solo flujo coherente
  - Crear `authServiceProvider` de Riverpod
  - Mover `currentUserProvider` de profile feature a auth feature
  - _SRD: T0-3 | J1_
  - _Requisitos: REQ-AUTH-013, REQ-AUTH-014_

- [ ] 5f. Implementar tests de autenticacion
  - Unit tests para AuthService (login, logout, refreshToken, lockout, session restore)
  - Unit tests para AuthInterceptor (401 retry, 403 handling)
  - Unit tests para GraphQLClientService (JWT expiry, session expired stream)
  - Integration test: flujo completo login -> uso -> token refresh -> logout
  - Cobertura minima 90% en AuthService
  - _SRD: T0-3 validacion_
  - _Requisitos: REQ-AUTH-001 a REQ-AUTH-014_

## Track C: Perfil Veterinario + Registro de Clinica (T0-8)

> Habilita el 20% de revenue (subscripciones de clinicas vet).

- [ ] C1. Implementar registro extendido de veterinarios y clinicas
  - Entidad `vet_profiles`: id, user_id, license_number, specialties (array), clinic_name, clinic_photos, clinic_hours (JSON), location (lat/lon), services_offered (array), pricing_tier (FREE, STANDARD, PREMIUM)
  - Formulario de registro con credenciales profesionales
  - Carga de licencias sanitarias
  - Configuracion de especialidades y tarifas preferenciales
  - Gestion de horarios de atencion
  - _SRD: T0-8 | J9 | P03, P04 | $1,000/mo at risk_
  - _Requerimientos: 8.1, 8.2_

## Track D: PostGIS para Consultas de Proximidad (T0-9)

> Habilita jurisdiccion automatica (subsidios), busqueda de vets/rescatistas cercanos, alertas.

- [ ] D1. Habilitar PostGIS y migrar coordenadas existentes
  - Instalar extension PostGIS en PostgreSQL
  - Migrar columnas lat/lon existentes (users, capture_requests) a tipo `geography(Point, 4326)`
  - Crear indice espacial GiST para consultas rapidas
  - Implementar funciones de proximidad: `ST_DWithin`, `ST_Distance`, `ST_Within`
  - _SRD: T0-9 | J2, J4, J5 | $2,000/mo at risk_

- [ ] D2. Implementar mapeo de jurisdicciones municipales
  - Tabla `jurisdictions`: id, municipality_name, tenant_id, boundary (polygon geometry)
  - Funcion: dado un punto GPS, retornar la jurisdiccion/municipalidad correspondiente
  - Query: `getJurisdictionByLocation(lat, lon)` -> jurisdiction con tenant_id
  - Esto habilita asignacion automatica de subsidios y reportes de abuso a la municipalidad correcta
  - _SRD: T0-9 extension | J4, J5 | Critico para B2G_

---

# SPRINT 2 (v0.4.0) - Revenue B2G

**Duracion:** 3 semanas | **Prioridad:** CRITICA
**Objetivo:** Construir los dos features que justifican contratos municipales: subsidio veterinario + reportes de abuso
**SRD Phase:** 2 + 3 (Revenue Paths A y B, en paralelo) | **Revenue at risk:** $6,825/mo
**Depende de:** Sprint 1 completado (Animal entity, PostGIS, Auth, Vet profile)

## Fase A: Workflow de Subsidio Veterinario Municipal (T0-4, T0-5)

> EL FEATURE MAS IMPORTANTE DE ALTRUPETS. $3,500/mo at risk. Sin esto, no hay contratos B2G.

- [ ] S1. Crear entidad SolicitudSubvencion y maquina de estados
  - Tabla `subsidy_requests`: id, animal_id, rescuer_id, vet_id, jurisdiction_id, municipality_tenant_id, estimated_cost, services_breakdown (JSON), procedure_date, status (CREATED, IN_REVIEW, APPROVED, REJECTED, EXPIRED), max_response_hours, expires_at, approved_by, rejection_reason, created_at, updated_at
  - Implementar maquina de estados con transiciones validas:
    - CREATED -> IN_REVIEW (cuando coordinador abre)
    - IN_REVIEW -> APPROVED | REJECTED (decision del coordinador)
    - CREATED -> EXPIRED (si pasa max_response_hours sin revision)
    - APPROVED -> INVOICED (cuando vet emite factura)
  - _SRD: T0-4 | J4 | P01-P06 | $3,500/mo_
  - _Requerimientos: REQ-FIN-VET-001 a REQ-FIN-VET-014_
  - _Referencia: design.md "Sistema de Subvencion Municipal" (interfaces TypeScript ya especificadas)_

- [ ] S2. Implementar creacion de solicitud de subsidio (mobile)
  - Formulario: seleccionar animal de casa cuna, procedimiento necesario, costo estimado, urgencia
  - Auto-deteccion de municipalidad por GPS del animal (usa jurisdiccion PostGIS de D2)
  - Seleccion de veterinario por proximidad (usa PostGIS)
  - Envio crea solicitud con status CREATED y asigna jurisdiction automaticamente
  - _SRD: T0-4 | J4 step 1-2_

- [ ] S3. Implementar revision y aprobacion de subsidios (web dashboard)
  - Dashboard web (Inertia.js, reemplazar stub `/b2g`):
    - Cola de solicitudes pendientes por jurisdiccion (multi-tenant)
    - Detalle de cada solicitud: animal, rescatista, vet, costo, urgencia
    - Botones: Aprobar (con asignacion de presupuesto) / Rechazar (con razon obligatoria)
  - Auto-expiracion: job que marca EXPIRED las solicitudes sin respuesta despues de `max_response_hours`
  - Notificacion al rescatista cuando cambia el estado
  - _SRD: T0-5 | J4 steps 3-4, J7 parcial | P01, P02_

- [ ] S4. Implementar recepcion de autorizacion por veterinario
  - Vet recibe notificacion de subsidio aprobado
  - Ve detalle: animal, monto autorizado, procedimiento, rescatista
  - Confirma aceptacion y programa fecha de atencion
  - _SRD: T0-4 extension | J4 step 5 | P03, P04_

## Fase B: Reportes de Abuso Animal (T0-6)

> Segundo revenue driver B2G. $1,425/mo at risk. Paralelo con Fase A.
> CAMBIO SRD: Los reportes REQUIEREN AUTENTICACION (no son anonimos). Rule #9.

- [ ] R1. Implementar formulario de reporte de abuso (mobile, REQUIERE AUTH)
  - Crear pantalla de reporte de abuso (requiere login)
  - Captura automatica de ubicacion GPS
  - Formulario: tipo de abuso (negligencia, maltrato fisico, abandono, acumulacion), descripcion detallada
  - Captura de evidencia fotografica (multiples fotos)
  - Al enviar: auto-asignar a municipalidad por GPS (usa jurisdicciones PostGIS de D2)
  - _SRD: T0-6 | J5 | P01, P02, P07 | $1,425/mo_
  - _Requerimientos: 3.1, 3.2_
  - _NOTA: Cambiado de "anonimo" a autenticado per SRD Rule #9_

- [ ] R2. Crear sistema de seguimiento de reportes
  - Generar codigo de seguimiento unico al crear reporte
  - Interfaz de consulta de estado usando codigo
  - Estados: FILED -> UNDER_REVIEW -> INVESTIGATING -> RESOLVED
  - Notificaciones de cambios de estado al reportante
  - _SRD: T0-6 | J5 steps 2, 5_
  - _Requerimientos: 3.3_

## Fase C: Municipal Dashboard (T0-7)

> Combina datos de subsidios + reportes de abuso. Standalone — muestra lo que haya disponible.

- [ ] G1. Implementar dashboard gubernamental (web)
  - Reemplazar stubs de Inertia en `/b2g` con dashboard funcional
  - KPIs jurisdiccionales: rescates, gastos en subsidios, reportes de abuso, tasa de adopcion, tiempos de respuesta
  - El dashboard muestra CUALQUIER dato disponible (Rule #7: nunca empty states)
  - Segregacion multi-tenant: cada municipalidad solo ve sus datos
  - _SRD: T0-7 | J7 | P01, P02 | $1,900/mo_
  - _Requerimientos: 2.4_
  - _MOVIDO de Sprint 5 a Sprint 2 por SRD (revenue blocker)_

- [ ] G2. Implementar gestion de reportes de abuso en dashboard
  - Clasificacion de reportes (negligencia, maltrato, abandono)
  - Asignar prioridad y investigador
  - Seguimiento de casos por jurisdiccion
  - _SRD: T0-7 extension | J5 step 4, J7_

---

# SPRINT 3 (v0.5.0) - Value Delivery

**Duracion:** 3 semanas | **Prioridad:** ALTA
**Objetivo:** Construir los flujos que crean contenido y actividad en la plataforma
**SRD Phase:** 5 (Value Delivery) | **Revenue at risk:** $1,135/mo
**Depende de:** Sprint 1 (Animal, Casa Cuna, PostGIS) + Sprint 2 parcial

## Fase D: Pipeline de Coordinacion de Rescate (T1-1)

> Value-delivery, NO revenue-critical (SRD Rule #6). Importante para engagement pero no bloquea B2G.

- [ ] 13. Implementar funcionalidades de sentinela
  - Crear formulario de solicitud de auxilio con geolocalizacion
  - Implementar captura de fotos del animal y descripcion
  - Agregar selector de nivel de urgencia
  - Crear interfaz de seguimiento de solicitudes enviadas
  - _SRD: T1-1 | J2 | P07_
  - _Requerimientos: 4.2, 4.3_

- [ ] 14. Crear sistema de matching y notificaciones para auxiliares
  - Implementar busqueda de auxiliares por proximidad (PostGIS, radio 10km)
  - Crear sistema de notificaciones push para alertas (Firebase)
  - Agregar interfaz de aceptacion/rechazo con justificacion
  - Implementar escalacion automatica si no hay respuesta
  - _SRD: T1-1 | J2 | P08_
  - _Requerimientos: 4.1, 4.2, 4.3_

- [ ] 15. Implementar funcionalidades de rescatista para coordinacion
  - Crear interfaz de solicitudes de rescate recibidas
  - Implementar navegacion GPS a ubicacion del rescate
  - Agregar formularios de actualizacion de estado del animal
  - Crear sistema de comunicacion directa con sentinelas via chat existente
  - _SRD: T1-1 | J2 | P05, P06_
  - _Requerimientos: 5.2, 5.3, 5.4, 5.5_

## Fase E: Sistema de Adopciones (T1-2)

> Independiente del rescue pipeline (SRD: J3 depende de J6, no de J2).

- [ ] AD1. Implementar publicacion de animales para adopcion
  - Rescatista marca animal como "Listo para Adopcion" desde inventario de casa cuna
  - Listing con: fotos, historial medico, temperamento, requisitos del hogar
  - Estado del animal cambia a READY_FOR_ADOPTION
  - _SRD: T1-2 | J3 step 1 | P05, P06_
  - _Requerimientos: REQ-RES-005_

- [ ] AD2. Crear galeria de adopciones con filtros
  - Pantalla browsable con listados de animales disponibles
  - Filtros: especie, tamano, edad, compatibilidad con ninos, ubicacion
  - Favoritos / guardados
  - _SRD: T1-2 | J3 step 2 | P09_
  - _Requerimientos: REQ-ADO-003_

- [ ] AD3. Implementar solicitud y screening de adopcion
  - Adoptante envia solicitud con cuestionario del hogar
  - Rescatista revisa, puede programar videollamada/visita
  - Flujo: PENDING_REVIEW -> VISIT_SCHEDULED -> VISIT_COMPLETED -> APPROVED / REJECTED
  - Al aprobar: animal cambia a ADOPTED, se genera registro de adopcion
  - _SRD: T1-2 | J3 steps 3-6 | P05, P06, P09_
  - _Requerimientos: REQ-ADO-003, REQ-RES-005_

## Fase F: Push Notifications (T1-3)

> MOVIDO de Sprint 8 a Sprint 3. Push es critico para alertas en tiempo real.

- [ ] 26. Implementar sistema de notificaciones push
  - Firebase Cloud Messaging: configuracion para Android/iOS
  - Notificaciones diferenciadas por tipo:
    - Rescatista: nuevo subsidio aprobado/rechazado, nueva solicitud de adopcion
    - Auxiliar: nueva alerta de auxilio cercana
    - Sentinela: actualizacion de estado de su reporte
    - Municipalidad: nuevo subsidio/reporte pendiente
    - Vet: nueva solicitud de subsidio asignada
  - Configuracion de preferencias de notificacion por usuario
  - Centro de notificaciones interno como fallback
  - _SRD: T1-3 | J2, J4, J5, J10 | ALL_
  - _Requerimientos: 12.1, 12.2, 12.3, 12.4_

## Fase G: Auth Complementario (T1-6)

- [ ] 5d. Implementar flujo de password reset
  - El boton "Olvidaste tu contrasena?" actualmente es no-op
  - Crear `ForgotPasswordPage` con envio de email
  - Crear mutation GraphQL para reset de contrasena
  - _SRD: T1-6 | J1_
  - _Requisitos: REQ-AUTH-UX-003_

- [ ] 5d-b. Implementar verificacion de email
  - Enviar email de verificacion al registrarse
  - Endpoint de confirmacion
  - Restricciones opcionales para usuarios no verificados
  - _SRD: T1-6 | J1_

---

# SPRINT 4 (v0.6.0) - Ecosistema Vet + Donaciones

**Duracion:** 2.5 semanas | **Prioridad:** ALTA
**Objetivo:** Completar flujo vet end-to-end y habilitar donaciones P2P
**SRD Phase:** 6 (Revenue Optimization) | **Depende de:** Sprint 2 (subsidio workflow)

## Fase H: Gestion de Pacientes Veterinarios (T1-5)

- [ ] 19. Crear sistema de solicitudes de atencion veterinaria
  - Busqueda de veterinarios por proximidad y especialidad (PostGIS)
  - Interfaz de solicitud de atencion urgente
  - Sistema de aceptacion/rechazo con justificacion
  - Derivacion entre veterinarios especializados
  - _SRD: T1-5 | J4, J9 | P03, P04_
  - _Requerimientos: 8.3, 8.4, 8.7_

- [ ] 20. Implementar registro de atencion medica
  - Formularios para diagnostico y tratamiento
  - Registro de medicamentos recetados
  - Historial medico completo por animal (vinculado a entidad Animal de A1)
  - _SRD: T1-5 | J4 step 6 | P03, P04_
  - _Requerimientos: 8.5, 8.6_

## Fase I: Facturacion Veterinaria (T1-7)

- [ ] V1. Implementar facturacion digital de subsidios
  - Vet genera factura digital con detalle de procedimiento y costos
  - Factura se envía a municipalidad para procesamiento de pago
  - Tracking de estado: SUBMITTED -> RECEIVED -> PAID
  - Auditoria completa del flujo solicitud -> aprobacion -> atencion -> factura -> pago
  - _SRD: T1-7 | J4 steps 7-8_

## Fase J: Donaciones Peer-to-Peer (T1-8)

> IMPORTANTE: AltruPets NUNCA toca los fondos. Donaciones son peer-to-peer.
> SUGEF compliance: sin intermediacion de fondos de terceros (Ley 7786, Arts. 15/15 bis).

- [ ] 23. Implementar sistema de donaciones P2P
  - Ver lista de necesidades de casa cuna (food, medicine, supplies — de tarea A4)
  - Seleccionar tipo de donacion: monetaria (SINPE/transferencia) o en especie
  - Para donaciones monetarias: mostrar datos bancarios de la org (SINPE, IBAN)
    - AltruPets NO procesa el pago — el donante lo hace directo
    - Donante confirma en app que envio la donacion
    - Org confirma recepcion
  - Para donaciones en especie: coordinar entrega/recogida via chat
  - Opcion de donaciones recurrentes (recordatorio mensual)
  - _SRD: T1-8 | J8 | P10, P06 | Rule #5 (never intermediate funds), Rule #10 (in-kind first-class)_
  - _Requerimientos: 9.1, 9.2, 9.3, 9.4_
  - _NOTA: Simplificado vs. original — sin PCI DSS propio, sin KYC para montos normales_

## Fase K: Integracion de Chat con Workflows (T1-4)

- [ ] 25. Integrar chat existente con workflows de rescate/subsidio/adopcion
  - Auto-crear sala de chat cuando se inicia un rescate (sentinela + auxiliar + rescatista)
  - Auto-crear sala cuando se inicia proceso de adopcion (rescatista + adoptante)
  - Vincular sala a caso/solicitud
  - Archivar automaticamente al completar caso
  - _SRD: T1-4 | J10 | ALL active_
  - _Requerimientos: 11.3, 11.4, 11.5, 11.6_
  - _NOTA: Chat base (Firebase Firestore) ya funciona parcialmente. Solo falta integracion con workflows._

## Fase L: Reportes de Transparencia (T1-9)

- [ ] 22. Crear sistema de reportes financieros y transparencia
  - Reportes configurables por periodo
  - Metricas de impacto: animales rescatados, adoptados, subsidiados, donaciones recibidas
  - Exportacion PDF y Excel
  - Disponible para municipalidades (dashboard) y organizaciones
  - _SRD: T1-9 | J7 | P01, P02_
  - _Requerimientos: 6.4, 6.5_

---

# SPRINT 5 (v0.7.0) - Retencion

**Duracion:** 2 semanas | **Prioridad:** MEDIA
**Objetivo:** Features que reducen churn y aumentan engagement
**SRD Phase:** 7 (Retention)

## Fase M: Adopcion Avanzada

- [ ] AD4. Implementar contratos digitales de adopcion con e-signature
  - Generar contrato PDF con datos del animal, rescatista, adoptante
  - Firma digital de ambas partes
  - Almacenar contrato firmado en el registro de adopcion
  - _SRD: T2-1 | J3 | P05, P06, P09_

- [ ] AD5. Implementar seguimiento post-adopcion automatizado
  - Notificaciones a 30, 60, 90 dias post-adopcion
  - Adoptante sube foto + actualizacion de estado
  - Rescatista confirma bienestar del animal
  - _SRD: T2-2 | J3 | P05, P06, P09_

## Fase N: Donor Impact + Vet Conversion

- [ ] DON1. Crear dashboard de impacto para donantes
  - Total donado, animales ayudados, historias especificas
  - Transparency score de cada organizacion
  - _SRD: T2-3 | J8 | P10_

- [ ] VET1. Implementar prompts de upgrade para clinicas vet
  - Cuando clinica procesa >5 subsidios/mes, mostrar prompt de upgrade
  - "Upgrade a Premium para aparecer primero en busquedas de rescatistas"
  - Flow de subscripcion via SINPE/tarjeta
  - _SRD: T2-4 | J9 | P03_

## Fase O: Reputacion y Calificaciones

- [ ] 27. Implementar sistema de calificaciones
  - Calificacion post-rescate, post-adopcion, post-atencion vet
  - Validacion de calificaciones autenticas
  - Expiracion automatica (3 meses)
  - Deteccion de patrones sospechosos
  - _SRD: T2-5 | J2, J3, J4_

- [ ] 28. Crear visualizacion de reputacion
  - Puntuacion visible en perfil
  - Historial de calificaciones
  - Priorizacion por reputacion en matching de proximidad
  - _SRD: T2-5_

---

# SPRINT 6 (v0.8.0) - Hardening

**Duracion:** 2 semanas | **Prioridad:** MEDIA
**Objetivo:** Seguridad avanzada, compliance, resiliencia

- [ ] 5e. Implementar deteccion de actividad sospechosa
  - Detectar multiples logins desde ubicaciones diferentes
  - Notificar al usuario mediante push
  - Permitir revocacion de sesiones activas
  - _Requisitos: REQ-AUTH-012, REQ-SEC-003_

- [ ] 24. Implementar KYC simplificado para donaciones de alto monto
  - Solo para donaciones >umbral definido por pais
  - Formularios de debida diligencia basicos
  - AltruPets NO procesa pagos — KYC es para compliance de orgs receptoras
  - _Requerimientos: 13.1, 13.2_
  - _NOTA: Simplificado vs. original — sin PCI DSS propio (no intermediamos fondos)_

- [ ] 31. Implementar funcionalidades offline-first
  - Sincronizacion automatica al recuperar conectividad
  - Cache local para datos criticos (inventario casa cuna, solicitudes pendientes)
  - Almacenamiento local de mensajes y ubicaciones
  - Indicadores de estado de conectividad
  - _SRD: T2-6 | J2_
  - _Requerimientos: 11.8, 10.3_

- [ ] 32. Implementar optimizaciones de performance
  - Lazy loading para listas grandes
  - Compresion automatica de imagenes
  - Cache de imagenes y datos frecuentes
  - Optimizar consultas GraphQL y reducir llamadas a API

---

# SPRINT 7 (v0.9.0) - Infraestructura Cloud

**Duracion:** 2 semanas | **Prioridad:** MEDIA
**Objetivo:** Desplegar infraestructura cloud (QA, STAGING, PROD)

- [ ] 33. Crear sistema de analytics y metricas
  - Tracking de eventos de usuario
  - Metricas de adopcion y uso de funcionalidades
  - Reportes de impacto del sistema
  - Deteccion de anomalias en uso

- [ ] 34. Implementar suite de testing completa
  - Unit tests para todos los servicios y modelos
  - Widget tests para componentes de UI criticos
  - Integration tests para flujos completos de usuario
  - Golden tests para consistencia visual

- [ ] 36. Configurar CI/CD y despliegue automatizado
  - Pipeline de build automatizado (parcialmente existe en GitHub Actions)
  - Configuracion de ambientes (QA, STAGING, PROD)
  - Tests automatizados en pipeline
  - Despliegue a stores (Google Play, App Store)

- [ ] 37. Implementar monitoreo y observabilidad
  - Logging estructurado y centralizado (parcialmente existe: Sentry)
  - Metricas de aplicacion y performance (parcialmente existe: Prometheus/Grafana)
  - Crash reporting y error tracking
  - Dashboards de monitoreo en tiempo real

---

# SPRINT 8 (v1.0.0) - Release Produccion

**Duracion:** 2 semanas | **Prioridad:** CRITICA
**Objetivo:** Testing final, seguridad y lanzamiento a produccion

- [ ] 35. Implementar testing de seguridad
  - Tests de validacion de encriptacion de datos sensibles
  - Tests de penetracion basicos
  - Validar que AltruPets no toca fondos en ningun flujo
  - _Requerimientos: 13.5, 13.6, 13.7_

- [ ] 38. Configurar seguridad de produccion
  - Certificate pinning para APIs
  - Ofuscacion de codigo para release
  - Deteccion de root/jailbreak
  - Rate limiting y proteccion DDoS

---

## Resumen de Tareas por Sprint (alineado con SRD)

| Sprint | Version | Foco | Duracion | Prioridad | SRD Phase | Revenue Impact |
|--------|---------|------|----------|-----------|-----------|----------------|
| 1 | v0.3.0 | Foundation: Animal + Auth + Vet + PostGIS | 2 sem | CRITICA | Phase 1 | Desbloquea todo |
| 2 | v0.4.0 | Revenue B2G: Subsidios + Abuso + Dashboard | 3 sem | CRITICA | Phase 2-4 | $6,825/mo |
| 3 | v0.5.0 | Value: Rescate + Adopcion + Push | 3 sem | ALTA | Phase 5 | $1,135/mo |
| 4 | v0.6.0 | Vet completo + Donaciones P2P + Chat | 2.5 sem | ALTA | Phase 6 | $672/mo |
| 5 | v0.7.0 | Retencion: Contratos + Impact + Reputacion | 2 sem | MEDIA | Phase 7 | Churn reduction |
| 6 | v0.8.0 | Hardening: Security + Offline + Perf | 2 sem | MEDIA | — | Reliability |
| 7 | v0.9.0 | Cloud: Testing + CI/CD + Monitoring | 2 sem | MEDIA | — | Deployability |
| 8 | v1.0.0 | Release: Security + Launch | 2 sem | CRITICA | — | Go-live |

---

## Mapeo SRD -> Tareas

| SRD Fix | Tarea(s) | Sprint |
|---------|----------|--------|
| QW-1..5 | QW-1 a QW-5 | Sprint 1 |
| T0-1 | A1 | Sprint 1 |
| T0-2 | A2, A3, A4 | Sprint 1 |
| T0-3 | 5a, 5b, 5c, 5f | Sprint 1 |
| T0-4 | S1, S2, S4 | Sprint 2 |
| T0-5 | S3 | Sprint 2 |
| T0-6 | R1, R2 | Sprint 2 |
| T0-7 | G1, G2 | Sprint 2 |
| T0-8 | C1 | Sprint 1 |
| T0-9 | D1, D2 | Sprint 1 |
| T1-1 | 13, 14, 15 | Sprint 3 |
| T1-2 | AD1, AD2, AD3 | Sprint 3 |
| T1-3 | 26 | Sprint 3 |
| T1-4 | 25 | Sprint 4 |
| T1-5 | 19, 20 | Sprint 4 |
| T1-6 | 5d, 5d-b | Sprint 3 |
| T1-7 | V1 | Sprint 4 |
| T1-8 | 23 | Sprint 4 |
| T1-9 | 22 | Sprint 4 |
| T2-1 | AD4 | Sprint 5 |
| T2-2 | AD5 | Sprint 5 |
| T2-3 | DON1 | Sprint 5 |
| T2-4 | VET1 | Sprint 5 |
| T2-5 | 27, 28 | Sprint 5 |
| T2-6 | 31 | Sprint 6 |

---

**Ultima actualizacion:** 3 de marzo de 2026
**Estado:** Sprint 1 en progreso (Tareas 1-10 completadas, auth hardening + foundation pendiente)
**Priorizado por:** SRD Framework v1 (`srd/gap-audit.md`)
