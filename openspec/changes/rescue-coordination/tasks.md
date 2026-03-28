# Tareas: Pipeline de Coordinacion de Rescate

**Change ID:** `rescue-coordination`
**SRD Task:** T1-1 | **Linear:** ALT-13 | **Sprint:** 3 (v0.5.0)

---

## Verificaciones Pre-vuelo

Antes de comenzar la implementacion, validar que las dependencias estan funcionales.

- [ ] **PF-1: Verificar PostGIS operativo**
  - Ejecutar `SELECT PostGIS_Version();` en la base de datos
  - Confirmar que la migracion `EnablePostGIS` esta aplicada
  - Verificar que `Animal.location` usa `geometry(Point, 4326)` correctamente

- [ ] **PF-2: Verificar entidad Animal existente**
  - Confirmar que `apps/backend/src/animals/entities/animal.entity.ts` tiene campo `location` con indice espacial
  - Confirmar relacion `Animal -> CasaCuna` via `casaCunaId`
  - Confirmar campo `rescuerId` en Animal

- [ ] **PF-3: Verificar auth/RBAC funcional**
  - Confirmar que `JwtAuthGuard` y `RolesGuard` protegen endpoints existentes
  - Confirmar que `UserRole` enum tiene CENTINELA, AUXILIAR, RESCATISTA
  - Verificar que `@GqlUser()` decorator inyecta el usuario autenticado

- [ ] **PF-4: Verificar schema GraphQL actual**
  - Revisar `apps/backend/schema.gql` para confirmar estructura de tipos existente
  - Confirmar que `createCaptureRequest` existe (referencia para patron de implementacion)

- [ ] **PF-5: Verificar build baseline**
  - `cd apps/backend && npm run build` compila sin errores
  - `cd apps/mobile && flutter analyze` pasa sin errores criticos
  - Tests existentes pasan: `cd apps/backend && npm run test`

---

## Fase 1: Backend — Entidad y Enums

- [ ] **BE-1: Crear enums de rescate**
  - Archivo: `apps/backend/src/rescues/enums/rescue-status.enum.ts`
  - Definir `RescueStatus`: CREATED, ASSIGNED, ACCEPTED, IN_PROGRESS, TRANSFERRED, COMPLETED, CANCELLED, REJECTED, EXPIRED
  - Archivo: `apps/backend/src/rescues/enums/rescue-urgency.enum.ts`
  - Definir `RescueUrgency`: LOW, MEDIUM, HIGH, CRITICAL
  - Registrar ambos como enums GraphQL con `registerEnumType`

- [ ] **BE-2: Crear entidad RescueAlert**
  - Archivo: `apps/backend/src/rescues/entities/rescue-alert.entity.ts`
  - Columnas: id, reportedById (FK User), auxiliarId (FK User nullable), rescuerId (FK User nullable), animalId (FK Animal nullable), location (geometry Point 4326), locationDescription, urgency (enum), description, imageUrls (simple-array), animalType, status (enum default CREATED), auxiliarPhotoUrls (simple-array nullable), conditionAssessment (text nullable), trackingCode (unique nullable), searchRadiusMeters (int default 10000), timestamps (createdAt, updatedAt, acceptedAt, transferredAt, completedAt, expiresAt)
  - Decoradores GraphQL `@ObjectType`, `@Field` en todas las columnas
  - Indice espacial `@Index({ spatial: true })` en location
  - Indices regulares en status, reportedById, auxiliarId, rescuerId

- [ ] **BE-3: Crear migracion de tabla rescue_alerts**
  - Archivo: `apps/backend/src/migrations/XXXXXX-CreateRescueAlerts.ts`
  - CREATE TABLE con todas las columnas y constraints
  - CREATE INDEX GiST en location
  - CREATE INDEX en status, reportedById, auxiliarId, rescuerId
  - Verificar: `npm run typeorm migration:run` ejecuta sin error

