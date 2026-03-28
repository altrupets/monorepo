# Notificaciones Push — Propuesta de Cambio

**ID de Cambio**: `push-notifications`
**Tarea SRD**: T1-3
**Issue Linear**: ALT-15
**Sprint**: 3 (v0.5.0)
**Tamano**: M (dias)
**Recorridos**: J2, J4, J5, J10
**Ingresos en riesgo**: $500/mes
**Dependencias**: Configuracion de Firebase existe (`firebase_messaging: ^15.2.4` en pubspec.yaml)

---

## Problema

Actualmente la plataforma no tiene ningun mecanismo de notificaciones push. Los usuarios no reciben alertas en tiempo real sobre eventos criticos del sistema:

- **Rescatistas y auxiliares** no se enteran de nuevas alertas de auxilio cercanas (J2), lo que retrasa la respuesta a animales en riesgo.
- **Coordinadores municipales y veterinarios** no reciben notificaciones sobre cambios de estado en solicitudes de subsidio (J4), causando cuellos de botella administrativos.
- **Centinelas** no reciben actualizaciones sobre el estado de sus reportes de maltrato (J5), generando desconfianza en la plataforma.
- **Todos los usuarios activos** no reciben notificaciones de nuevos mensajes de chat (J10), rompiendo la comunicacion en tiempo real.

El SRD gap-audit clasifica esto como T1-3 (Entrega de Valor) con impacto en 4 recorridos criticos y $500/mes en ingresos en riesgo por atribucion de conversion.

## Solucion Propuesta

Implementar un sistema completo de notificaciones push basado en Firebase Cloud Messaging (FCM) con las siguientes capacidades:

1. **Backend (NestJS)**: Nuevo modulo `NotificationsModule` con servicio que integra Firebase Admin SDK para envio de notificaciones push segmentadas por rol y tipo de evento.
2. **Mobile (Flutter)**: Configuracion del receptor de notificaciones push con manejo de foreground, background y terminated state. Almacenamiento y gestion de FCM tokens.
3. **Enrutamiento basado en rol**: Logica de targeting que envia notificaciones solo a los usuarios relevantes segun su rol (`UserRole`) y ubicacion geografica.
4. **Centro de notificaciones**: Persistencia de notificaciones en base de datos como fallback para consulta historica.

## Alcance

### Incluido

- Registro y actualizacion de FCM device tokens por usuario
- Servicio backend de envio de push via Firebase Admin SDK
- 4 tipos de notificacion: alerta de rescate, estado de subsidio, actualizacion de maltrato, mensaje de chat
- Enrutamiento por rol (WATCHER, HELPER, RESCUER, VETERINARIAN, GOVERNMENT_ADMIN, etc.)
- Manejo de notificaciones en foreground, background y app terminada (Flutter)
- Navegacion deep-link al tocar la notificacion
- Entidad `Notification` para persistencia e historial
- Entidad `DeviceToken` para gestion de tokens FCM por usuario
- Mutaciones GraphQL: `registerDeviceToken`, `unregisterDeviceToken`, `markNotificationRead`
- Query GraphQL: `myNotifications` (paginado)

### Excluido

- Notificaciones de expansion de radio (REQ-NOT-002, REQ-NOT-008) — requiere T1-1 completado
- Notificaciones por email o SMS
- Preferencias granulares de notificacion por usuario (Sprint 5)
- Notificaciones de seguimiento post-adopcion (T2-2 — depende de T1-2 y T1-3)
- Topics de Firebase para broadcast masivo (se evaluara en Sprint 6)

## Personas Impactadas

| Persona | Rol | Notificaciones que recibe |
|---------|-----|--------------------------|
| P05 Sofia | RESCUER | Nuevo subsidio aprobado/rechazado, nueva solicitud de adopcion, mensajes |
| P06 Miguel | RESCUER | Igual que P05 |
| P07 Andrea | WATCHER | Actualizacion de estado de su reporte de maltrato |
| P08 Diego | HELPER | Nueva alerta de auxilio cercana, mensajes |
| P01 Gabriela | GOVERNMENT_ADMIN | Nuevo subsidio/reporte pendiente |
| P02 Laura | GOVERNMENT_ADMIN | Igual que P01 |
| P03 Dr. Carlos | VETERINARIAN | Nueva solicitud de subsidio asignada, mensajes |
| P04 Dra. Priscilla | VETERINARIAN | Igual que P03 |
| P09 Maria Elena | ADOPTER | Estado de solicitud de adopcion, mensajes |
| P10 Roberto | DONOR | Confirmacion de donacion recibida, mensajes |

## Criterios de Aceptacion

Derivados directamente de los recorridos SRD:

- [ ] Auxiliares cercanos reciben push de alerta de rescate en <30 segundos (J2, paso 4)
- [ ] Veterinario recibe notificacion de subsidio aprobado con detalles (J4, paso 5)
- [ ] Centinela recibe actualizacion de estado de su reporte de maltrato (J5, paso 5)
- [ ] Usuarios reciben push de nuevo mensaje de chat (J10, paso 3)
- [ ] Al tocar la notificacion, la app navega a la pantalla correcta via deep-link
- [ ] Las notificaciones llegan tanto en foreground como en background/terminated
- [ ] El historial de notificaciones es consultable desde la app
- [ ] Los tokens FCM se registran al login y se eliminan al logout

## Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Firebase Admin SDK no configurado en backend | Media | Alto | Agregar `firebase-admin` a dependencias y configurar service account como variable de entorno |
| Tokens FCM expirados o invalidos | Alta | Medio | Implementar limpieza automatica de tokens invalidos al recibir error de FCM |
| Notificaciones duplicadas por multiples dispositivos | Media | Bajo | Deduplicar por usuario + tipo + referencia con ventana de 60 segundos |
| Latencia en envio masivo (broadcast a zona) | Baja | Medio | Usar colas asincronas para envio batch; limitar a 500 tokens por llamada FCM |
