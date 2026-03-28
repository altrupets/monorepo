# Subvención Veterinaria Municipal — Especificación Completa

**Dominio**: `vet-subsidy`
**Sprint**: 02 (Prioridad Alta)
**Servicios afectados**: Veterinary Service, Government Service, Financial Service, Geolocation Service, Notification Service
**Ingresos en riesgo**: $4,500/mes (J4: $3,500/mes + J9: $1,000/mes)

---

## Visión General

El Sistema de Subvención Municipal para Atención Veterinaria es la funcionalidad de mayor impacto en ingresos de AltruPets. Representa $4,500/mes en ingresos recurrentes en riesgo ($3,500/mes del flujo de subsidio veterinario J4 + $1,000/mes de incorporación de clínicas veterinarias J9), siendo el **feature #1 en generación de revenue** del modelo B2G.

### Justificacion de Prioridad Alta (Sprint 02)

1. **Sostenibilidad Financiera**: Permite que las municipalidades subsidien los costos veterinarios, reduciendo la carga financiera sobre rescatistas individuales
2. **Cumplimiento Regulatorio**: Establece el marco legal para que gobiernos locales participen activamente en el bienestar animal
3. **Escalabilidad del Sistema**: Sin subvencion municipal, el sistema no es viable a largo plazo para rescatistas con recursos limitados
4. **Diferenciacion Competitiva**: Ninguna plataforma similar ofrece integracion gubernamental para subvenciones veterinarias

### Componentes Criticos

- Workflow completo de solicitud -> revision -> aprobacion/rechazo -> facturacion
- Segregacion multi-tenant para datos gubernamentales
- Integracion con Financial Service para facturacion dual (municipal vs rescatista)
- Dashboard gubernamental para gestion de subvenciones
- Notificaciones automaticas y expiracion de solicitudes
- Auditoria completa para transparencia gubernamental

### Principio Fundamental

> **Desacoplamiento procedimiento/subvencion (REQ-FIN-VET-008)**: La subvencion municipal NO condiciona la realizacion de procedimientos medicos. Los rescatistas pueden actuar libremente para rescatar animales. La subvencion afecta unicamente la facturacion y el sujeto obligado de pago.

---

## Red Veterinaria

### Registro y Perfiles de Veterinarios

**REQ-VET-001: Registro de Veterinarios**
CUANDO un veterinario se registre ENTONCES el sistema DEBERA verificar credenciales profesionales, especialidades y tarifas preferenciales.

**REQ-VET-002: Recepcion de Solicitudes**
CUANDO un rescatista solicite atencion ENTONCES el sistema DEBERA notificar a veterinarios cercanos con especialidad requerida.

**REQ-VET-003: Gestion de Casos**
CUANDO un veterinario acepte un caso ENTONCES el sistema DEBERA proporcionar historial medico del animal y contacto del rescatista.

**REQ-VET-004: Registro Medico**
CUANDO un veterinario complete atencion ENTONCES el sistema DEBERA permitir registrar diagnostico, tratamiento, medicamentos y seguimiento requerido.

**REQ-VET-005: Facturacion de Servicios**
CUANDO se complete atencion veterinaria ENTONCES el sistema DEBERA registrar costos del servicio en el sistema financiero del rescatista.

### Incorporacion de Clinicas

El flujo de incorporacion de clinicas veterinarias (J9) es prerequisito del subsidio veterinario (J4):

| Paso | Accion | Pantalla/Ruta |
|------|--------|---------------|
| 1 | Registrarse con credenciales profesionales | `/register` (seleccion de rol) |
| 2 | Completar perfil de clinica | `/vet/clinic/setup` [TBD] |
| 3 | Recibir primera solicitud de subsidio | Push -> `/vet/subsidy/{id}` [TBD] |
| 4 | Se muestra propuesta de mejora | Mensaje dentro de la app |
| 5 | Suscribirse al plan de pago | `/vet/clinic/subscription` [TBD] |

**Perfil de clinica incluye**: nombre, horario, servicios, precios, fotos, pin en mapa, licencia profesional, especialidades.

### Especializaciones

Segun REQ-RES-001D, el sistema muestra para cada veterinario:
- Lista de veterinarios recomendados por otros rescatistas cercanos
- Calificaciones y comentarios de la comunidad
- Tarifas preferenciales disponibles para rescatistas
- Especialidades (felinos, caninos, exoticos, etc.)
- Disponibilidad para emergencias y horarios de atencion