- [ ] **BE-4: Crear DTOs de entrada (inputs)**
  - `apps/backend/src/rescues/dto/create-rescue-alert.input.ts` — latitude, longitude, locationDescription?, urgency, description?, imageBase64s, animalType?
  - `apps/backend/src/rescues/dto/update-rescue-progress.input.ts` — alertId, conditionAssessment, imageBase64s?
  - `apps/backend/src/rescues/dto/complete-rescue.input.ts` — alertId, animalName, species, casaCunaId

---

## Fase 2: Backend — Maquina de Estados

- [ ] **BE-5: Implementar RescueStateMachine**
  - Archivo: `apps/backend/src/rescues/rescue-state-machine.ts`
  - Mapa de transiciones validas (ver design.md seccion 2)
  - Metodo `canTransition(currentStatus, targetStatus): boolean`
  - Metodo `transition(alert, targetStatus, actorId): RescueAlert` que:
    - Valida transicion
    - Actualiza status
    - Registra timestamp correspondiente (acceptedAt, transferredAt, completedAt)
    - Lanza excepcion si transicion invalida
  - Tests unitarios para todas las transiciones validas e invalidas

---

## Fase 3: Backend — Servicio de Matching por Proximidad

- [ ] **BE-6: Crear tabla user_locations (si no existe columna location en users)**
  - Evaluar: si `users` tiene columna `location`, usar esa. Si no, crear tabla `user_locations` con userId (FK), location (geometry Point), updatedAt
  - Migracion correspondiente con indice GiST
  - Alternativa: agregar columna `lastKnownLocation` a tabla `users` si se prefiere simplicidad

- [ ] **BE-7: Implementar RescueMatchingService**
  - Archivo: `apps/backend/src/rescues/rescue-matching.service.ts`
  - Metodo `findNearbyAuxiliares(lon, lat, radiusMeters)`:
    - Query PostGIS con `ST_DWithin` sobre location de usuarios con rol AUXILIAR
    - Excluir auxiliares actualmente ocupados (con alerta en estado ACCEPTED o IN_PROGRESS)
    - Ordenar por distancia ascendente
    - Retornar lista con userId, distancia en km, datos del usuario
  - Metodo `findAvailableRescuers(lon, lat, radiusMeters)`:
    - Query PostGIS con `ST_DWithin` sobre location de usuarios con rol RESCATISTA
    - JOIN con casa_cunas para verificar capacidad disponible (capacidad > animales actuales)
    - Ordenar por scoring simplificado: `(1/distancia) * 0.4 + capacidad * 0.4 + especializacion * 0.2`
    - Retornar lista con userId, distancia, casaCuna, capacidad disponible
  - Tests con datos mock de coordenadas

- [ ] **BE-8: Implementar mutacion updateMyLocation**
  - Agregar mutacion GraphQL `updateMyLocation(latitude, longitude)` en un resolver existente (users?) o en rescues
  - Guard: cualquier usuario autenticado
  - Actualiza la posicion actual del usuario para matching de proximidad
  - Rate limit: maximo 1 update por minuto por usuario

---

## Fase 4: Backend — Servicio y Resolvers

