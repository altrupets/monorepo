# Recorridos Críticos — AltruPets

**Objetivo**: $10K MRR | **Recorridos**: 10 | **Ingresos Totales en Riesgo**: $9,372/mes (93.7%)

## Resumen de Puntuación de Recorridos

| ID | Recorrido | Personas | Etiqueta | Puntuación | Ingresos en Riesgo |
|----|---------|----------|-----|-------|-----------------|
| J1 | Descubrimiento -> Registro -> Incorporación | TODOS | Revenue-Critical | **60%** | $200/mes |
| J2 | Pipeline de Coordinación de Rescate | P05,P06,P07,P08 | Value-Delivery | **15%** | $255/mes |
| J3 | Ciclo de Vida de Adopción | P05,P06,P09 | Value-Delivery | **0%** | $200/mes |
| J4 | Solicitud y Aprobación de Subsidio Veterinario | P01-P06 | Revenue-Critical | **0%** | $3,500/mes |
| J5 | Reporte de Maltrato (Autenticado) | P01,P02,P06,P07 | Revenue-Critical | **5%** | $1,425/mes |
| J6 | Casa Cuna y Gestión Animal | P05,P06 | Value-Delivery | **10%** | $720/mes |
| J7 | Panel Municipal y Reportes | P01,P02 | Revenue-Critical | **5%** | $1,900/mes |
| J8 | Donación y Seguimiento de Impacto | P10,P06 | Value-Delivery | **8%** | $92/mes |
| J9 | Incorporación Clínica Veterinaria -> Premium | P03,P04 | Revenue-Critical | **0%** | $1,000/mes |
| J10 | Chat en Tiempo Real y Notificaciones | TODOS activos | Value-Delivery | **20%** | $80/mes |

## Grafo de Dependencia de Recorridos

```
J1 (Registro/Incorporación) <- RAÍZ para TODOS los flujos (incluidos reportes de maltrato)
  |
  +-- J6 (Gestión Casa Cuna) <- depende de J1
  |     +-- J3 (Adopción) <- depende de J1 + J6 (INDEPENDIENTE de J2)
  |     +-- J4 (Subsidio Veterinario) <- depende de J1 + J6 + J9 (INDEPENDIENTE de J2)
  |     +-- J8 (Donación) <- depende de J1 + J6 (necesita listados del inventario de casa cuna)
  |
  +-- J2 (Coordinación de Rescate) <- depende de J1 + J6 + J10
  |
  +-- J5 (Reportes de Maltrato) <- depende de J1 (REQUIERE AUTH, independiente de J2)
  |
  +-- J7 (Panel Municipal) <- depende de J1, INDEPENDIENTE (enriquecido por datos de J4/J5/J2)
  |
  +-- J9 (Incorporación Veterinaria) <- depende de J1, alimenta J4
  +-- J10 (Chat) <- depende de J1, mejora J2/J3/J4
```

**Dos caminos críticos paralelos hacia ingresos B2G:**
- **Camino A (subsidios)**: J1 -> J6 + J9 -> J4 (flujo de subsidio veterinario)
- **Camino B (reportes de maltrato)**: J1 -> J5 (reportes de maltrato)
- **Camino C (panel)**: J1 -> J7 (se lanza inmediatamente con cualquier dato disponible)

Los tres caminos pueden construirse en paralelo para el menor tiempo de entrega de valor.

---

## J1: Descubrimiento -> Registro -> Incorporación

**Puntuación: 60%** | **Personas**: TODOS | **Etiqueta de ingresos**: Revenue-Critical

| Paso | Acción del Usuario | Pantalla/Ruta | Qué Debe Suceder | Datos Requeridos |
|------|------------|-------------|------------------|---------------|
| 1 | Descarga la app desde la tienda | App Store / Play Store | La app se instala, la pantalla de inicio carga | Ninguno |
| 2 | Toca "Registrarse" | `/register` (`RegisterPage`) | Formulario de registro: nombre, correo, teléfono, contraseña, selección de rol | Ninguno |
| 3 | Llena el formulario, selecciona rol principal | `/register` | Validación del lado del cliente, hash dual SHA-256 de contraseña, mutación GraphQL `register` | Correo válido, teléfono, contraseña |
| 4 | Sesión iniciada automáticamente | -> `/home` (`HomeShellPage`) | JWT emitido, tokens almacenados en Secure Storage, redirección a inicio | Usuario backend + JWT |
| 5 | Completa perfil extendido | `/register-individual` | Selector de ubicación, carga de avatar, campos específicos del rol | Permiso GPS |
| 6 | Ve la pantalla de inicio apropiada para su rol | `/home` (navegación de 5 pestañas) | La barra de pestañas muestra secciones relevantes al rol | Rol del usuario en claims del JWT |

