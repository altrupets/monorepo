# Tareas: Flujo de Adopcion

**Change ID:** adoption-flow
**SRD Task:** T1-2 | **Linear:** ALT-14 | **Sprint:** 3 (v0.5.0)

---

## Backend

### Migraciones de Base de Datos

- [ ] **BE-01** Crear migracion: agregar `READY_FOR_ADOPTION` al enum `AnimalStatus` en tabla `animals`
- [ ] **BE-02** Crear migracion: agregar campos `size` (enum: SMALL/MEDIUM/LARGE), `ageCategory` (enum: PUPPY_KITTEN/YOUNG/ADULT/SENIOR), `isSterilized` (boolean) a tabla `animals`
- [ ] **BE-03** Crear migracion: tabla `adoption_listings` con todos los campos, FK a `animals`, `users`, `casas_cunas`, indice GIST en `location`, indice unique en `animalId`
- [ ] **BE-04** Crear migracion: tabla `adoption_applications` con todos los campos, FK a `adoption_listings` y `users`, constraint unique en (`listingId`, `applicantUserId`)

### Modulo de Adopciones

- [ ] **BE-05** Crear modulo `adoptions` (`apps/backend/src/adoptions/adoptions.module.ts`) con imports de TypeORM, AuthModule
- [ ] **BE-06** Crear entidad `AdoptionListing` (`adoptions/entities/adoption-listing.entity.ts`) con decoradores TypeORM + GraphQL
- [ ] **BE-07** Crear entidad `AdoptionApplication` (`adoptions/entities/adoption-application.entity.ts`) con decoradores TypeORM + GraphQL
- [ ] **BE-08** Actualizar entidad `Animal`: agregar `READY_FOR_ADOPTION` al enum, campos `size`, `ageCategory`, `isSterilized`

### Servicio de Listados

- [ ] **BE-09** Implementar `AdoptionsService.createListing()` — crear listado en DRAFT vinculado a animal
- [ ] **BE-10** Implementar `AdoptionsService.publishListing()` — validar animal tiene fotos y status READY_FOR_ADOPTION, transicionar a ACTIVE
- [ ] **BE-11** Implementar `AdoptionsService.pauseListing()` / `reactivateListing()` — transiciones ACTIVE <-> PAUSED
- [ ] **BE-12** Implementar `AdoptionsService.closeListing()` — cerrar como ADOPTED o WITHDRAWN, rechazar solicitudes pendientes, actualizar status del animal si es adopcion
- [ ] **BE-13** Implementar `AdoptionsService.updateListing()` — editar campos del listado (solo en DRAFT o ACTIVE)
- [ ] **BE-14** Implementar `AdoptionsService.findListings()` — query con filtros (especie, tamano, edad, booleanos, proximidad PostGIS), paginacion cursor-based, ordenamiento
- [ ] **BE-15** Implementar `AdoptionsService.findById()` — detalle de listado con relaciones (animal, casa cuna)
- [ ] **BE-16** Implementar `AdoptionsService.findMyListings()` — listados del rescatista autenticado

### Servicio de Solicitudes

- [ ] **BE-17** Implementar `AdoptionApplicationsService.submit()` — validar listado ACTIVE, max 1 por adoptante por listado, max 3 activas globales, crear en SUBMITTED
- [ ] **BE-18** Implementar `AdoptionApplicationsService.review()` — transicionar SUBMITTED -> IN_REVIEW, asignar reviewerUserId
- [ ] **BE-19** Implementar `AdoptionApplicationsService.scheduleVisit()` — transicionar IN_REVIEW -> VISIT_SCHEDULED con fecha
- [ ] **BE-20** Implementar `AdoptionApplicationsService.completeVisit()` — transicionar VISIT_SCHEDULED -> VISIT_COMPLETED con notas
- [ ] **BE-21** Implementar `AdoptionApplicationsService.approve()` — transicionar VISIT_COMPLETED -> APPROVED, cerrar listado como ADOPTED, rechazar otras solicitudes
- [ ] **BE-22** Implementar `AdoptionApplicationsService.reject()` — transicionar desde IN_REVIEW o VISIT_COMPLETED a REJECTED con razon
- [ ] **BE-23** Implementar `AdoptionApplicationsService.findByListing()` — solicitudes para un listado (con filtro de status)
- [ ] **BE-24** Implementar `AdoptionApplicationsService.findMyApplications()` — solicitudes del adoptante autenticado
- [ ] **BE-25** Implementar metodo privado `validateTransition(currentStatus, targetStatus)` — validar transiciones de estado permitidas