- [ ] **BE-9: Implementar RescueService**
  - Archivo: `apps/backend/src/rescues/rescues.service.ts`
  - `createAlert(input, userId)`:
    - Crear RescueAlert con status CREATED
    - Generar trackingCode unico (formato: `RSC-XXXXXX`)
    - Procesar imagenes base64 via storage service
    - Calcular expiresAt (createdAt + 15 minutos)
    - Llamar a matching service para encontrar auxiliares cercanos
    - Si hay auxiliares: transicionar a ASSIGNED, enviar push a cada uno
    - Si no hay auxiliares: mantener CREATED, programar escalacion
    - Retornar alerta creada
  - `acceptAlert(alertId, auxiliarId)`:
    - Validar que alerta esta en ASSIGNED
    - Transicionar a ACCEPTED via state machine
    - Asignar auxiliarId
    - Registrar acceptedAt
    - Enviar push al centinela
  - `rejectAlert(alertId, auxiliarId, reason)`:
    - Transicionar a REJECTED
    - Re-buscar auxiliares (excluir el que rechazo)
    - Si hay otro disponible: transicionar a ASSIGNED
    - Si no: esperar escalacion
  - `updateProgress(input, auxiliarId)`:
    - Validar que auxiliar es el asignado
    - Transicionar a IN_PROGRESS
    - Guardar fotos y evaluacion de condicion
    - Enviar push al centinela con update
  - `requestTransfer(alertId, auxiliarId)`:
    - Buscar rescatistas disponibles via matching service
    - Enviar push a rescatistas encontrados
  - `acceptTransfer(alertId, rescuerId)`:
    - Transicionar a TRANSFERRED
    - Asignar rescuerId
    - Enviar push al centinela y auxiliar
  - `completeRescue(input, rescuerId)`:
    - Crear entidad Animal vinculada a la alerta
    - Asignar animal a casaCuna seleccionada
    - Transicionar a COMPLETED
    - Enviar push a todos los participantes con trackingCode
  - `cancelAlert(alertId, userId, reason)`:
    - Validar que el usuario es el creador
    - Transicionar a CANCELLED
    - Notificar participantes activos
  - `escalateSearch(alertId)`:
    - Expandir searchRadiusMeters a 25000
    - Re-buscar auxiliares con radio expandido
    - Enviar push al nuevo set
    - Si aun sin auxiliares: notificar coordinador de organizacion

- [ ] **BE-10: Implementar RescuesResolver**
  - Archivo: `apps/backend/src/rescues/rescues.resolver.ts`
  - Mutations:
    - `createRescueAlert(input)` — Guard: JwtAuthGuard + Roles(CENTINELA, RESCATISTA)
    - `acceptRescueAlert(alertId)` — Guard: JwtAuthGuard + Roles(AUXILIAR)
    - `rejectRescueAlert(alertId, reason?)` — Guard: JwtAuthGuard + Roles(AUXILIAR)
    - `updateRescueProgress(input)` — Guard: JwtAuthGuard + Roles(AUXILIAR)
    - `requestRescueTransfer(alertId)` — Guard: JwtAuthGuard + Roles(AUXILIAR)
    - `acceptRescueTransfer(alertId)` — Guard: JwtAuthGuard + Roles(RESCATISTA)
    - `completeRescue(input)` — Guard: JwtAuthGuard + Roles(RESCATISTA)
    - `cancelRescueAlert(alertId, reason?)` — Guard: JwtAuthGuard
  - Queries:
    - `rescueAlert(id)` — Guard: JwtAuthGuard, verificar que usuario participa en la alerta
    - `myRescueAlerts(status?)` — Guard: JwtAuthGuard, filtrar por rol del usuario
    - `nearbyRescueAlerts(lat, lon, radiusKm?)` — Guard: JwtAuthGuard + Roles(AUXILIAR)
    - `availableRescuers(alertId, radiusKm?)` — Guard: JwtAuthGuard + Roles(AUXILIAR)
  - Field resolvers para relaciones: reportedBy, auxiliar, rescuer, animal

- [ ] **BE-11: Crear RescuesModule y registrar en AppModule**
  - Archivo: `apps/backend/src/rescues/rescues.module.ts`
  - Imports: TypeOrmModule.forFeature([RescueAlert]), PushNotificationsModule
  - Providers: RescueService, RescueMatchingService, RescueStateMachine
  - Resolver: RescuesResolver
  - Modificar `apps/backend/src/app.module.ts` para importar RescuesModule

---

## Fase 5: Backend — Notificaciones Push

- [ ] **BE-12: Crear entidad DeviceToken**
  - Archivo: `apps/backend/src/push-notifications/entities/device-token.entity.ts`
  - Columnas: id, userId (FK User), token (string), platform (android/ios/web), createdAt, updatedAt
  - Constraint UNIQUE(userId, token)