**Estado actual:**
- Pasos 1-4: **Funcional**. Login/registro, JWT, hash dual SHA-256 funcionando.
- Paso 5: **Funcional**. `RegisterIndividualOnboardingPage` existe.
- Paso 6: **Parcial**. El shell de inicio renderiza pero el contenido de rescate/mensajes está como placeholder.
- **Brechas**: Sin verificación de correo. El botón de restablecimiento de contraseña es un no-op. La renovación de token no está expuesta como mutación. Sistema dual de auth (`AuthService` sealed class + `AuthNotifier`/`AuthRepository`).

**Criterios de Aceptación:**
- [x] PASA: Registrarse con nombre/correo/teléfono/contraseña y rol
- [x] PASA: JWT emitido y almacenado de forma segura
- [ ] FALLA: Enlace de verificación de correo enviado (fix: T1-6)
- [ ] FALLA: "Olvidé mi contraseña" envía correo de restablecimiento (fix: T1-6)
- [ ] FALLA: Token se renueva automáticamente antes de expirar (fix: T0-3)
- [x] PASA: Pantalla de inicio apropiada al rol renderiza

---

## J2: Pipeline de Coordinación de Rescate

**Puntuación: 15%** | **Personas**: P07 (Centinela), P08 (Auxiliar), P05/P06 (Rescatista) | **Etiqueta de ingresos**: Value-Delivery

| Paso | Acción del Usuario | Pantalla/Ruta | Qué Debe Suceder | Datos Requeridos |
|------|------------|-------------|------------------|---------------|
| 1 | El centinela abre "Crear Alerta de Auxilio" | `/rescues/new-alert` [TBD] | Formulario: captura GPS automática, carga de fotos, nivel de urgencia, descripción | GPS, cámara |
| 2 | El centinela envía la solicitud de auxilio | GraphQL `createCaptureRequest` | Guardado con ubicación, fotos, urgencia. Estado -> `CREATED` | Centinela autenticado |
| 3 | El sistema encuentra auxiliares cercanos | Servicio de Geolocalización | Consulta en radio de 10km, ordenar por proximidad + calificación | PostGIS, datos de disponibilidad |
| 4 | El auxiliar recibe notificación push | Push -> `/rescues/alert/{id}` [TBD] | Push con detalles, fotos, distancia. Al tocar abre el detalle. | Token de Firebase |
| 5 | El auxiliar acepta y navega | `/rescues/alert/{id}/navigate` [TBD] | Estado -> `ACCEPTED`. Navegación GPS a la ubicación. | Integración de mapas |
| 6 | El auxiliar documenta al animal | `/rescues/alert/{id}/update` [TBD] | Carga de fotos, evaluación de condición. Estado -> `IN_PROGRESS` | Cámara |
| 7 | El sistema encuentra rescatistas cercanos con espacio | Servicio de Geolocalización | Consulta de rescatistas en 15km con capacidad disponible | PostGIS, datos de casa cuna |
| 8 | El rescatista acepta la transferencia | `/rescues/alert/{id}` [TBD] | Ver detalles + evaluación. Aceptar. Estado -> `TRANSFERRED` | Disponibilidad del rescatista |
| 9 | Animal registrado en casa cuna | `/casa-cuna/animals/new` [TBD] | Entidad animal creada con evaluación inicial, fotos, código de seguimiento | Entidad animal |
| 10 | Todos los participantes ven el estado | `/rescues/alert/{id}/status` [TBD] | Actualizaciones de estado en tiempo real. Código de seguimiento compartido. | WebSocket |

**Estado actual:**
- Paso 2: **Parcial** — `createCaptureRequest` existe pero falta guard de auth (brecha de seguridad), sin flujo de estados, sin FK `userId`.
- Pasos 1, 4-10: **Faltante** — Sin UI de creación de alertas, sin PostGIS, sin notificaciones push, sin lógica de asignación, sin entidad Animal.
- Móvil `rescues_page.dart`: Cuadrícula de tarjetas de servicio, todos `onTap: () {}` no-ops.