### Radios de Busqueda y Prioridad

**REQ-GEO-020**: Veterinarios para emergencias: radio de 20km.
**REQ-GEO-021**: Veterinarios para consultas rutinarias: radio de 50km.
**REQ-GEO-022**: Priorizar aquellos con tarifas preferenciales para rescate.
**REQ-RES-001C**: Veterinarios registrados en radio de 25km con tarifas preferenciales para asignacion de veterinario de confianza.

### Red de Emergencia (REQ-CONT-010)

CUANDO se requiera continuidad veterinaria ENTONCES el sistema DEBERA proporcionar:
- Red de veterinarios disponibles para casos urgentes
- Acceso completo a historiales medicos de animales transferidos
- Tarifas preferenciales para casos de continuidad
- Disponibilidad 24/7 para emergencias criticas

### Apoyo Gubernamental (REQ-RES-001E)

CUANDO un rescatista solicite apoyo gubernamental ENTONCES el sistema DEBERA:
- Conectar automaticamente con la oficina de Bienestar Animal de su jurisdiccion
- Facilitar que el gobierno local proporcione lista de veterinarios colaboradores
- Permitir que el gobierno subsidie parcialmente las primeras consultas veterinarias
- Coordinar con veterinarios que participen en programas gubernamentales de rescate

### Validacion de Proveedor (REQ-FIN-VET-011)

CUANDO un proveedor solicite subvencion ENTONCES el sistema DEBERA verificar que el veterinario/clinica este validado por el `Veterinary Service`.

### API Endpoints del Veterinary Service

```
POST /api/v1/veterinary/register
GET  /api/v1/veterinary/available
POST /api/v1/veterinary/request
PUT  /api/v1/veterinary/treatment
GET  /api/v1/veterinary/medical-records
POST /api/v1/veterinary/referral
```

---

## Workflow de Solicitud de Subvencion

### Maquina de Estados Completa

```
CREADA ──────> EN_REVISION ──────> APROBADA   (estado final)
                   │
                   ├──────────────> RECHAZADA  (estado final)
                   │
                   └──────────────> EXPIRADA   (estado final, automatico)
```

**Transiciones validas:**

| Estado Origen | Estados Destino | Disparador |
|---------------|-----------------|------------|
| `CREADA` | `EN_REVISION` | Solicitud entra a evaluacion municipal |
| `EN_REVISION` | `APROBADA` | Municipalidad aprueba la subvencion |
| `EN_REVISION` | `RECHAZADA` | Municipalidad rechaza con justificacion |
| `EN_REVISION` | `EXPIRADA` | Vence el tiempo maximo de respuesta sin resolucion |
| `APROBADA` | (ninguno) | Estado final |
| `RECHAZADA` | (ninguno) | Estado final |
| `EXPIRADA` | (ninguno) | Estado final |

### Reglas de Transicion (REQ-WF-050 a REQ-WF-054)

**REQ-WF-050:** CUANDO se cree una Solicitud de Subvencion Municipal ENTONCES el estado inicial DEBERA ser `CREADA`.

**REQ-WF-051:** CUANDO una solicitud de subvencion entre a evaluacion ENTONCES el estado DEBERA ser `EN_REVISION`.

**REQ-WF-052:** CUANDO la municipalidad apruebe ENTONCES el estado DEBERA cambiar a `APROBADA` y se DEBERA emitir factura a nombre de la municipalidad.

**REQ-WF-053:** CUANDO la municipalidad rechace ENTONCES el estado DEBERA cambiar a `RECHAZADA` y se DEBERA emitir factura a nombre del rescatista.

**REQ-WF-054:** CUANDO venza el "Tiempo maximo de respuesta para subvencionar" sin resolucion ENTONCES el estado DEBERA cambiar automaticamente a `EXPIRADA` y se DEBERA emitir factura a nombre del rescatista.

### Flujo Completo del Journey J4