- [ ] **BE-13: Crear migracion de tabla user_device_tokens**
  - CREATE TABLE con constraint unique
  - Verificar migracion ejecuta correctamente

- [ ] **BE-14: Implementar PushNotificationService**
  - Archivo: `apps/backend/src/push-notifications/push-notification.service.ts`
  - Instalar `firebase-admin` si no esta instalado
  - Inicializar Firebase Admin SDK con service account (credenciales via Infisical/env)
  - Metodo `sendToUser(userId, payload)`: buscar tokens del usuario, enviar a todos sus dispositivos
  - Metodo `sendToUsers(userIds, payload)`: batch send a multiples usuarios
  - Manejar tokens invalidos: eliminar de la tabla si FCM retorna error de token invalido
  - DTO `RegisterDeviceTokenInput`: token, platform

- [ ] **BE-15: Crear PushNotificationsModule**
  - Archivo: `apps/backend/src/push-notifications/push-notifications.module.ts`
  - Exports: PushNotificationService (para uso en RescuesModule y futuros modulos)
  - Agregar mutacion `registerDeviceToken(input)` y `removeDeviceToken(token)` en un resolver
  - Guard: JwtAuthGuard para ambas mutaciones

- [ ] **BE-16: Implementar scheduler de escalacion**
  - Usar `@nestjs/schedule` con `@Cron('*/1 * * * *')` o Bull queue
  - Cada minuto: buscar alertas en estado ASSIGNED con `expiresAt < NOW()`
  - Para cada una: ejecutar `escalateSearch(alertId)`
  - Alternativa con Bull: al crear alerta, programar job con delay de 15 minutos

---

## Fase 6: Movil — Modelos y Repositorio

- [ ] **FE-1: Crear modelos de dominio**
  - Archivo: `apps/mobile/lib/features/rescues/domain/rescue_alert.dart`
  - Clase `RescueAlert` con todos los campos del tipo GraphQL
  - Archivo: `apps/mobile/lib/features/rescues/domain/rescue_status.dart`
  - Enum `RescueStatus` con valores correspondientes
  - Enum `RescueUrgency` con valores y colores asociados

- [ ] **FE-2: Crear queries y mutations GraphQL**
  - Archivo: `apps/mobile/lib/features/rescues/data/rescue_graphql_queries.dart`
  - Queries: `rescueAlertQuery`, `myRescueAlertsQuery`, `nearbyRescueAlertsQuery`, `availableRescuersQuery`
  - Mutations: `createRescueAlertMutation`, `acceptRescueAlertMutation`, `rejectRescueAlertMutation`, `updateRescueProgressMutation`, `requestRescueTransferMutation`, `acceptRescueTransferMutation`, `completeRescueMutation`, `cancelRescueAlertMutation`

- [ ] **FE-3: Crear repositorio de rescate**
  - Archivo: `apps/mobile/lib/features/rescues/data/rescue_repository.dart`
  - Metodos que ejecutan las queries/mutations via GraphQL client
  - Parsing de respuestas a modelos de dominio
  - Manejo de errores

---

## Fase 7: Movil — Pantallas de UI

- [ ] **FE-4: Refactorizar rescues_page.dart (lista principal)**
  - Modificar: `apps/mobile/lib/features/rescues/presentation/pages/rescues_page.dart`
  - Reemplazar cuadricula de stubs con:
    - Boton FAB "Crear Alerta de Auxilio" (visible solo para CENTINELA y RESCATISTA)
    - Lista de alertas activas del usuario (mis alertas)
    - Cada tarjeta muestra: urgencia (color), tipo animal, estado, distancia, tiempo transcurrido
    - Tab o filtro por estado: Activas / Completadas / Canceladas