### Resolvers GraphQL

- [ ] **BE-26** Crear `AdoptionsResolver` con queries: `adoptionListings`, `adoptionListing`, `myAdoptionListings`
- [ ] **BE-27** Crear `AdoptionsResolver` con mutations: `createAdoptionListing`, `publishAdoptionListing`, `pauseAdoptionListing`, `reactivateAdoptionListing`, `closeAdoptionListing`, `updateAdoptionListing`
- [ ] **BE-28** Crear `AdoptionApplicationsResolver` con queries: `adoptionApplications`, `myAdoptionApplications`
- [ ] **BE-29** Crear `AdoptionApplicationsResolver` con mutations: `submitAdoptionApplication`, `reviewAdoptionApplication`, `scheduleVisit`, `completeVisit`, `approveAdoptionApplication`, `rejectAdoptionApplication`
- [ ] **BE-30** Aplicar `@UseGuards(JwtAuthGuard)` a todas las mutations y queries protegidas
- [ ] **BE-31** Crear DTOs de input: `CreateAdoptionListingInput`, `UpdateAdoptionListingInput`, `SubmitAdoptionApplicationInput`, `AdoptionListingFilter`, `PaginationInput`

### Tests Backend

- [ ] **BE-32** Tests unitarios para `AdoptionsService`: transiciones de estado validas e invalidas
- [ ] **BE-33** Tests unitarios para `AdoptionApplicationsService`: reglas de negocio (max solicitudes, transiciones, cierre en cascada)
- [ ] **BE-34** Tests de integracion: queries GraphQL con filtros y paginacion
- [ ] **BE-35** Tests de integracion: flujo completo DRAFT -> ACTIVE -> solicitud -> revision -> visita -> aprobacion

---

## Mobile

### Estructura de Feature

- [ ] **MO-01** Crear estructura del feature `adoptions` en `apps/mobile/lib/features/adoptions/`: carpetas `data/`, `domain/`, `presentation/`
- [ ] **MO-02** Crear entidades de dominio: `AdoptionListing`, `AdoptionApplication` con enums de estado
- [ ] **MO-03** Crear modelos de datos (serialization/deserialization desde GraphQL): `AdoptionListingModel`, `AdoptionApplicationModel`
- [ ] **MO-04** Crear repositorio: `AdoptionsRepository` con metodos para queries y mutations GraphQL
- [ ] **MO-05** Crear datasource remoto: `AdoptionsRemoteDataSource` con llamadas GraphQL

### Pantallas del Adoptante

- [ ] **MO-06** Implementar `AdoptionListingsPage` — galeria en grid de 2 columnas con scroll infinito (cursor-based), pull-to-refresh
- [ ] **MO-07** Implementar chips de especie (Perros/Gatos/Todos) como filtro rapido en la parte superior
- [ ] **MO-08** Implementar `AdoptionFiltersBottomSheet` — filtros avanzados: tamano, edad, compatible con ninos, mascotas, esterilizado, distancia (slider)
- [ ] **MO-09** Implementar `AdoptionListingCard` — card con foto, nombre, especie, edad, ubicacion
- [ ] **MO-10** Implementar `AdoptionListingDetailPage` — carrusel de fotos (PageView), datos del animal, temperamento (chips), descripcion, historial medico, requisitos, info de casa cuna, boton sticky "Solicitar Adopcion"
- [ ] **MO-11** Implementar `AdoptionApplicationFormPage` — formulario con secciones: hogar, familia, experiencia, contacto, motivacion. Validacion de campos requeridos.
- [ ] **MO-12** Implementar `MyApplicationsPage` — listado de solicitudes del adoptante con estado visual (color-coded badges)