| Paso | Accion | Pantalla/Ruta | Que Debe Suceder | Datos Requeridos |
|------|--------|---------------|------------------|------------------|
| 1 | El rescatista crea solicitud de subsidio | `/vet-subsidy/new` [TBD] | Formulario: animal, procedimiento, costo estimado, urgencia. Auto-deteccion de municipalidad por GPS. | Entidad animal, GPS, mapa de jurisdiccion |
| 2 | El sistema asigna a la municipalidad | En segundo plano | GPS -> mapeo de jurisdiccion. Enrutado al tenant correcto. Estado -> `CREADA` | Limites de jurisdiccion PostGIS |
| 3 | El coordinador recibe la solicitud | Push -> `/subsidy/review/{id}` [TBD] | Solicitud con detalles del animal, estimacion veterinaria, historial del rescatista. | Panel municipal |
| 4 | El coordinador aprueba/rechaza | `/subsidy/review/{id}` [TBD] | Aprobar con presupuesto o rechazar con motivo. Expiracion automatica si no hay respuesta. Estado -> `APROBADA`/`RECHAZADA` | Presupuesto, autoridad |
| 5 | El veterinario recibe autorizacion | Push -> `/vet/subsidy/{id}` [TBD] | Subsidio aprobado con monto autorizado, detalles del procedimiento. | Perfil veterinario |
| 6 | El veterinario realiza y registra el tratamiento | `/vet/patients/{animalId}/treatment` [TBD] | Expediente medico: diagnostico, tratamiento, medicamentos, fotos. Factura generada. | Entidad de expediente medico |
| 7 | El veterinario envia la factura | `/vet/subsidy/{id}/invoice` [TBD] | Factura digital enviada a la municipalidad. | Entidad de factura |
| 8 | La municipalidad procesa el pago | `/subsidy/{id}/payment` [TBD] | Confirmacion de pago. Estado -> `PAID`. Pista de auditoria completa. | Pago municipal |

### Creacion de Solicitudes (Automaticas y Manuales)

**REQ-BR-060: Solicitudes para atencion veterinaria (automaticas y manuales)**

CUANDO un auxiliar genere una solicitud de rescate ENTONCES el sistema DEBERA crear automaticamente una "solicitud de autorizacion para atencion veterinaria" SI el animal tiene CUALQUIERA de las siguientes condiciones:
- Callejero = TRUE
- Herido = TRUE
- Enfermo = TRUE

CUANDO un rescatista evalue que un animal requiere atencion veterinaria profesional ENTONCES el sistema DEBERA permitir crear una "solicitud para atencion veterinaria" independientemente de las condiciones automaticas, basada en su criterio profesional y conocimiento directo del animal.

**Diferenciacion:**
- **Solicitudes automaticas**: Generadas por el sistema para subvencion gubernamental de animales callejeros
- **Solicitudes manuales de rescatistas**: Creadas por evaluacion profesional para cualquier animal bajo su cuidado

### Solicitud de Informacion (REQ-FIN-VET-007)

CUANDO la municipalidad requiera aclaraciones ENTONCES el sistema DEBERA permitir solicitudes de informacion durante `EN_REVISION` y pausar el computo de plazo hasta que el veterinario adjunte los soportes.

### Expiracion Automatica (REQ-FIN-VET-014)

CUANDO se configure un tenant municipal ENTONCES el parametro "Tiempo maximo de respuesta para subvencionar" DEBERA ser definible por la municipalidad (en horas) y aplicarse al calculo de `EXPIRADA`.

### API Endpoints de Subvencion

**Financial Service:**
```
POST /api/v1/veterinary-subsidy
GET  /api/v1/veterinary-subsidy/{id}
PUT  /api/v1/veterinary-subsidy/{id}/approve
PUT  /api/v1/veterinary-subsidy/{id}/reject
GET  /api/v1/veterinary-subsidy/municipal/{tenantId}
POST /api/v1/veterinary-subsidy/{id}/invoice
GET  /api/v1/veterinary-subsidy/reports/{tenantId}
```

**Government Service:**
```
GET  /api/v1/government/veterinary-subsidies/pending
PUT  /api/v1/government/veterinary-subsidies/{id}/approve
PUT  /api/v1/government/veterinary-subsidies/{id}/reject
POST /api/v1/government/veterinary-subsidies/{id}/request-info
GET  /api/v1/government/veterinary-subsidies/reports
PUT  /api/v1/government/config/subsidy-response-time
```

---