- [ ] **FE-5: Crear pantalla de creacion de alerta**
  - Archivo: `apps/mobile/lib/features/rescues/presentation/pages/create_alert_page.dart`
  - Captura GPS automatica al abrir la pantalla (con paquete `geolocator`)
  - Mapa mostrando ubicacion actual (marcador rojo)
  - Selector de urgencia (LOW/MEDIUM/HIGH/CRITICAL) con colores
  - Campo de descripcion (text area)
  - Selector de tipo de animal (perro, gato, otro)
  - Boton de captura/seleccion de fotos (minimo 1, maximo 5)
  - Boton "Enviar Alerta" -> ejecuta mutation createRescueAlert
  - Loading state y confirmacion con trackingCode

- [ ] **FE-6: Crear pantalla de detalle de alerta**
  - Archivo: `apps/mobile/lib/features/rescues/presentation/pages/alert_detail_page.dart`
  - Header con urgencia, estado, trackingCode
  - Carrusel de fotos (centinela + auxiliar si hay)
  - Mapa con ubicacion del animal
  - Timeline de eventos (creada, asignada, aceptada, etc.) con timestamps
  - Informacion de participantes (centinela, auxiliar, rescatista) segun visibilidad
  - Acciones contextuales segun rol y estado:
    - Auxiliar + ASSIGNED: botones "Aceptar" / "Rechazar"
    - Auxiliar + ACCEPTED: boton "Navegar" (abre navigation page)
    - Auxiliar + IN_PROGRESS: boton "Solicitar Transferencia"
    - Rescatista + TRANSFERRED pending: botones "Aceptar Transferencia" / "Rechazar"
    - Centinela + CREATED/ASSIGNED: boton "Cancelar Alerta"

- [ ] **FE-7: Crear pantalla de navegacion**
  - Archivo: `apps/mobile/lib/features/rescues/presentation/pages/alert_navigation_page.dart`
  - Mapa a pantalla completa con:
    - Marcador de ubicacion del animal (destino)
    - Marcador de posicion actual del auxiliar (origen, actualizado en tiempo real)
    - Linea de ruta entre ambos puntos (via Directions API o linea recta como MVP)
  - Distancia restante y tiempo estimado
  - Boton "Llegue" que abre update_progress_page
  - Boton para abrir Google Maps/Waze como alternativa

- [ ] **FE-8: Crear pantalla de actualizacion de progreso**
  - Archivo: `apps/mobile/lib/features/rescues/presentation/pages/update_progress_page.dart`
  - Solo accesible por auxiliar con alerta en ACCEPTED
  - Campo de evaluacion de condicion (texto): estado general, heridas, comportamiento
  - Captura de fotos del animal en sitio (minimo 1)
  - Boton "Documentar y Continuar" -> mutation updateRescueProgress

- [ ] **FE-9: Crear pantalla de confirmacion de transferencia**
  - Archivo: `apps/mobile/lib/features/rescues/presentation/pages/transfer_confirmation_page.dart`
  - Solo accesible por rescatista cuando hay solicitud de transferencia
  - Resumen de la alerta: fotos originales + evaluacion del auxiliar
  - Selector de casa cuna (dropdown con casas cuna del rescatista y capacidad disponible)
  - Campo para nombre del animal
  - Selector de especie
  - Botones "Aceptar y Registrar" / "No puedo recibir"
  - Al aceptar: ejecuta mutation acceptRescueTransfer + completeRescue
  - Muestra trackingCode al completar

---

## Fase 8: Movil — State Management y Push

- [ ] **FE-10: Crear providers de Riverpod**
  - Archivo: `apps/mobile/lib/features/rescues/presentation/providers/rescue_providers.dart`
  - `rescueAlertProvider(id)`: FutureProvider para detalle de alerta por ID
  - `myRescueAlertsProvider`: FutureProvider para lista de mis alertas
  - `nearbyAlertsProvider(lat, lon)`: FutureProvider para alertas cercanas
  - `createRescueAlertProvider`: StateNotifier para flujo de creacion (loading, success, error)
  - Invalidacion automatica cuando se ejecuta una mutation