**Criterios de Aceptación:**
- [ ] FALLA: El centinela crea alerta con GPS + fotos en <3 minutos (fix: T0-1, T1-1)
- [ ] FALLA: Auxiliares cercanos reciben push en 30 segundos (fix: T1-1, T1-3)
- [ ] FALLA: El auxiliar navega a la ubicación GPS exacta (fix: T1-1)
- [ ] FALLA: El sistema muestra rescatistas con espacio disponible en 15km (fix: T0-9, T1-1)
- [ ] FALLA: Animal registrado con código de seguimiento al colocarse en hogar temporal (fix: T0-1, T0-2)
- [ ] FALLA: Todos los participantes rastrean el caso en tiempo real (fix: T1-4)

---

## J3: Ciclo de Vida de Adopción

**Puntuación: 0%** | **Personas**: P05/P06 (publican), P09 (aplica) | **Etiqueta de ingresos**: Value-Delivery

| Paso | Acción del Usuario | Pantalla/Ruta | Qué Debe Suceder | Datos Requeridos |
|------|------------|-------------|------------------|---------------|
| 1 | El rescatista marca al animal "Listo para Adopción" | `/casa-cuna/animals/{id}/publish` [TBD] | Listado con fotos, historial médico, temperamento, requisitos | Entidad animal |
| 2 | El adoptante navega los listados | `/adoptions` [TBD] | Galería filtrable: especie, tamaño, edad, compatible con niños, ubicación | Listados de adopción |
| 3 | El adoptante envía solicitud | `/adoptions/{id}/apply` [TBD] | Cuestionario del hogar, detalles familiares. Estado -> `PENDING_REVIEW` | Perfil del adoptante |
| 4 | El rescatista revisa la solicitud | `/casa-cuna/adoptions/{id}/review` [TBD] | Ver perfil del solicitante, respuestas. Agendar videollamada. | Solicitud + perfil |
| 5 | Visita/videollamada | Externa o en la app | Evaluar compatibilidad. Estado -> `VISIT_COMPLETED` | Programación |
| 6 | El rescatista aprueba | `/casa-cuna/adoptions/{id}/approve` [TBD] | Contrato digital generado y firmado. Estado -> `APPROVED` | Plantilla de contrato |
| 7 | Seguimiento (30/60/90 días) | Push -> `/adoptions/{id}/followup` [TBD] | Foto + actualización de estado del adoptante. El rescatista confirma bienestar. | Notificación |

**Estado actual**: Nada construido. Sin entidad de adopción, UI ni backend.

**Criterios de Aceptación:**
- [ ] FALLA: El rescatista publica animal con fotos e historial médico (fix: T1-2)
- [ ] FALLA: El adoptante navega y filtra listados (fix: T1-2)
- [ ] FALLA: El adoptante envía solicitud con cuestionario (fix: T1-2)
- [ ] FALLA: El rescatista revisa, agenda visita, aprueba/rechaza (fix: T1-2)
- [ ] FALLA: Contrato digital de adopción generado y firmado (fix: T2-1)
- [ ] FALLA: Seguimiento automatizado a 30/60/90 días (fix: T2-2)

---

## J4: Solicitud y Aprobación de Subsidio Veterinario

**Puntuación: 0%** | **Personas**: P05/P06 (solicitan), P03/P04 (tratan), P01/P02 (aprueban) | **Etiqueta de ingresos**: Revenue-Critical