## Autorizacion Gubernamental

### Validacion de Jurisdiccion

**REQ-JUR-001: Definir jurisdiccion con poligonos**
CUANDO un gobierno local se registre ENTONCES el sistema DEBERA permitir definir su jurisdiccion mediante poligonos geograficos.

**REQ-JUR-002: Solapamiento para zonas fronterizas**
CUANDO se definan jurisdicciones ENTONCES el sistema DEBERA permitir solapamiento para casos fronterizos.

**REQ-JUR-003: Notificacion a jurisdicciones solapadas**
CUANDO haya solapamiento de jurisdicciones ENTONCES el sistema DEBERA notificar a ambas jurisdicciones.

**REQ-JUR-010: Aprobacion financiera exclusiva por jurisdiccion**
CUANDO se requiera subvencion municipal ENTONCES SOLAMENTE los encargados de la jurisdiccion correspondiente DEBERAN poder aprobar o rechazar la subvencion financiera; esta aprobacion no condiciona la realizacion del procedimiento medico.

**REQ-JUR-011: Jurisdiccion segun ubicacion exacta**
CUANDO se determine la jurisdiccion ENTONCES el sistema DEBERA usar la ubicacion exacta del animal reportado.

**REQ-JUR-012: Autorizacion doble en zona fronteriza**
CUANDO un animal este en zona fronteriza ENTONCES el sistema DEBERA requerir autorizacion de ambas jurisdicciones.

### Casos Especiales de Jurisdiccion

**REQ-JUR-020: Carreteras nacionales -> canton mas cercano**
CUANDO un animal este en carreteras nacionales ENTONCES el sistema DEBERA asignar la jurisdiccion del canton mas cercano.

**REQ-JUR-021: Propiedad privada requiere autorizacion del dueno**
CUANDO un animal este en propiedades privadas ENTONCES el sistema DEBERA requerir autorizacion adicional del propietario.

**REQ-JUR-022: Zonas protegidas requieren entidad ambiental**
CUANDO un animal este en zonas protegidas ENTONCES el sistema DEBERA requerir autorizacion de la entidad ambiental nacional (ej: SINAC en Costa Rica) ademas del gobierno local.

### Arquitectura Multi-Tenant

**REQ-ADM-003**: CUANDO un gobierno local contrate el servicio ENTONCES el sistema DEBERA implementar tenant especifico con segregacion UNICAMENTE de datos gubernamentales (autorizaciones veterinarias, reportes jurisdiccionales, politicas locales) manteniendo los datos de AltruPets centralizados.

**REQ-MT-001: Datos de AltruPets centralizados**
CUANDO se almacenen datos de AltruPets ENTONCES el sistema DEBERA mantener centralizados los datos de usuarios, animales, rescates, donaciones, veterinarios y casas cuna de rescatistas.

**REQ-MT-002: Datos gubernamentales segregados por tenant**
CUANDO se almacenen datos gubernamentales ENTONCES el sistema DEBERA segregar por tenant UNICAMENTE las autorizaciones veterinarias, reportes jurisdiccionales y politicas locales.

**REQ-MT-003: Acceso gubernamental a datos en su jurisdiccion**
CUANDO un gobierno local acceda al sistema ENTONCES DEBERA ver solo sus datos gubernamentales segregados pero tener acceso a los datos centralizados de AltruPets en su jurisdiccion.

**REQ-MT-004: Reportes filtrados por jurisdiccion**
CUANDO se generen reportes gubernamentales ENTONCES el sistema DEBERA filtrar los datos centralizados por jurisdiccion geografica del tenant.

**REQ-MT-005: RLS solo en tablas gubernamentales**
CUANDO se implemente Row Level Security ENTONCES DEBERA aplicarse UNICAMENTE a tablas gubernamentales (autorizaciones veterinarias, reportes, mediacion de conflictos).

### Rol: Encargado de Bienestar Animal

**REQ-NOT-004:** CUANDO se requiera autorizacion veterinaria ENTONCES el sistema DEBERA notificar al encargado de bienestar animal jurisdiccional.

**REQ-BR-070: Criterios para autorizar atencion veterinaria**
CUANDO un encargado gubernamental evalue una autorizacion veterinaria ENTONCES SOLAMENTE PODRA autorizarla CUANDO se cumplan AMBAS condiciones:
- La ubicacion este dentro de su jurisdiccion territorial
- El animal tenga la condicion "callejero" = TRUE

