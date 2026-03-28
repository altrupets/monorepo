# Reportes de Maltrato Animal — Especificacion Completa

**Dominio**: `abuse-reports`
**Sprint**: 02 (Prioridad Alta)
**Servicios afectados**: Government Service, Geolocation Service, Notification Service, User Service
**Ingresos en riesgo**: $3,325/mes (J5: $1,425/mes + J7: $1,900/mes)

---

## Vision General

El Sistema de Reportes de Maltrato Animal es la funcionalidad que conecta a ciudadanos autenticados con las autoridades municipales para denunciar situaciones de maltrato, negligencia o abandono animal. Representa $3,325/mes en ingresos recurrentes en riesgo ($1,425/mes del flujo de reporte de maltrato J5 + $1,900/mes del panel municipal J7 que consume estos datos), siendo el **segundo feature en generacion de revenue B2G** despues del subsidio veterinario.

### Justificacion de Prioridad Alta (Sprint 02)

1. **Cumplimiento Regulatorio**: Facilita el cumplimiento de leyes de maltrato animal (ej: Ley N 9458 de Costa Rica) por parte de los gobiernos locales
2. **Valor Inmediato para Municipalidades**: Reemplaza lineas telefonicas con espera de 45 minutos (pain point de P01 Gabriela) por un canal digital con seguimiento automatico
3. **Alimenta el Panel Municipal (J7)**: Los reportes de maltrato son una de las metricas clave del dashboard gubernamental que justifica el contrato B2G
4. **Diferenciacion Competitiva**: Reportes autenticados con GPS, fotos y seguimiento automatico son superiores a lineas telefonicas o formularios en papel

### Principio Fundamental: Autenticacion Obligatoria (Regla SRD #9)

> **Los reportes de maltrato de AltruPets NO son anonimos.** Los usuarios deben tener sesion iniciada para presentar un reporte. Esto garantiza rendicion de cuentas, permite seguimiento, y previene spam/reportes falsos. A diferencia del `requirements.md` original que menciona "denuncias anonimas", el SRD establece explicitamente que la autenticacion es obligatoria.

### Componentes Criticos

- Formulario movil con captura automatica de GPS y carga de fotos
- Generacion inmediata de codigo de seguimiento unico
- Enrutamiento automatico a la jurisdiccion municipal correcta via PostGIS
- Maquina de estados completa: `FILED` -> `EN_REVISION` -> `INVESTIGADO` -> `RESUELTO`
- Integracion con el panel municipal (J7) para gestion de casos
- Consulta publica de estado via codigo de seguimiento
- Auditoria completa para transparencia gubernamental

---

## Workflow de Reporte Autenticado

### Flujo Completo del Journey J5