| Paso | Acción del Usuario | Pantalla/Ruta | Qué Debe Suceder | Datos Requeridos |
|------|------------|-------------|------------------|---------------|
| 1 | El rescatista crea solicitud de subsidio | `/vet-subsidy/new` [TBD] | Formulario: animal, procedimiento, costo estimado, urgencia. Auto-detección de municipalidad por GPS. | Entidad animal, GPS, mapa de jurisdicción |
| 2 | El sistema asigna a la municipalidad | En segundo plano | GPS -> mapeo de jurisdicción. Enrutado al tenant correcto. Estado -> `CREATED` | Límites de jurisdicción PostGIS |
| 3 | El coordinador recibe la solicitud | Push -> `/subsidy/review/{id}` [TBD] | Solicitud con detalles del animal, estimación veterinaria, historial del rescatista. | Panel municipal |
| 4 | El coordinador aprueba/rechaza | `/subsidy/review/{id}` [TBD] | Aprobar con presupuesto o rechazar con motivo. Expiración automática si no hay respuesta. Estado -> `APPROVED`/`REJECTED` | Presupuesto, autoridad |
| 5 | El veterinario recibe autorización | Push -> `/vet/subsidy/{id}` [TBD] | Subsidio aprobado con monto autorizado, detalles del procedimiento. | Perfil veterinario |
| 6 | El veterinario realiza y registra el tratamiento | `/vet/patients/{animalId}/treatment` [TBD] | Expediente médico: diagnóstico, tratamiento, medicamentos, fotos. Factura generada. | Entidad de expediente médico |
| 7 | El veterinario envía la factura | `/vet/subsidy/{id}/invoice` [TBD] | Factura digital enviada a la municipalidad. | Entidad de factura |
| 8 | La municipalidad procesa el pago | `/subsidy/{id}/payment` [TBD] | Confirmación de pago. Estado -> `PAID`. Pista de auditoría completa. | Pago municipal |

**Estado actual**: Nada construido. Ampliamente especificado en `design.md` (interfaces TypeScript, estados de flujo de trabajo, clase de motor) pero cero implementación.

**Criterios de Aceptación:**
- [ ] FALLA: El rescatista crea solicitud de subsidio en <5 minutos (fix: T0-4)
- [ ] FALLA: El sistema asigna automáticamente a la municipalidad correcta por GPS (fix: T0-9, T0-4)
- [ ] FALLA: El coordinador aprueba/rechaza dentro de la app (fix: T0-5)
- [ ] FALLA: Expiración automática si no hay respuesta en las horas configuradas (fix: T0-4)
- [ ] FALLA: El veterinario recibe autorización y registra el tratamiento (fix: T0-8, T1-5)
- [ ] FALLA: Factura digital enviada y rastreada hasta el pago (fix: T1-7)
- [ ] FALLA: Pista de auditoría completa desde la solicitud hasta el pago (fix: T0-4)

---

## J5: Reporte de Maltrato (Autenticado)

**Puntuación: 5%** | **Personas**: P07, P01, P02, P06 | **Etiqueta de ingresos**: Revenue-Critical

| Paso | Acción del Usuario | Pantalla/Ruta | Qué Debe Suceder | Datos Requeridos |
|------|------------|-------------|------------------|---------------|
| 1 | El usuario abre el formulario de reporte de maltrato (inicio de sesión requerido) | `/report-abuse` [TBD] | Formulario: GPS, fotos, descripción, tipo de maltrato. Debe estar autenticado. | Auth, GPS, cámara |
| 2 | Envía y recibe código de seguimiento | `/report-abuse/confirmation` [TBD] | Código de seguimiento único generado. Reporte guardado. Estado -> `FILED` | Usuario autenticado |
| 3 | El sistema enruta a la jurisdicción | En segundo plano | GPS -> jurisdicción municipal. El reporte aparece en el panel. | Límites de jurisdicción |
| 4 | El funcionario municipal revisa/clasifica | `/b2g/reports/{id}` [TBD] | Categorizar (negligencia, maltrato, abandono), asignar prioridad, asignar investigador. | Panel municipal |
| 5 | Estado visible vía código de seguimiento | `/report-abuse/track/{code}` [TBD] | Verificar estado: Presentado -> En Revisión -> Investigado -> Resuelto. | Código de seguimiento |
| 6 | Resolución del caso y métricas | Panel municipal | Caso cerrado con resultado. Métricas agregadas. | Datos de resolución |

**Estado actual**: La entidad `CaptureRequest` (8 columnas) no está diseñada para reportes de maltrato. El controlador B2G tiene 3 stubs de Inertia sin datos. Sin formulario móvil de reporte de maltrato.

**Criterios de Aceptación:**
- [ ] FALLA: Usuario autenticado presenta reporte de maltrato con GPS + fotos en <3 minutos (fix: T0-6)
- [ ] FALLA: Código de seguimiento emitido inmediatamente (fix: T0-6)
- [ ] FALLA: Reporte se enruta automáticamente a la municipalidad correcta por GPS (fix: T0-9)
- [ ] FALLA: El funcionario municipal revisa, clasifica y da seguimiento a reportes (fix: T0-7)
- [ ] FALLA: El usuario verifica el estado usando el código de seguimiento (fix: T0-6)

---

## J6: Casa Cuna y Gestión Animal

