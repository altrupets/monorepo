# Notificaciones Push — Tareas de Implementacion

**ID de Cambio**: `push-notifications`
**Tarea SRD**: T1-3 | **Linear**: ALT-15 | **Sprint**: 3 (v0.5.0)
**Estimacion total**: M (dias) | **Dependencias**: Configuracion de Firebase existe

---

## Fase 1: Infraestructura Backend (NestJS)

### 1.1 Configuracion de Firebase Admin SDK
- [ ] Instalar dependencia `firebase-admin` en `apps/backend/package.json`
- [ ] Instalar tipos `@types/firebase-admin` (si aplica) en devDependencies
- [ ] Agregar variable de entorno `FIREBASE_SERVICE_ACCOUNT_JSON` al `.env.example`
- [ ] Crear inicializacion de Firebase Admin en el modulo de notificaciones (`onModuleInit`)
- [ ] Verificar que la inicializacion no falle si las credenciales no estan configuradas (modo desarrollo)

### 1.2 Entidades de Base de Datos
- [ ] Crear entidad `DeviceToken` en `apps/backend/src/notifications/entities/device-token.entity.ts`
  - Campos: `id`, `userId`, `token`, `platform`, `isActive`, `createdAt`, `updatedAt`
  - Indice en `userId`, constraint unique en `(userId, token)`
  - Relacion `ManyToOne` con `User`
- [ ] Crear entidad `Notification` en `apps/backend/src/notifications/entities/notification.entity.ts`
  - Campos: `id`, `userId`, `type`, `title`, `body`, `data` (jsonb), `referenceId`, `referenceType`, `isRead`, `pushSent`, `pushSentAt`, `pushError`, `createdAt`
  - Indices en `userId`, `type`, `referenceId`, indice parcial en `(userId, isRead) WHERE isRead = false`
  - Relacion `ManyToOne` con `User`
- [ ] Crear enum `NotificationType` en `apps/backend/src/notifications/enums/notification-type.enum.ts`
  - Tipos: `RESCUE_ALERT`, `RESCUE_ACCEPTED`, `RESCUE_TRANSFERRED`, `SUBSIDY_CREATED`, `SUBSIDY_APPROVED`, `SUBSIDY_REJECTED`, `SUBSIDY_VET_ASSIGNED`, `ABUSE_REPORT_UPDATE`, `ABUSE_REPORT_FILED`, `CHAT_MESSAGE`
  - Registrar con `registerEnumType` para GraphQL
- [ ] Registrar ambas entidades en el array `entities` de `TypeOrmModule.forRootAsync` en `app.module.ts`
- [ ] Generar migracion TypeORM: `npm run migration:generate -- src/migrations/AddNotificationTables`
- [ ] Ejecutar migracion y verificar que las tablas se crean correctamente

### 1.3 NotificationsModule
- [ ] Crear `apps/backend/src/notifications/notifications.module.ts`
  - Imports: `TypeOrmModule.forFeature([Notification, DeviceToken])`, `UsersModule`
  - Providers: `NotificationService`, `NotificationsResolver`
  - Exports: `NotificationService` (para que otros modulos lo inyecten)
- [ ] Registrar `NotificationsModule` en `app.module.ts` imports

### 1.4 NotificationService
- [ ] Crear `apps/backend/src/notifications/notifications.service.ts`
- [ ] Implementar `registerToken(userId, token, platform)` — upsert del device token
- [ ] Implementar `unregisterToken(userId, token)` — desactivar token
- [ ] Implementar `sendToUser(params)` — persistir notificacion + enviar push a todos los dispositivos del usuario
- [ ] Implementar `sendToUsers(params)` — batch para multiples usuarios
- [ ] Implementar `sendToRole(params)` — buscar usuarios por rol (y jurisdiccion opcional), enviar a todos
- [ ] Implementar `sendPush(tokens, notification, data)` — logica de envio via `admin.messaging().sendEachForMulticast()`
- [ ] Implementar deduplicacion: verificar que no exista notificacion identica (userId + type + referenceId) en ventana de 60 segundos
- [ ] Implementar `deactivateTokens(tokens)` — marcar tokens invalidos como `isActive = false`
- [ ] Implementar `markAsRead(userId, notificationId)` — validar que la notificacion pertenece al usuario
- [ ] Implementar `markAllAsRead(userId)` — update masivo
- [ ] Implementar `getUserNotifications(userId, options)` — paginacion + conteo de no-leidas
- [ ] Implementar `cleanInvalidTokens()` con decorador `@Cron('0 3 * * *')` — eliminar tokens inactivos con mas de 30 dias