| Paso | Accion | Pantalla/Ruta | Que Debe Suceder | Datos Requeridos |
|------|--------|---------------|------------------|------------------|
| 1 | El usuario abre el formulario de reporte de maltrato (sesion iniciada requerida) | `/report-abuse` [TBD] | Formulario: GPS automatico, carga de fotos, descripcion, tipo de maltrato. Debe estar autenticado (Regla SRD #9). | Auth (JWT), GPS, camara |
| 2 | Envia y recibe codigo de seguimiento | `/report-abuse/confirmation` [TBD] | Codigo de seguimiento unico generado (formato: `MAL-XXXXXX`). Reporte guardado. Estado -> `FILED` | Usuario autenticado |
| 3 | El sistema enruta a la jurisdiccion | En segundo plano | GPS -> jurisdiccion municipal via PostGIS (`ST_Contains`). El reporte aparece en el panel municipal. | Limites de jurisdiccion (poligonos) |
| 4 | El funcionario municipal revisa y clasifica | `/b2g/reports/{id}` [TBD] | Categorizar (negligencia, maltrato fisico, abandono), asignar prioridad, asignar investigador. Estado -> `EN_REVISION` | Panel municipal, tenant |
| 5 | Investigacion del caso | `/b2g/reports/{id}/investigate` [TBD] | Registro de hallazgos, notas de campo, evidencia adicional. Estado -> `INVESTIGADO` | Datos de investigacion |
| 6 | Estado visible via codigo de seguimiento | `/report-abuse/track/{code}` [TBD] | El reportante consulta estado: `FILED` -> `EN_REVISION` -> `INVESTIGADO` -> `RESUELTO` | Codigo de seguimiento |
| 7 | Resolucion del caso y metricas | Panel municipal | Caso cerrado con resultado (sancion, decomiso, absuelto, derivado). Metricas agregadas. | Datos de resolucion |

### Captura Automatica de GPS

CUANDO un usuario abra el formulario de reporte ENTONCES el sistema DEBERA:
- Solicitar permiso de geolocalizacion si no ha sido otorgado previamente
- Capturar automaticamente las coordenadas GPS del dispositivo
- Mostrar la ubicacion en un mapa para confirmacion visual del usuario
- Permitir ajuste manual del pin si el incidente no esta en la ubicacion actual del reportante
- Almacenar las coordenadas como `GEOMETRY(POINT, 4326)` para consultas PostGIS

### Carga de Fotos

CUANDO un usuario quiera adjuntar evidencia ENTONCES el sistema DEBERA:
- Permitir carga desde camara (foto en el momento) o galeria
- Aceptar minimo 1 y maximo 10 fotos por reporte
- Comprimir imagenes a un maximo de 2MB cada una para optimizar transferencia
- Preservar metadatos EXIF (GPS de la foto, timestamp) como evidencia adicional
- Almacenar fotos en almacenamiento de objetos con referencia en el reporte

### Codigo de Seguimiento

CUANDO se envie un reporte exitosamente ENTONCES el sistema DEBERA:
- Generar un codigo unico con formato `MAL-{6 caracteres alfanumericos}` (ej: `MAL-A3K9F2`)
- Mostrar el codigo inmediatamente en pantalla de confirmacion
- Enviar el codigo por notificacion push y correo electronico al reportante
- Permitir consulta de estado sin autenticacion usando solo el codigo (lectura publica)
- Garantizar unicidad del codigo a nivel global de la plataforma

---

## Maquina de Estados

```
FILED ──────> EN_REVISION ──────> INVESTIGADO ──────> RESUELTO  (estado final)
```

**Transiciones validas:**

| Estado Origen | Estados Destino | Disparador |
|---------------|-----------------|------------|
| `FILED` | `EN_REVISION` | Funcionario municipal abre y clasifica el reporte |
| `EN_REVISION` | `INVESTIGADO` | Investigador registra hallazgos de campo |
| `INVESTIGADO` | `RESUELTO` | Funcionario cierra el caso con resultado final |
| `RESUELTO` | (ninguno) | Estado final |

### Reglas de Transicion

**REQ-WF-AR-010:** CUANDO se cree un reporte de maltrato ENTONCES el estado inicial DEBERA ser `FILED`.

**REQ-WF-AR-011:** CUANDO un funcionario municipal abra y clasifique el reporte ENTONCES el estado DEBERA cambiar a `EN_REVISION` y se DEBERA registrar: funcionario asignado, categoria de maltrato, y nivel de prioridad.

**REQ-WF-AR-012:** CUANDO el investigador registre hallazgos de campo ENTONCES el estado DEBERA cambiar a `INVESTIGADO` y se DEBERA registrar: notas de investigacion, evidencia adicional, y fecha de visita.

**REQ-WF-AR-013:** CUANDO el funcionario cierre el caso ENTONCES el estado DEBERA cambiar a `RESUELTO` y se DEBERA registrar: tipo de resolucion (sancion, decomiso, absuelto, derivado a otra entidad), detalle de la resolucion, y fecha de cierre.

### Categorias de Maltrato

| Codigo | Categoria | Descripcion |
|--------|-----------|-------------|
| `NEGLIGENCIA` | Negligencia | Falta de alimentacion, agua, refugio o atencion medica |
| `MALTRATO_FISICO` | Maltrato fisico | Golpes, heridas intencionales, tortura |
| `ABANDONO` | Abandono | Animal abandonado en via publica o propiedad |
| `HACINAMIENTO` | Hacinamiento | Acumulacion excesiva de animales en condiciones inadecuadas |
| `EXPLOTACION` | Explotacion | Uso indebido para trabajo, peleas, o espectaculos |
| `OTRO` | Otro | Situaciones no cubiertas por las categorias anteriores |

### Niveles de Prioridad

| Nivel | Descripcion | SLA de Respuesta |
|-------|-------------|------------------|
| `CRITICO` | Riesgo de muerte inminente del animal | 4 horas |
| `ALTO` | Lesiones graves visibles o condiciones severas | 24 horas |
| `MEDIO` | Condiciones inadecuadas sin riesgo inmediato | 72 horas |
| `BAJO` | Situaciones menores o preventivas | 7 dias |

---

## Enrutamiento por Jurisdiccion via PostGIS

### Asignacion Automatica de Municipalidad

CUANDO se envie un reporte de maltrato ENTONCES el sistema DEBERA:

1. Tomar las coordenadas GPS del reporte
2. Ejecutar consulta PostGIS contra la tabla `government_tenants`:
   ```sql
   SELECT id, tenant_name
   FROM government_tenants
   WHERE ST_Contains(jurisdiction_polygon, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326))
     AND is_active = TRUE;
   ```
3. Si hay exactamente un resultado: asignar el reporte al tenant correspondiente
4. Si hay multiples resultados (zona fronteriza, REQ-JUR-002): notificar a todas las jurisdicciones solapadas
5. Si no hay resultado: asignar al canton mas cercano (REQ-JUR-020) usando `ST_Distance`

### Casos Especiales de Jurisdiccion

**REQ-JUR-020 (Carreteras nacionales):** CUANDO el reporte se ubique en una carretera nacional sin jurisdiccion directa ENTONCES el sistema DEBERA asignar al canton geograficamente mas cercano.

**REQ-JUR-021 (Propiedad privada):** CUANDO el reporte involucre un animal en propiedad privada ENTONCES el sistema DEBERA registrar esta condicion para que el investigador coordine con autoridades competentes para el acceso (las leyes de maltrato animal de paises latinoamericanos autorizan la intervencion en propiedad privada con escolta policial).

**REQ-JUR-022 (Zonas protegidas):** CUANDO el reporte se ubique en una zona protegida ENTONCES el sistema DEBERA notificar tanto al gobierno local como a la entidad ambiental nacional (ej: SINAC en Costa Rica).

### Zonas Fronterizas (REQ-JUR-002, REQ-JUR-003)

CUANDO un reporte se ubique en una zona de solapamiento entre jurisdicciones ENTONCES el sistema DEBERA:
- Notificar a ambas jurisdicciones simultaneamente
- Permitir que cualquiera de las dos tome el caso
- Registrar cual jurisdiccion tomo responsabilidad para auditoria

---

## Integracion con Panel Municipal (J7)

### Dashboard Gubernamental

El panel municipal (`/b2g/dashboard`) DEBERA mostrar las siguientes metricas de maltrato:

| KPI | Descripcion | Fuente |
|-----|-------------|--------|
| Reportes activos | Conteo de reportes en estado `FILED` + `EN_REVISION` + `INVESTIGADO` | Tabla `abuse_reports` filtrada por tenant |
| Tiempo promedio de resolucion | Dias promedio desde `FILED` hasta `RESUELTO` | Calculo sobre reportes resueltos |
| Reportes por categoria | Distribucion de reportes por tipo de maltrato | Agregacion por `abuse_category` |
| Cumplimiento de SLA | Porcentaje de reportes atendidos dentro del SLA de prioridad | Comparacion `created_at` vs primera transicion |
| Tendencia mensual | Grafico de reportes recibidos por mes | Serie temporal |

### Cola de Elementos Pendientes

El panel municipal DEBERA incluir una vista de cola accionable (`/b2g/reports`) con:
- Lista de reportes pendientes ordenados por prioridad y antiguedad
- Filtros por categoria, prioridad, estado y fecha
- Accion directa: clasificar, asignar investigador, cambiar estado
- Indicadores visuales de SLA (verde: dentro de SLA, amarillo: proximo a vencer, rojo: vencido)

### Reportes de Transparencia (REQ-ADM-005)

CUANDO se requieran reportes oficiales ENTONCES el sistema DEBERA generar estadisticas de reportes de maltrato filtradas por jurisdiccion del tenant gubernamental, incluyendo:
- Total de reportes recibidos por periodo
- Tasa de resolucion y tiempos promedio
- Desglose por categoria y prioridad
- Exportacion en PDF/Excel con marca de agua y control de auditoria (REQ-ADM-008)

---

## Reglas de Negocio

### Reglas de Reporte

| ID | Regla |
|----|-------|
| REQ-AR-001 | El usuario DEBE estar autenticado para presentar un reporte (Regla SRD #9: NO anonimo) |
| REQ-AR-002 | El reporte DEBE incluir coordenadas GPS (captura automatica o manual) |
| REQ-AR-003 | El reporte DEBE incluir al menos 1 foto como evidencia |
| REQ-AR-004 | El reporte DEBE incluir descripcion textual del incidente (minimo 20 caracteres) |
| REQ-AR-005 | El sistema DEBE generar un codigo de seguimiento unico al enviar el reporte |
| REQ-AR-006 | El sistema DEBE enrutar el reporte a la jurisdiccion correcta via PostGIS |
| REQ-AR-007 | Cualquier persona puede consultar el estado de un reporte con el codigo de seguimiento (lectura publica) |

### Reglas de Gestion Municipal

| ID | Regla |
|----|-------|
| REQ-AR-010 | Solo funcionarios del tenant asignado pueden gestionar el reporte (RLS) |
| REQ-AR-011 | La clasificacion de categoria y prioridad es obligatoria al pasar a `EN_REVISION` |
| REQ-AR-012 | El tipo de resolucion es obligatorio al pasar a `RESUELTO` |
| REQ-AR-013 | Toda transicion de estado genera registro de auditoria inmutable |
| REQ-AR-014 | El sistema DEBE notificar al reportante en cada cambio de estado |

### Reglas de Jurisdiccion (aplicadas de REQ-JUR-*)

| ID | Regla |
|----|-------|
| REQ-JUR-001 | Jurisdiccion definida con poligonos geograficos en `government_tenants` |
| REQ-JUR-002 | Solapamiento permitido para zonas fronterizas |
| REQ-JUR-003 | Notificar a ambas jurisdicciones en solapamiento |
| REQ-JUR-011 | Jurisdiccion segun ubicacion exacta del reporte |
| REQ-JUR-020 | Carreteras nacionales: canton mas cercano |
| REQ-JUR-021 | Propiedad privada: registrar para coordinacion con autoridades |
| REQ-JUR-022 | Zonas protegidas: notificar entidad ambiental + gobierno local |

### Reglas de Notificacion

| ID | Regla |
|----|-------|
| REQ-NOT-AR-001 | Notificar al funcionario municipal jurisdiccional al recibir reporte |
| REQ-NOT-AR-002 | Notificar al reportante en cada cambio de estado |
| REQ-NOT-AR-003 | Notificar a supervisores si el SLA de prioridad esta por vencer (75% del tiempo transcurrido) |
| REQ-NOT-AR-004 | Notificar al reportante cuando el caso se resuelva con el detalle de la resolucion |

### Reglas Multi-Tenant (aplicadas de REQ-MT-*)

| ID | Regla |
|----|-------|
| REQ-MT-002 | Reportes de maltrato segregados por tenant gubernamental |
| REQ-MT-003 | Gobierno local ve solo reportes de su jurisdiccion |
| REQ-MT-004 | Reportes de transparencia filtrados por jurisdiccion del tenant |
| REQ-MT-005 | Row Level Security en la tabla `abuse_reports` por `tenant_id` |

---

## Modelo de Datos

### Entidad AbuseReport

```typescript
interface AbuseReport {
  id: string;                          // UUID, PK
  reporterId: string;                  // FK -> users.id (usuario autenticado, Regla SRD #9)
  tenantId: string;                    // FK -> government_tenants.id (segregacion multi-tenant)
  trackingCode: string;                // Codigo unico formato MAL-XXXXXX

  // Ubicacion
  location: Geometry;                  // GEOMETRY(POINT, 4326) — coordenadas GPS
  address: string | null;              // Direccion legible (geocodificacion inversa, opcional)

  // Detalle del incidente
  description: string;                 // Descripcion textual del incidente (min 20 chars)
  abuseCategory: AbuseCategory;        // Categoria de maltrato
  abuseType: string | null;            // Subtipo o detalle adicional

  // Evidencia
  photos: string[];                    // URLs de fotos en almacenamiento de objetos (1-10)
  photoMetadata: PhotoMetadata[];      // Metadatos EXIF preservados

  // Gestion municipal
  priority: AbusePriority | null;      // Asignada por el funcionario al clasificar
  assignedTo: string | null;           // FK -> users.id (investigador asignado)
  estado: AbuseReportState;            // Maquina de estados

  // Resolucion
  resolutionType: ResolutionType | null;    // Tipo de resolucion al cerrar
  resolutionDetail: string | null;          // Detalle de la resolucion
  resolvedAt: Date | null;                  // Fecha de cierre

  // Investigacion
  investigationNotes: string | null;        // Notas del investigador
  investigationEvidence: string[];          // Evidencia adicional recopilada
  investigatedAt: Date | null;              // Fecha de investigacion

  // Metadatos
  createdAt: Date;                     // Fecha de creacion (FILED)
  updatedAt: Date;                     // Ultima actualizacion
}
```

### AbuseReportState

```typescript
enum AbuseReportState {
  FILED = 'FILED',                    // Reporte enviado por el ciudadano
  EN_REVISION = 'EN_REVISION',        // Funcionario municipal clasifico y asigno
  INVESTIGADO = 'INVESTIGADO',        // Investigador registro hallazgos
  RESUELTO = 'RESUELTO'              // Caso cerrado con resolucion
}
```

### AbuseCategory

```typescript
enum AbuseCategory {
  NEGLIGENCIA = 'NEGLIGENCIA',
  MALTRATO_FISICO = 'MALTRATO_FISICO',
  ABANDONO = 'ABANDONO',
  HACINAMIENTO = 'HACINAMIENTO',
  EXPLOTACION = 'EXPLOTACION',
  OTRO = 'OTRO'
}
```

### AbusePriority

```typescript
enum AbusePriority {
  CRITICO = 'CRITICO',       // SLA: 4 horas
  ALTO = 'ALTO',             // SLA: 24 horas
  MEDIO = 'MEDIO',           // SLA: 72 horas
  BAJO = 'BAJO'              // SLA: 7 dias
}
```

### ResolutionType

```typescript
enum ResolutionType {
  SANCION = 'SANCION',                // Multa o sancion al infractor
  DECOMISO = 'DECOMISO',              // Animal decomisado y trasladado
  ABSUELTO = 'ABSUELTO',              // No se confirmo maltrato
  DERIVADO = 'DERIVADO',              // Derivado a otra entidad (policia, fiscalia)
  DESISTIMIENTO = 'DESISTIMIENTO'     // Reportante desistio o no coopero
}
```

### PhotoMetadata

```typescript
interface PhotoMetadata {
  url: string;
  capturedAt: Date | null;             // Timestamp EXIF
  gpsLat: number | null;              // Latitud EXIF
  gpsLng: number | null;              // Longitud EXIF
  fileSize: number;                    // Tamano en bytes
}
```

### AbuseReportAuditLog

```typescript
interface AbuseReportAuditLog {
  id: string;                          // UUID, PK
  reportId: string;                    // FK -> abuse_reports.id
  previousState: AbuseReportState | null;
  newState: AbuseReportState;
  changedBy: string;                   // FK -> users.id
  changeReason: string | null;
  metadata: Record<string, unknown>;   // Datos adicionales de la transicion
  createdAt: Date;
}
```

### Esquema SQL

```sql
-- Enum para estados de reporte de maltrato
CREATE TYPE abuse_report_state AS ENUM (
  'FILED', 'EN_REVISION', 'INVESTIGADO', 'RESUELTO'
);

CREATE TYPE abuse_category_enum AS ENUM (
  'NEGLIGENCIA', 'MALTRATO_FISICO', 'ABANDONO', 'HACINAMIENTO', 'EXPLOTACION', 'OTRO'
);

CREATE TYPE abuse_priority_enum AS ENUM (
  'CRITICO', 'ALTO', 'MEDIO', 'BAJO'
);

CREATE TYPE abuse_resolution_enum AS ENUM (
  'SANCION', 'DECOMISO', 'ABSUELTO', 'DERIVADO', 'DESISTIMIENTO'
);

-- Tabla principal de reportes de maltrato (MULTI-TENANT)
CREATE TABLE abuse_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES users(id),
  tenant_id UUID NOT NULL REFERENCES government_tenants(id),
  tracking_code VARCHAR(10) NOT NULL UNIQUE,

  -- Ubicacion
  location GEOMETRY(POINT, 4326) NOT NULL,
  address TEXT,

  -- Detalle del incidente
  description TEXT NOT NULL CHECK (char_length(description) >= 20),
  abuse_category abuse_category_enum NOT NULL,
  abuse_type VARCHAR(100),

  -- Evidencia (fotos almacenadas como array de URLs)
  photos TEXT[] NOT NULL CHECK (array_length(photos, 1) BETWEEN 1 AND 10),
  photo_metadata JSONB,

  -- Gestion municipal
  priority abuse_priority_enum,
  assigned_to UUID REFERENCES users(id),
  estado abuse_report_state NOT NULL DEFAULT 'FILED',

  -- Resolucion
  resolution_type abuse_resolution_enum,
  resolution_detail TEXT,
  resolved_at TIMESTAMP,

  -- Investigacion
  investigation_notes TEXT,
  investigation_evidence TEXT[],
  investigated_at TIMESTAMP,

  -- Metadatos
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

  -- Indices
  INDEX idx_abuse_tenant_estado (tenant_id, estado),
  INDEX idx_abuse_tenant_priority (tenant_id, priority),
  INDEX idx_abuse_tenant_created (tenant_id, created_at),
  INDEX idx_abuse_tracking_code (tracking_code),
  INDEX idx_abuse_reporter (reporter_id),
  INDEX idx_abuse_location USING GIST (location)
);

-- Tabla de auditoria de transiciones de estado
CREATE TABLE abuse_report_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id UUID NOT NULL REFERENCES abuse_reports(id),
  previous_state abuse_report_state,
  new_state abuse_report_state NOT NULL,
  changed_by UUID NOT NULL REFERENCES users(id),
  change_reason TEXT,
  metadata JSONB,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),

  INDEX idx_audit_report (report_id),
  INDEX idx_audit_created (created_at)
);

-- Row Level Security para segregacion multi-tenant (REQ-MT-005)
ALTER TABLE abuse_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_abuse_reports_policy ON abuse_reports
  USING (tenant_id = get_current_tenant_id());

-- Funcion para generar codigo de seguimiento unico
CREATE OR REPLACE FUNCTION generate_tracking_code() RETURNS VARCHAR(10) AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  code TEXT := 'MAL-';
  i INT;
BEGIN
  FOR i IN 1..6 LOOP
    code := code || substr(chars, floor(random() * length(chars) + 1)::int, 1);
  END LOOP;
  RETURN code;
END;
$$ LANGUAGE plpgsql;
```

---

## API Endpoints

### Servicio de Reportes (ciudadano)

```
POST /api/v1/abuse-reports                    # Crear reporte (auth requerido)
GET  /api/v1/abuse-reports/track/{code}       # Consultar estado por codigo (publico)
GET  /api/v1/abuse-reports/my-reports         # Listar reportes propios (auth requerido)
GET  /api/v1/abuse-reports/{id}               # Detalle de reporte propio (auth requerido)
```

### Government Service (panel municipal)

```
GET  /api/v1/government/abuse-reports                     # Listar reportes del tenant
GET  /api/v1/government/abuse-reports/{id}                # Detalle de reporte
PUT  /api/v1/government/abuse-reports/{id}/classify       # Clasificar: categoria + prioridad + asignar
PUT  /api/v1/government/abuse-reports/{id}/investigate    # Registrar hallazgos de investigacion
PUT  /api/v1/government/abuse-reports/{id}/resolve        # Cerrar caso con resolucion
GET  /api/v1/government/abuse-reports/stats               # Metricas agregadas para dashboard
GET  /api/v1/government/abuse-reports/export              # Exportar reporte de transparencia
```

---

## Referencia de Ingresos SRD

### Modelo de Revenue B2G

Los reportes de maltrato son parte integral de los contratos municipales B2G:

| Nivel de Contrato | Poblacion | Precio/mes | Incluye Maltrato |
|-------------------|-----------|------------|------------------|
| **Pequeno** | <50K hab. | $500/mes | Flujo de subsidios + reportes basicos |
| **Mediano** | 50-200K hab. | $800/mes | Panel completo + **reportes de maltrato** + analitica |
| **Grande** | >200K hab. | $1,500/mes | Multi-departamento + API + soporte prioritario |

**Ingreso objetivo**: 10 municipalidades x $750/mes promedio = $7,500/mes MRR total B2G.

### Atribucion de Ingresos

| Journey | Ingreso en Riesgo | % Atribucion de Conversion | Justificacion |
|---------|-------------------|----------------------------|---------------|
| **J5** Reportes de Maltrato | **$1,425/mes** | 15% | Canal digital que reemplaza lineas telefonicas: argumento directo de venta para P01 (Gabriela) |
| **J7** Panel Municipal | **$1,900/mes** | 20% | Dashboard donde los reportes de maltrato son KPI central para la toma de decisiones |

**Pain point clave de P01 (Gabriela):** "La linea telefonica municipal para reportes de maltrato tiene tiempos de espera de 45 minutos." Este feature es su trigger de compra inmediato.

---

## Criterios de Aceptacion

### Del Journey J5 (Reporte de Maltrato Autenticado)

- [ ] Usuario autenticado presenta reporte de maltrato con GPS + fotos en <3 minutos
- [ ] Codigo de seguimiento emitido inmediatamente al enviar
- [ ] Reporte se enruta automaticamente a la municipalidad correcta por GPS (PostGIS)
- [ ] El funcionario municipal revisa, clasifica y da seguimiento a reportes
- [ ] El usuario verifica el estado usando el codigo de seguimiento

### Del Journey J7 (Panel Municipal y Reportes)

- [ ] El panel muestra KPIs de maltrato con alcance de jurisdiccion a partir de datos disponibles
- [ ] La cola de elementos pendientes es accionable (clasificar, asignar, resolver en linea)
- [ ] Reporte de transparencia exportable como PDF con metricas de maltrato

### Criterios Adicionales del Dominio

- [ ] El formulario NO permite envio sin sesion iniciada (Regla SRD #9)
- [ ] GPS se captura automaticamente al abrir el formulario
- [ ] Al menos 1 foto es obligatoria como evidencia
- [ ] La descripcion tiene un minimo de 20 caracteres
- [ ] Las transiciones de estado generan registros de auditoria inmutables
- [ ] El SLA de prioridad se muestra visualmente en el panel municipal
- [ ] Los reportes en zonas fronterizas notifican a ambas jurisdicciones (REQ-JUR-003)
- [ ] Los reportes en zonas protegidas notifican a la entidad ambiental ademas del gobierno local (REQ-JUR-022)

### Personas Involucradas

| Persona | Rol en el Flujo | Acciones |
|---------|-----------------|----------|
| **P07 Andrea** (Centinela Casual) | Reportante principal | Presenta reportes de maltrato desde el movil |
| **P06 Miguel** (Lider de ONG) | Reportante secundario | Presenta reportes como parte de operaciones de rescate |
| **P01 Gabriela** (Tomadora de Decisiones B2G) | Supervisora municipal | Ve KPIs, genera reportes de transparencia |
| **P02 Laura** (Operadora Diaria B2G) | Gestora de casos | Clasifica, asigna investigadores, resuelve casos |

---

## Dependencias

### Prerequisitos

| Dependencia | Estado | Journey |
|-------------|--------|---------|
| J1 (Registro/Autenticacion) | **60% funcional** | Requerido para autenticacion obligatoria |
| `government_tenants` con poligonos | **Esquema definido, sin datos** | Requerido para enrutamiento por jurisdiccion |
| PostGIS habilitado | **Definido en design.md** | Requerido para consultas `ST_Contains` |
| Notification Service | **Parcial** (sin push) | Requerido para notificaciones de estado |

### Servicios Consumidos

- **Geolocation Service**: `ST_Contains` para enrutamiento, `ST_Distance` para canton mas cercano
- **Notification Service**: Push al funcionario municipal, email/push al reportante
- **User Service**: Validacion de autenticacion, datos del reportante

### Servicios que Consumen

- **Government Service**: Panel municipal, cola de reportes, metricas agregadas
- **Analytics Service**: Tendencias, deteccion de anomalias, mapas de calor de maltrato