- [ ] **FE-11: Implementar servicio de push notifications**
  - Archivo: `apps/mobile/lib/core/services/push_notification_service.dart`
  - `initialize()`: configurar FirebaseMessaging, solicitar permisos
  - `requestPermission()`: solicitar permiso de notificaciones (Android 13+ y iOS)
  - `registerDeviceToken()`: obtener token FCM, enviar al backend via mutation registerDeviceToken
  - `onTokenRefresh()`: listener de rotacion de token, re-registrar automaticamente
  - `onForegroundMessage()`: mostrar notificacion local o snackbar in-app
  - `onMessageOpenedApp()`: navegar a la pantalla correspondiente segun data del push (deep link a `/rescues/alert/{id}`)
  - Integrar inicializacion en `main.dart`

- [ ] **FE-12: Implementar actualizacion periodica de ubicacion**
  - Usar paquete `geolocator` para obtener ubicacion en background
  - Frecuencia: cada 5 minutos cuando la app esta activa (foreground)
  - Enviar al backend via mutation `updateMyLocation`
  - Solo para usuarios con rol AUXILIAR o RESCATISTA (son los que necesitan ser encontrados)
  - Respetar permisos de ubicacion del dispositivo

---

## Fase 9: Integracion y Tests

- [ ] **INT-1: Test de integracion del flujo completo (backend)**
  - Crear test e2e que simule el flujo completo:
    1. Centinela crea alerta con GPS y fotos
    2. Sistema encuentra auxiliar cercano (mock de datos de ubicacion)
    3. Auxiliar acepta la alerta
    4. Auxiliar documenta al animal
    5. Auxiliar solicita transferencia
    6. Rescatista acepta transferencia
    7. Rescate completado con animal en casa cuna
  - Verificar transiciones de estado en cada paso
  - Verificar trackingCode generado

- [ ] **INT-2: Tests unitarios de RescueStateMachine**
  - Todas las transiciones validas retornan exito
  - Todas las transiciones invalidas lanzan excepcion
  - Timestamps se registran correctamente
  - Estado final no permite mas transiciones

- [ ] **INT-3: Tests unitarios de RescueMatchingService**
  - Mock de datos PostGIS
  - Verificar que auxiliares fuera de radio no aparecen
  - Verificar que auxiliares ocupados no aparecen
  - Verificar ordenamiento por distancia
  - Verificar que rescatistas sin capacidad no aparecen

- [ ] **INT-4: Tests de resolvers con guards**
  - Verificar que solo CENTINELA puede crear alertas
  - Verificar que solo AUXILIAR puede aceptar/rechazar
  - Verificar que solo RESCATISTA puede aceptar transferencia
  - Verificar que usuarios no autenticados son rechazados

- [ ] **INT-5: Verificar build y schema GraphQL**
  - `cd apps/backend && npm run build` compila sin errores
  - Schema generado incluye nuevos tipos, mutations y queries
  - `cd apps/mobile && flutter analyze` pasa sin errores
  - `cd apps/mobile && flutter build apk --debug` compila correctamente

---

## Fase 10: Verificacion Post-vuelo

- [ ] **PV-1: Verificar criterios de aceptacion del SRD J2**
  - [ ] Centinela crea alerta con GPS + fotos en <3 minutos
  - [ ] Auxiliares cercanos (10km) reciben push en <30 segundos
  - [ ] Auxiliar acepta y navega a la ubicacion GPS exacta
  - [ ] Auxiliar documenta al animal con fotos y evaluacion
  - [ ] Sistema encuentra rescatistas con espacio en 15km
  - [ ] Rescatista acepta transferencia y registra animal en casa cuna
  - [ ] Animal tiene codigo de seguimiento
  - [ ] Todos los participantes ven el estado actual