### 1.5 GraphQL Resolver
- [ ] Crear `apps/backend/src/notifications/notifications.resolver.ts`
- [ ] Crear DTOs GraphQL:
  - `RegisterDeviceTokenInput` (token, platform)
  - `NotificationObjectType` (mapeo de la entidad)
  - `NotificationPage` (notifications, total, unreadCount)
- [ ] Implementar mutacion `registerDeviceToken` — requiere `JwtAuthGuard`
- [ ] Implementar mutacion `unregisterDeviceToken` — requiere `JwtAuthGuard`
- [ ] Implementar query `myNotifications(page, limit, unreadOnly)` — requiere `JwtAuthGuard`
- [ ] Implementar mutacion `markNotificationRead(notificationId)` — requiere `JwtAuthGuard`
- [ ] Implementar mutacion `markAllNotificationsRead` — requiere `JwtAuthGuard`

### 1.6 Tests Unitarios Backend
- [ ] Tests para `NotificationService`:
  - `registerToken` — crea nuevo token, actualiza existente
  - `sendToUser` — persiste notificacion, llama a FCM, maneja errores
  - `sendToRole` — filtra usuarios por rol correctamente
  - `deduplicacion` — no envia duplicados dentro de ventana de 60s
  - `markAsRead` — solo permite marcar notificaciones propias
  - `cleanInvalidTokens` — elimina tokens inactivos
- [ ] Tests para `NotificationsResolver`:
  - Verifica que `JwtAuthGuard` esta aplicado en todas las operaciones
  - `myNotifications` retorna paginacion correcta
  - `registerDeviceToken` asocia al usuario autenticado

---

## Fase 2: Integracion con Modulos Existentes

### 2.1 SubsidiesModule (J4 — Estado de subsidio)
- [ ] Inyectar `NotificationService` en `SubsidiesService`
- [ ] Al crear solicitud de subsidio: enviar `SUBSIDY_CREATED` a `GOVERNMENT_ADMIN` de la jurisdiccion
- [ ] Al aprobar subsidio: enviar `SUBSIDY_APPROVED` al rescatista solicitante y al veterinario asignado
- [ ] Al rechazar subsidio: enviar `SUBSIDY_REJECTED` al rescatista solicitante con motivo
- [ ] Al asignar veterinario: enviar `SUBSIDY_VET_ASSIGNED` al veterinario con detalles del caso

### 2.2 CapturesModule (J2 — Alertas de rescate)
- [ ] Inyectar `NotificationService` en `CapturesService`
- [ ] Al crear solicitud de captura: enviar `RESCUE_ALERT` a auxiliares (`HELPER`) cercanos
  - Nota: requiere query de usuarios por proximidad (PostGIS o filtro por ubicacion almacenada)
  - Si PostGIS no esta disponible, filtrar por `latitude`/`longitude` del usuario con formula Haversine en SQL
- [ ] Al aceptar captura por auxiliar: enviar `RESCUE_ACCEPTED` al centinela creador
- [ ] Al transferir a rescatista: enviar `RESCUE_TRANSFERRED` al centinela y auxiliar

### 2.3 AbuseReportsModule (J5 — Actualizaciones de maltrato)
- [ ] Inyectar `NotificationService` en `AbuseReportsService`
- [ ] Al crear reporte de maltrato: enviar `ABUSE_REPORT_FILED` a `GOVERNMENT_ADMIN` de la jurisdiccion
- [ ] Al cambiar estado del reporte: enviar `ABUSE_REPORT_UPDATE` al usuario que creo el reporte

### 2.4 Chat/Mensajeria (J10 — Mensajes de chat)
- [ ] Definir punto de integracion con Firebase Firestore (listener backend o Cloud Function)
- [ ] Al detectar nuevo mensaje: enviar `CHAT_MESSAGE` a participantes de la conversacion (excepto el remitente)
- [ ] Incluir preview del mensaje (primeros 100 caracteres) y nombre del remitente en el payload

---

## Fase 3: Flutter Mobile

### 3.1 Servicio de Push Notifications
- [ ] Crear `apps/mobile/lib/features/notifications/services/push_notification_service.dart`
- [ ] Implementar `initialize()`:
  - Solicitar permisos de notificacion (`requestPermission`)
  - Obtener token FCM (`getToken`)
  - Registrar token en backend via mutacion GraphQL `registerDeviceToken`
  - Escuchar `onTokenRefresh` para re-registrar
- [ ] Implementar handler de foreground (`FirebaseMessaging.onMessage`)
  - Mostrar snackbar/banner local con titulo y cuerpo
  - Refrescar el provider de notificaciones para actualizar badge
- [ ] Implementar handler de background (`onBackgroundMessage`)
  - Funcion top-level con `@pragma('vm:entry-point')`