### Pantallas del Rescatista

- [ ] **MO-13** Implementar `PublishAdoptionPage` — formulario para crear/editar listado: seleccionar animal, agregar fotos, temperamento, descripcion, requisitos
- [ ] **MO-14** Implementar `MyListingsPage` — listado de publicaciones del rescatista con filtro por estado
- [ ] **MO-15** Implementar `ListingApplicationsPage` — lista de solicitudes recibidas para un listado, resumen de cada solicitante
- [ ] **MO-16** Implementar `ApplicationDetailPage` — detalle completo de la solicitud, datos del hogar, experiencia, motivacion, notas del rescatista, botones de accion contextuales segun estado
- [ ] **MO-17** Implementar dialog de agendar visita con selector de fecha/hora
- [ ] **MO-18** Implementar dialog de rechazo con campo de razon obligatorio

### Providers y Estado

- [ ] **MO-19** Crear `AdoptionListingsProvider` (Riverpod) — estado de la galeria con filtros, paginacion, carga
- [ ] **MO-20** Crear `AdoptionApplicationProvider` (Riverpod) — estado del formulario de solicitud, envio, validacion
- [ ] **MO-21** Crear `RescuistListingsProvider` (Riverpod) — estado de los listados del rescatista y solicitudes recibidas

### Navegacion y Rutas

- [ ] **MO-22** Registrar rutas: `/adoptions`, `/adoptions/:id`, `/adoptions/:id/apply`, `/casa-cuna/animals/:id/publish`, `/casa-cuna/adoptions`, `/casa-cuna/adoptions/:id/review`, `/casa-cuna/adoptions/:appId`
- [ ] **MO-23** Agregar entrada "Adopciones" al tab de navegacion principal (visible para todos los roles)
- [ ] **MO-24** Agregar acceso a "Publicar para adopcion" desde la pantalla de detalle de animal en casa cuna

---

## Integracion

- [ ] **IN-01** Integrar notificacion push REQ-NOT-005: cuando se publica un listado, enviar push a adoptantes cuyas preferencias coinciden (especie, ubicacion)
- [ ] **IN-02** Integrar notificacion push: cuando se envia una solicitud, notificar al rescatista dueno del listado
- [ ] **IN-03** Integrar notificacion push: cambios de estado de solicitud (en revision, visita agendada, aprobada, rechazada) al adoptante
- [ ] **IN-04** Registrar modulo `AdoptionsModule` en `AppModule` (`apps/backend/src/app.module.ts`)
- [ ] **IN-05** Verificar que el flujo completo funciona end-to-end: publicar listado -> filtrar/navegar -> enviar solicitud -> revisar -> agendar visita -> aprobar -> animal pasa a ADOPTED

---

## Resumen de Esfuerzo

| Area | Tareas | Estimacion |
|------|--------|------------|
| Backend — Migraciones | BE-01 a BE-04 | 1 dia |
| Backend — Modulo y Entidades | BE-05 a BE-08 | 0.5 dia |
| Backend — Servicios | BE-09 a BE-25 | 3 dias |
| Backend — Resolvers y DTOs | BE-26 a BE-31 | 1.5 dias |
| Backend — Tests | BE-32 a BE-35 | 2 dias |
| Mobile — Estructura | MO-01 a MO-05 | 1 dia |
| Mobile — Adoptante | MO-06 a MO-12 | 3 dias |
| Mobile — Rescatista | MO-13 a MO-18 | 2.5 dias |
| Mobile — Providers y Rutas | MO-19 a MO-24 | 1.5 dias |
| Integracion | IN-01 a IN-05 | 1.5 dias |
| **Total** | **54 tareas** | **~17.5 dias (~3.5 semanas)** |

**Tamano estimado:** L (semanas) — consistente con la estimacion SRD.