**REQ-BR-092: Autorizacion vet dentro de jurisdiccion**
CUANDO se intente otorgar una autorizacion veterinaria ENTONCES el sistema DEBERA verificar que este dentro de la jurisdiccion territorial correspondiente.

### Roles Administrativos Gubernamentales

**Administrador Gubernamental**: Autoridad local que supervisa actividades en su jurisdiccion. Permisos: supervision jurisdiccional, mediacion de conflictos, reportes oficiales.

**Auditor Gubernamental/Ambiental**: Rol de auditoria para entidades gubernamentales (municipalidades, SINAC u homologos). Permisos: generacion de reportes oficiales y de auditoria acotados a su jurisdiccion, acceso solo lectura con PII minimizada, exportacion controlada y auditada.

---

## Facturacion Dual

### Modelo de Facturacion

El sistema emite automaticamente facturas a diferentes sujetos obligados segun el resultado de la subvencion:

| Resultado de Subvencion | Sujeto Obligado de Pago | Regla |
|--------------------------|-------------------------|-------|
| `APROBADA` | Municipalidad | REQ-FIN-VET-004, REQ-WF-052 |
| `RECHAZADA` | Rescatista | REQ-FIN-VET-005, REQ-WF-053 |
| `EXPIRADA` | Rescatista | REQ-FIN-VET-005, REQ-WF-054 |

### Reglas de Facturacion

**REQ-FIN-VET-004: Factura a municipalidad si aprobada**
CUANDO una solicitud sea `APROBADA` ENTONCES el sistema DEBERA emitir la factura a nombre de la municipalidad aprobadora y registrar la obligacion de pago municipal (subvencion total).

**REQ-FIN-VET-005: Factura al rescatista si rechazada/expirada**
CUANDO una solicitud sea `RECHAZADA` o `EXPIRADA` ENTONCES el sistema DEBERA emitir la factura a nombre del rescatista y registrar su obligacion de pago.

**REQ-FIN-VET-009: Emision inmediata de factura segun estado**
CUANDO una solicitud cambie a `APROBADA` ENTONCES el sistema DEBERA emitir la factura inmediata a nombre de la municipalidad; CUANDO cambie a `RECHAZADA` o `EXPIRADA` ENTONCES debera emitir la factura a nombre del rescatista.

**REQ-FIN-VET-010: Subvencion total (sin cofinanciamiento)**
CUANDO se gestione subvencion municipal ENTONCES el sistema DEBERA aplicar subvencion total; el cofinanciamiento parcial NO DEBERA estar habilitado.

### Integracion con Financial Service

**REQ-SW-FIN-010: Obligacion municipal al aprobar subvencion**
CUANDO una solicitud de subvencion cambie a `APROBADA` ENTONCES el `Financial Service` DEBERA crear la obligacion de pago municipal y preparar el flujo de pago (via ONVOPay o metodo alternativo `REQ-INT-002`).

**REQ-SW-FIN-011: Obligacion del rescatista si rechazada/expirada**
CUANDO una solicitud de subvencion cambie a `RECHAZADA` o `EXPIRADA` ENTONCES el `Financial Service` DEBERA crear la obligacion de pago del rescatista y habilitar los metodos de cobro correspondientes.

### Arquitectura de Integracion entre Servicios

**Decision de Diseno**: El sistema de subvencion se implementa como una funcionalidad distribuida entre Financial Service y Government Service, con eventos asincronos para coordinacion.

- **Financial Service**: Maneja la logica de facturacion y obligaciones de pago
- **Government Service**: Maneja la aprobacion/rechazo y politicas municipales
- **Comunicacion asincrona**: Permite que cada servicio mantenga su responsabilidad unica

---

## Expedientes Medicos

### Gestion de Pacientes

El Veterinary Service gestiona expedientes medicos inmutables usando Event Sourcing para auditoria completa.

**REQ-VET-003:** CUANDO un veterinario acepte un caso ENTONCES el sistema DEBERA proporcionar historial medico del animal y contacto del rescatista.

**REQ-VET-004:** CUANDO un veterinario complete atencion ENTONCES el sistema DEBERA permitir registrar diagnostico, tratamiento, medicamentos y seguimiento requerido.