- [ ] Implementar handler de tap (`onMessageOpenedApp`)
  - Navegar a la pantalla correcta segun `data['route']` o `data['type']`
- [ ] Implementar handler de initial message (`getInitialMessage`)
  - Para cuando la app se abre desde una notificacion en estado terminated
- [ ] Implementar `dispose()` — desregistrar token al hacer logout

### 3.2 Configuracion de la App
- [ ] Invocar `PushNotificationService.initialize()` despues de `Firebase.initializeApp()` en `main.dart`
- [ ] Invocar `PushNotificationService.dispose()` en el flujo de logout (`AuthNotifier` o equivalente)
- [ ] Configurar canal de notificacion Android por defecto en `AndroidManifest.xml` (`altrupets_default`)
- [ ] Verificar/agregar `UIBackgroundModes: remote-notification` en `ios/Runner/Info.plist`

### 3.3 Capa de Datos (Repository + GraphQL)
- [ ] Crear `apps/mobile/lib/features/notifications/data/notification_repository.dart`
- [ ] Implementar mutacion GraphQL `registerDeviceToken(token, platform)`
- [ ] Implementar mutacion GraphQL `unregisterDeviceToken(token)`
- [ ] Implementar query GraphQL `myNotifications(page, limit, unreadOnly)` con paginacion
- [ ] Implementar mutacion GraphQL `markNotificationRead(notificationId)`
- [ ] Implementar mutacion GraphQL `markAllNotificationsRead`
- [ ] Crear modelo `NotificationModel` con Freezed para deserializacion

### 3.4 Capa de Presentacion (Riverpod + UI)
- [ ] Crear `NotificationNotifier` (Riverpod AsyncNotifier) en `apps/mobile/lib/features/notifications/providers/`
  - Exponer estado: lista de notificaciones, conteo de no-leidas, total
  - Metodos: `refresh()`, `markAsRead(id)`, `markAllAsRead()`, `loadMore()`
- [ ] Crear pantalla de centro de notificaciones (`NotificationsPage`) en `apps/mobile/lib/features/notifications/presentation/`
  - Lista de notificaciones con icono por tipo, titulo, cuerpo, fecha relativa
  - Indicador visual de leida/no-leida
  - Pull-to-refresh
  - Boton "Marcar todas como leidas"
  - Al tocar una notificacion: marcar como leida + navegar al destino
- [ ] Agregar badge de conteo de no-leidas en el icono de notificaciones del shell de navegacion (`HomeShellPage`)
- [ ] Registrar ruta `/notifications` en el router de la app

### 3.5 Tests Flutter
- [ ] Test unitario para `NotificationNotifier` — verifica estados de carga, refresh, markAsRead
- [ ] Test unitario para `NotificationRepository` — verifica construccion de queries GraphQL
- [ ] Test de widget para `NotificationsPage` — verifica renderizado de lista, badge, interacciones
- [ ] Test de deep-link — verifica navegacion correcta por tipo de notificacion

---

## Fase 4: Verificacion y QA

### 4.1 Tests de Integracion
- [ ] Verificar flujo completo: crear subsidio -> notificacion llega a coordinador municipal
- [ ] Verificar flujo completo: crear alerta de rescate -> notificacion llega a auxiliares
- [ ] Verificar flujo completo: actualizar reporte de maltrato -> notificacion llega al reportante
- [ ] Verificar que notificaciones de chat llegan a participantes (excepto remitente)
- [ ] Verificar deduplicacion: mismo evento no genera notificacion duplicada en 60s
- [ ] Verificar limpieza de tokens: tokens invalidos se desactivan tras error FCM

### 4.2 Verificacion de Criterios de Aceptacion SRD
- [ ] **J2 paso 4**: Auxiliares cercanos reciben push de alerta de rescate en <30 segundos
- [ ] **J4 paso 5**: Veterinario recibe notificacion de subsidio aprobado con detalles
- [ ] **J5 paso 5**: Centinela recibe actualizacion de estado de su reporte de maltrato
- [ ] **J10 paso 3**: Usuarios reciben push de nuevo mensaje de chat
- [ ] Verificar que al tocar la notificacion la app navega a la pantalla correcta (todos los tipos)
- [ ] Verificar que las notificaciones llegan en foreground (banner local) y background/terminated (push del OS)
- [ ] Verificar que el historial de notificaciones es consultable y paginado
- [ ] Verificar que los tokens FCM se registran al login y se eliminan al logout

### 4.3 Documentacion
- [ ] Documentar variable de entorno `FIREBASE_SERVICE_ACCOUNT_JSON` en el README del backend
- [ ] Agregar instrucciones de configuracion de Firebase para desarrollo local
- [ ] Documentar los tipos de notificacion y su enrutamiento en la API del backend (`API.md`)