**Puntuación: 10%** | **Personas**: P05, P06 | **Etiqueta de ingresos**: Value-Delivery

| Paso | Acción del Usuario | Pantalla/Ruta | Qué Debe Suceder | Datos Requeridos |
|------|------------|-------------|------------------|---------------|
| 1 | Registrar casa cuna | `/profile/foster-homes` (stub existe) | Ubicación, capacidad, especies aceptadas, fotos | GPS, entidad |
| 2 | Agregar animal | `/casa-cuna/animals/new` [TBD] | Perfil: especie, raza, edad, fotos, evaluación médica inicial | Entidad animal |
| 3 | Actualizar estado del animal | `/casa-cuna/animals/{id}` [TBD] | Notas médicas, peso, comportamiento, puntaje de adoptabilidad | Entidad animal |
| 4 | Gestionar capacidad | `/profile/foster-homes` | Inventario actual, espacios disponibles, lista de necesidades para donantes | Casa cuna + animales |
| 5 | Publicar lista de necesidades | `/casa-cuna/needs` [TBD] | Comida, medicina, suministros, juguetes necesarios. Visible para donantes (P10). | Entidad de lista de necesidades |

**Estado actual**: `foster_homes_management_page.dart` existe como shell de UI con botones pero sin llamadas al backend. Sin entidad Animal en la BD.

**Criterios de Aceptación:**
- [ ] FALLA: Registrar hogar temporal con ubicación y capacidad (fix: T0-2)
- [ ] FALLA: Agregar/eliminar animales con fotos y notas médicas (fix: T0-1, T0-2)
- [ ] FALLA: Vista de inventario muestra animales actuales y espacios disponibles (fix: T0-2)
- [ ] FALLA: Lista de necesidades publicada y visible para donantes (fix: T0-2)

---

## J7: Panel Municipal y Reportes

**Puntuación: 5%** | **Personas**: P01, P02 | **Etiqueta de ingresos**: Revenue-Critical

| Paso | Acción del Usuario | Pantalla/Ruta | Qué Debe Suceder | Datos Requeridos |
|------|------------|-------------|------------------|---------------|
| 1 | Iniciar sesión en el panel web | `/b2g` (stub de Inertia existe) | Inicio de sesión seguro, aislamiento multi-tenant, alcance por jurisdicción | JWT + tenant |
| 2 | Ver resumen de actividad | `/b2g/dashboard` [TBD] | KPIs: conteo de rescates, gasto en subsidios, reportes de maltrato, tasa de adopción | Métricas agregadas |
| 3 | Revisar elementos pendientes | `/b2g/captures` (stub existe) | Subsidios pendientes + reportes de maltrato con urgencia y montos | Datos de entidades |
| 4 | Generar reporte de transparencia | `/b2g/reports` [TBD] | Configurable por rango de fechas, selección de métricas, exportar PDF/Excel | Motor de reportes |

**Estado actual**: 3 stubs de rutas Inertia (`/b2g`, `/b2g/captures`, `/b2g/captures/:id`) renderizan shells vacíos.

**Criterios de Aceptación:**
- [ ] FALLA: El panel muestra KPIs con alcance de jurisdicción a partir de datos disponibles (fix: T0-7)
- [ ] FALLA: La cola de elementos pendientes es accionable (aprobar/rechazar en línea) (fix: T0-5)
- [ ] FALLA: Reporte de transparencia exportable como PDF (fix: T1-9)

---

## J8: Donación y Seguimiento de Impacto

**Puntuación: 8%** | **Personas**: P10, P06 | **Etiqueta de ingresos**: Value-Delivery

| Paso | Acción del Usuario | Pantalla/Ruta | Qué Debe Suceder | Datos Requeridos |
|------|------------|-------------|------------------|---------------|
| 1 | Encontrar perfil de organización de rescate | `/organizations/{id}` (existe) | Perfil de la org con misión, animales, lista de necesidades, puntaje de transparencia | Entidad org (existe) |
| 2 | Ver lista de necesidades | `/organizations/{id}/needs` [TBD] | Necesidades actuales de la org: comida, medicina, suministros, montos en efectivo | Lista de necesidades de J6 |
| 3 | Iniciar donación | `/donate/{orgId}` [TBD] | Seleccionar tipo (efectivo/en especie), monto/artículos. Redirigir a SINPE/banco (persona a persona). | Datos bancarios de la org |
| 4 | Confirmar donación en la app | `/donate/{orgId}/confirm` [TBD] | Marcar como enviada. La org confirma recepción. Registrada en la plataforma. | Registro de donación |
| 5 | Ver reporte de impacto | `/donor/impact` [TBD] | Panel: total donado, animales ayudados, historias específicas | Datos de impacto |