### Contenido del Expediente

Cada registro de tratamiento incluye:
- Diagnostico
- Tratamiento realizado
- Medicamentos administrados y recetados
- Seguimiento requerido
- Fotos del procedimiento
- Factura generada

### Historial del Animal

El expediente medico esta vinculado a la entidad Animal y es accesible:
- Por el veterinario tratante
- Por veterinarios de emergencia que reciban transferencia (REQ-CONT-010)
- Por rescatistas responsables del animal
- Para reportes de transparencia gubernamental (filtrado por jurisdiccion)

---

## Reglas de Negocio

### Reglas de Subvencion (REQ-FIN-VET-*)

| ID | Regla |
|----|-------|
| REQ-FIN-VET-001 | Crear solicitud de subvencion municipal vinculada al caso con monto tentativo, desglose, proveedor, fecha y ubicacion |
| REQ-FIN-VET-002 | Asignacion automatica por jurisdiccion respetando REQ-JUR-001..003 y REQ-JUR-011 |
| REQ-FIN-VET-003 | Flujo de estados: `CREADA` -> `EN_REVISION` -> `APROBADA` / `RECHAZADA` / `EXPIRADA` |
| REQ-FIN-VET-004 | Factura a municipalidad si `APROBADA` (subvencion total) |
| REQ-FIN-VET-005 | Factura al rescatista si `RECHAZADA` o `EXPIRADA` |
| REQ-FIN-VET-006 | Notificar encargado municipal (creacion), veterinario y rescatista (resolucion) |
| REQ-FIN-VET-007 | Solicitud de informacion durante `EN_REVISION`, pausa el computo de plazo |
| REQ-FIN-VET-008 | Procedimiento medico NO condicionado por aprobacion municipal |
| REQ-FIN-VET-009 | Emision inmediata de factura al cambiar estado |
| REQ-FIN-VET-010 | Subvencion total, sin cofinanciamiento parcial |
| REQ-FIN-VET-011 | Validacion de proveedor por Veterinary Service |
| REQ-FIN-VET-012 | Sin subvencion fuera de jurisdiccion; doble subvencion en zonas fronterizas |
| REQ-FIN-VET-013 | Auditoria completa con retencion minima de 7 anos |
| REQ-FIN-VET-014 | SLA de respuesta configurable en horas por municipalidad |

### Reglas de Workflow (REQ-WF-050 a REQ-WF-054)

| ID | Regla |
|----|-------|
| REQ-WF-050 | Estado inicial de Solicitud de Subvencion Municipal: `CREADA` |
| REQ-WF-051 | Entrada a evaluacion: `EN_REVISION` |
| REQ-WF-052 | Aprobacion municipal: `APROBADA` + emision factura a municipalidad |
| REQ-WF-053 | Rechazo municipal: `RECHAZADA` + emision factura a rescatista |
| REQ-WF-054 | Vencimiento de tiempo maximo: `EXPIRADA` + emision factura a rescatista |

### Reglas de Negocio Veterinarias (REQ-BR-*)

| ID | Regla |
|----|-------|
| REQ-BR-026 | Criterios para solicitudes veterinarias: evaluar si excede conocimientos/insumos, si es urgente, si hay riesgo de complicaciones |
| REQ-BR-060 | Solicitudes automaticas si animal callejero/herido/enfermo; manuales por criterio del rescatista |
| REQ-BR-070 | Autorizacion veterinaria SOLO si ubicacion dentro de jurisdiccion Y animal callejero = TRUE |
| REQ-BR-092 | Autorizacion veterinaria debe estar dentro de jurisdiccion territorial |

### Reglas de Jurisdiccion (REQ-JUR-*)

| ID | Regla |
|----|-------|
| REQ-JUR-001 | Jurisdiccion definida con poligonos geograficos |
| REQ-JUR-002 | Permitir solapamiento para zonas fronterizas |
| REQ-JUR-003 | Notificar a ambas jurisdicciones en solapamiento |
| REQ-JUR-010 | Aprobacion financiera exclusiva por jurisdiccion (no condiciona procedimiento medico) |
| REQ-JUR-011 | Jurisdiccion segun ubicacion exacta del animal |
| REQ-JUR-012 | Autorizacion doble en zona fronteriza |
| REQ-JUR-020 | Carreteras nacionales: canton mas cercano |
| REQ-JUR-021 | Propiedad privada: autorizacion del dueno |
| REQ-JUR-022 | Zonas protegidas: autorizacion de entidad ambiental + gobierno local |