- [ ] **PV-2: Verificar que no se rompieron funcionalidades existentes**
  - `getCaptureRequests` sigue funcionando (endpoint legacy)
  - Auth flows no afectados
  - Tests existentes pasan
  - Schema GraphQL es backward-compatible (solo adiciones, sin cambios breaking)

- [ ] **PV-3: Revisar seguridad**
  - Todos los endpoints de rescate protegidos con JwtAuthGuard
  - RBAC aplicado correctamente por endpoint (CENTINELA, AUXILIAR, RESCATISTA)
  - No hay escalacion de privilegios (auxiliar no puede completar rescate)
  - Datos de ubicacion de usuarios solo accesibles via matching service (no expuestos directamente)

---

## Resumen de Archivos

| Accion | Ruta | Lineas est. |
|--------|------|-------------|
| Crear | `apps/backend/src/rescues/enums/rescue-status.enum.ts` | ~20 |
| Crear | `apps/backend/src/rescues/enums/rescue-urgency.enum.ts` | ~15 |
| Crear | `apps/backend/src/rescues/entities/rescue-alert.entity.ts` | ~120 |
| Crear | `apps/backend/src/rescues/dto/create-rescue-alert.input.ts` | ~25 |
| Crear | `apps/backend/src/rescues/dto/update-rescue-progress.input.ts` | ~15 |
| Crear | `apps/backend/src/rescues/dto/complete-rescue.input.ts` | ~15 |
| Crear | `apps/backend/src/rescues/rescue-state-machine.ts` | ~60 |
| Crear | `apps/backend/src/rescues/rescue-matching.service.ts` | ~100 |
| Crear | `apps/backend/src/rescues/rescues.service.ts` | ~200 |
| Crear | `apps/backend/src/rescues/rescues.resolver.ts` | ~120 |
| Crear | `apps/backend/src/rescues/rescues.module.ts` | ~25 |
| Crear | `apps/backend/src/push-notifications/entities/device-token.entity.ts` | ~35 |
| Crear | `apps/backend/src/push-notifications/push-notification.service.ts` | ~80 |
| Crear | `apps/backend/src/push-notifications/push-notifications.module.ts` | ~25 |
| Crear | `apps/backend/src/migrations/XXXXXX-CreateRescueAlerts.ts` | ~50 |
| Crear | `apps/backend/src/migrations/XXXXXX-CreateDeviceTokens.ts` | ~25 |
| Modificar | `apps/backend/src/app.module.ts` | ~5 |
| Crear | `apps/mobile/lib/features/rescues/domain/rescue_alert.dart` | ~60 |
| Crear | `apps/mobile/lib/features/rescues/domain/rescue_status.dart` | ~30 |
| Crear | `apps/mobile/lib/features/rescues/data/rescue_graphql_queries.dart` | ~100 |
| Crear | `apps/mobile/lib/features/rescues/data/rescue_repository.dart` | ~80 |
| Modificar | `apps/mobile/lib/features/rescues/presentation/pages/rescues_page.dart` | ~100 |
| Crear | `apps/mobile/lib/features/rescues/presentation/pages/create_alert_page.dart` | ~120 |
| Crear | `apps/mobile/lib/features/rescues/presentation/pages/alert_detail_page.dart` | ~150 |
| Crear | `apps/mobile/lib/features/rescues/presentation/pages/alert_navigation_page.dart` | ~100 |
| Crear | `apps/mobile/lib/features/rescues/presentation/pages/update_progress_page.dart` | ~80 |
| Crear | `apps/mobile/lib/features/rescues/presentation/pages/transfer_confirmation_page.dart` | ~100 |
| Crear | `apps/mobile/lib/features/rescues/presentation/providers/rescue_providers.dart` | ~50 |
| Crear | `apps/mobile/lib/core/services/push_notification_service.dart` | ~100 |
| Modificar | `apps/mobile/lib/main.dart` | ~10 |
| Crear | Tests backend (unit + integration) | ~300 |
| **Total** | | **~2,415** |