**Estado actual**: Infraestructura de pasarela de pago existe (4 implementaciones). Perfiles de organizaciones existen. Sin UI de donación, entidad, ni seguimiento de impacto.

**Criterios de Aceptación:**
- [ ] FALLA: El donante ve la lista de necesidades de la org (efectivo + en especie) (fix: T0-2 lista de necesidades)
- [ ] FALLA: Donación persona a persona sin que AltruPets toque fondos (fix: T1-8)
- [ ] FALLA: Donación registrada en la plataforma (fix: T1-8)
- [ ] FALLA: Reporte de impacto muestra animales ayudados por donación (fix: T2-3)

---

## J9: Incorporación Clínica Veterinaria -> Conversión Premium

**Puntuación: 0%** | **Personas**: P03, P04 | **Etiqueta de ingresos**: Revenue-Critical

| Paso | Acción del Usuario | Pantalla/Ruta | Qué Debe Suceder | Datos Requeridos |
|------|------------|-------------|------------------|---------------|
| 1 | Registrarse con credenciales | `/register` (existe, selección de rol) | Extendido: licencia, especialidades, info de clínica, ubicación | Entidad de perfil veterinario |
| 2 | Completar perfil de clínica | `/vet/clinic/setup` [TBD] | Nombre, horario, servicios, precios, fotos, pin en mapa | Entidad de clínica veterinaria |
| 3 | Recibir primera solicitud de subsidio | Push -> `/vet/subsidy/{id}` [TBD] | Subsidio con detalles del animal, monto autorizado, info del rescatista | J4 funcionando |
| 4 | Se muestra propuesta de mejora | Mensaje dentro de la app | "5+ casos subsidiados este mes. Mejora para posicionamiento preferente." | Seguimiento de uso |
| 5 | Suscribirse al plan de pago | `/vet/clinic/subscription` [TBD] | Pago vía SINPE/tarjeta. Suscripción activada. Premium desbloqueado. | Pago |

**Estado actual**: El registro tiene el rol de Veterinario. Nada más construido.

**Criterios de Aceptación:**
- [ ] FALLA: Registrarse con credenciales profesionales e info de clínica (fix: T0-8)
- [ ] FALLA: Aparece en búsquedas por proximidad para rescatistas (fix: T0-8, T0-9)
- [ ] FALLA: Propuesta de mejora basada en uso al alcanzar el umbral (fix: T2-4)
- [ ] FALLA: Suscribirse al plan de pago vía SINPE/tarjeta (fix: T1-16)

---

## J10: Chat en Tiempo Real y Notificaciones

**Puntuación: 20%** | **Personas**: TODOS activos | **Etiqueta de ingresos**: Value-Delivery

| Paso | Acción del Usuario | Pantalla/Ruta | Qué Debe Suceder | Datos Requeridos |
|------|------------|-------------|------------------|---------------|
| 1 | Un evento dispara una sala de chat | Automático | Evento de rescate/subsidio/adopción crea chat con participantes | Entidad Firebase |
| 2 | Intercambiar mensajes | `/messages/{chatId}` (parcialmente existe) | Texto en tiempo real, fotos, compartir GPS. Acuses de lectura. | Firebase |
| 3 | Notificaciones push | Push del sistema | Notificación con vista previa, al tocar abre la conversación | Firebase Messaging |
| 4 | Archivar al completar | Automático | Caso se cierra -> chat archivado y vinculado al historial del caso | Estado del caso |

**Estado actual**: Mensajería con Firebase Firestore parcialmente implementada. Deep links existen. No integrada con flujos de trabajo. Sin notificaciones push.

**Criterios de Aceptación:**
- [x] PASA: Los usuarios envían/reciben mensajes en tiempo real
- [ ] FALLA: Salas de chat creadas automáticamente para eventos de rescate/subsidio (fix: T1-4)
- [ ] FALLA: Notificaciones push para mensajes nuevos (fix: T1-3)
- [ ] FALLA: Chat archivado y vinculado al caso al completarse (fix: T2-4)