### Reglas de Notificacion

| ID | Regla |
|----|-------|
| REQ-NOT-004 | Notificar encargado de bienestar animal jurisdiccional para autorizacion veterinaria |
| REQ-NOT-006 | Notificar encargado municipal (creacion de subvencion); veterinario y rescatista (resolucion o expiracion) |

### Reglas de Integracion Financiera

| ID | Regla |
|----|-------|
| REQ-SW-FIN-010 | Financial Service crea obligacion de pago municipal al aprobar subvencion |
| REQ-SW-FIN-011 | Financial Service crea obligacion del rescatista si rechazada/expirada |

### Reglas Multi-Tenant

| ID | Regla |
|----|-------|
| REQ-MT-001 | Datos de AltruPets centralizados (usuarios, animales, veterinarios, etc.) |
| REQ-MT-002 | Segregacion por tenant SOLO de autorizaciones veterinarias, reportes, politicas |
| REQ-MT-003 | Gobierno local ve sus datos segregados + datos centralizados en su jurisdiccion |
| REQ-MT-004 | Reportes filtrados por jurisdiccion geografica del tenant |
| REQ-MT-005 | Row Level Security SOLO en tablas gubernamentales |

---

## Modelos de Datos

### SolicitudSubvencionMunicipal

```typescript
interface SolicitudSubvencionMunicipal {
  id: string;
  veterinarioId: string;
  rescatistaId: string;
  animalId: string;
  tenantMunicipalId: string; // Segregacion multi-tenant

  // Detalles del procedimiento
  montoTentativo: number;
  desgloceServicios: ServicioVeterinario[];
  fechaProcedimiento: Date;
  ubicacionAnimal: Coordenadas;

  // Estados del workflow
  estado: 'CREADA' | 'EN_REVISION' | 'APROBADA' | 'RECHAZADA' | 'EXPIRADA';

  // Configuracion municipal
  tiempoMaximoRespuesta: number; // En horas, configurable por municipalidad
  fechaCreacion: Date;
  fechaExpiracion: Date;

  // Auditoria
  aprobadoPor?: string;
  motivoRechazo?: string;
  facturaEmitida?: FacturaVeterinaria;
}
```

### SolicitudSubvencion (modelo simplificado de requisitos)

```typescript
interface SolicitudSubvencion {
  id: string;
  casoId: string;
  animal: Animal;
  veterinarioId: string;
  clinicaId?: string;
  montoTentativo: number;
  desgloseServicios: string[];
  fechaProcedimiento: Date;
  ubicacion: Coordenadas;
  estado: SolicitudSubvencionState;
  municipalidadId: string;
  encargadoId?: string;
  fechaCreacion: Date;
  fechaVencimiento: Date;
  justificacionRechazo?: string;
  soportesAdjuntos: string[];
}
```

### SolicitudSubvencionState

```typescript
enum SolicitudSubvencionState {
  CREADA = 'CREADA',
  EN_REVISION = 'EN_REVISION',
  APROBADA = 'APROBADA',
  RECHAZADA = 'RECHAZADA',
  EXPIRADA = 'EXPIRADA'
}
```

### Motor de Reglas (SubvencionMunicipalEngine)

```typescript
class SubvencionMunicipalEngine {

  // REQ-FIN-VET-002: Asignacion automatica por jurisdiccion
  async asignarJurisdiccion(ubicacionAnimal: Coordenadas): Promise<string>;

  // REQ-FIN-VET-003: Gestion de estados con facturacion automatica
  async procesarTransicionEstado(
    solicitudId: string,
    nuevoEstado: EstadoSubvencion,
    usuarioId: string
  ): Promise<void>;

  // REQ-FIN-VET-014: Expiracion automatica
  async verificarExpiraciones(): Promise<void>;
}
```

### SubvencionWorkflowStateMachine

```typescript
class SubvencionWorkflowStateMachine {

  private transiciones = {
    'CREADA': ['EN_REVISION'],
    'EN_REVISION': ['APROBADA', 'RECHAZADA', 'EXPIRADA'],
    'APROBADA': [],   // Estado final
    'RECHAZADA': [],  // Estado final
    'EXPIRADA': []    // Estado final
  };

  // REQ-WF-052: Aprobacion municipal
  async aprobarSubvencion(solicitudId: string, encargadoId: string): Promise<void>;

  // REQ-WF-054: Expiracion automatica
  async procesarExpiracionAutomatica(): Promise<void>;
}
```

### SubvencionMultiTenantService

```typescript
class SubvencionMultiTenantService {

  // REQ-MT-002: Solo datos gubernamentales segregados (Row Level Security)
  async getSolicitudesPorTenant(tenantId: string): Promise<SolicitudSubvencionMunicipal[]>;

  // REQ-MT-004: Reportes filtrados por jurisdiccion
  async generarReporteTransparencia(
    tenantId: string,
    periodo: PeriodoReporte
  ): Promise<ReporteTransparencia>;
}
```

### Entidades Relacionadas

**Animal** (campos relevantes para subvencion):
```typescript
interface Animal {
  id: string;
  especie: 'GATO' | 'PERRO' | 'OTRO';
  condiciones: AnimalConditions; // callejero, herido, enfermo
  estado: AnimalState;
  ubicacion: Coordenadas;
  rescatistaId?: string;
  casaCunaId?: string;
}
```

---

## Criterios de Aceptacion

### J4: Solicitud y Aprobacion de Subsidio Veterinario

**Puntuacion actual: 0%** | **Ingresos en riesgo: $3,500/mes** | **Etiqueta: Revenue-Critical**

Personas involucradas: P05/P06 (rescatistas solicitan), P03/P04 (veterinarios tratan), P01/P02 (gobierno aprueba)

- [ ] FALLA: El rescatista crea solicitud de subsidio en <5 minutos
- [ ] FALLA: El sistema asigna automaticamente a la municipalidad correcta por GPS
- [ ] FALLA: El coordinador aprueba/rechaza dentro de la app
- [ ] FALLA: Expiracion automatica si no hay respuesta en las horas configuradas
- [ ] FALLA: El veterinario recibe autorizacion y registra el tratamiento
- [ ] FALLA: Factura digital enviada y rastreada hasta el pago
- [ ] FALLA: Pista de auditoria completa desde la solicitud hasta el pago

### J9: Incorporacion Clinica Veterinaria -> Conversion Premium

**Puntuacion actual: 0%** | **Ingresos en riesgo: $1,000/mes** | **Etiqueta: Revenue-Critical**

Personas involucradas: P03 (Veterinario), P04 (Clinica)

- [ ] FALLA: Registrarse con credenciales profesionales e info de clinica
- [ ] FALLA: Aparece en busquedas por proximidad para rescatistas
- [ ] FALLA: Propuesta de mejora basada en uso al alcanzar el umbral
- [ ] FALLA: Suscribirse al plan de pago via SINPE/tarjeta

### Estado de Implementacion

**J4**: Nada construido. Ampliamente especificado en `design.md` (interfaces TypeScript, estados de flujo de trabajo, clase de motor) pero cero implementacion.

**J9**: El registro tiene el rol de Veterinario. Nada mas construido.

---

## Referencias SRD Journey

### Grafo de Dependencias

```
J1 (Registro) <- RAIZ
  +-- J6 (Casa Cuna)
  |     +-- J4 (Subsidio Veterinario) <- depende de J1 + J6 + J9
  +-- J9 (Incorporacion Veterinaria) <- depende de J1, alimenta J4
```

**Camino critico hacia ingresos B2G (subsidios)**: J1 -> J6 + J9 -> J4

### Ingresos en Riesgo

| Journey | Descripcion | Ingresos/mes | % del Objetivo |
|---------|-------------|-------------|----------------|
| J4 | Solicitud y Aprobacion de Subsidio Veterinario | $3,500 | 35.0% |
| J9 | Incorporacion Clinica Veterinaria -> Premium | $1,000 | 10.0% |
| **Total** | **Vet-subsidy combinado** | **$4,500** | **45.0%** |

**Objetivo global**: $10K MRR. El dominio vet-subsidy representa el 45% del objetivo total de ingresos mensuales.
