# Rescue Pipeline — Especificacion de Dominio

**Dominio**: Coordinacion de Rescate Animal y Gestion de Casas Cuna
**Microservicios involucrados**: Animal Rescue Service, Geolocation Service, Notification Service, Agent AI Service
**Prioridad**: Sprint 01 (critico para primer release)
**Fuentes**: `specs/altrupets/requirements.md`, `specs/altrupets/design.md`, `srd-espanol/journeys.md` (J2, J6)

---

## 1. Vision General

El Rescue Pipeline es el flujo central de coordinacion de rescate animal en AltruPets. Orquesta la cadena completa desde que un ciudadano (centinela) avista un animal vulnerable hasta que el animal es colocado en una casa cuna bajo el cuidado de un rescatista.

El pipeline comprende:

1. **Solicitud de auxilio** -- Un centinela reporta un animal vulnerable con GPS, fotos y nivel de urgencia.
2. **Matching de auxiliares** -- El sistema busca auxiliares cercanos por geolocalización y los notifica via push.
3. **Captura y documentacion** -- El auxiliar navega al lugar, captura al animal y documenta su estado.
4. **Solicitud de rescate** -- Si el auxiliar no tiene casa cuna propia, crea una solicitud de rescate.
5. **Matching de rescatistas** -- El sistema busca rescatistas con casa cuna disponible, ordenados por score de prioridad.
6. **Transferencia y registro** -- El rescatista acepta, recibe al animal y lo registra en su casa cuna con codigo de seguimiento.
7. **Gestion de casa cuna** -- El rescatista gestiona el inventario de animales, capacidad, necesidades y adoptabilidad.

**Ingresos en riesgo**: $255/mes (J2) + $720/mes (J6) = $975/mes

---

## 2. Actores

### 2.1. Centinela (P07)

- **Rol**: Persona que alerta sobre animales abandonados, maltratados, desnutridos, malheridos, enfermos o accidentados que necesitan captura inmediata.
- **Nivel tecnico**: Basico a intermedio con dispositivos moviles.
- **Frecuencia de uso**: Esporadica, basada en avistamientos de animales vulnerables.
- **Permisos**: UNICAMENTE puede enviar "solicitudes de auxilio" (REQ-BR-010). No puede enviar informes (REQ-BR-011). Requiere geolocalización obligatoria (REQ-BR-012).
- **Acciones**:
  - Crear solicitud de auxilio con GPS, descripcion, fotografias y nivel de urgencia.
  - Consultar estado de sus solicitudes via codigo de seguimiento.
  - Comunicarse con el auxiliar asignado por chat interno.

### 2.2. Auxiliar (P08)

- **Rol**: Persona con capacidad de capturar animales vulnerables y brindarles auxilio inmediato. Puede o no tener casa cuna propia.
- **Nivel tecnico**: Intermedio con aplicaciones moviles.
- **Frecuencia de uso**: Regular, segun disponibilidad.
- **Permisos**: UNICAMENTE puede enviar "solicitudes de rescate" (REQ-BR-020). No puede enviar informes (REQ-BR-021). Requiere referencia a solicitud de auxilio previa valida (REQ-BR-022).
- **Acciones**:
  - Recibir notificaciones push de solicitudes de captura en su area.
  - Aceptar o declinar solicitudes con justificacion.
  - Navegar via GPS al lugar del incidente.
  - Documentar la captura con fotografias y descripcion.
  - Crear solicitud de rescate si no tiene casa cuna propia.
  - Solicitar crowdfunding para gastos de transporte (REQ-AUX-006 a REQ-AUX-006D).

### 2.3. Rescatista (P05, P06)

- **Rol**: Persona con casa cuna que rescata y cuida animales a largo plazo, proporcionando comida, vacunas, castracion y cuidado maternal. Determina cuando un animal esta listo para adopcion y gestiona las solicitudes de adopcion.
- **Nivel tecnico**: Intermedio a avanzado.
- **Frecuencia de uso**: Diaria, gestion continua de animales.
- **Permisos**: Excepcion al Principio de Responsabilidad Unica (REQ-BR-030) -- puede enviar "solicitudes para atencion veterinaria" y "solicitudes de adopcion". No puede enviar informes (REQ-BR-031).
- **Acciones**:
  - Registrar casa cuna con ubicacion, capacidad, especies aceptadas.
  - Aceptar transferencias de animales desde auxiliares.
  - Registrar animales con datos medicos, comportamiento, fotos.
  - Gestionar inventario de capacidad y lista de necesidades.
  - Marcar animales como "Listos para Adoptar" (REQ-RES-005).
  - Gestionar solicitudes de adopcion recibidas (REQ-RES-005A, REQ-RES-005B).
  - Solicitar intervencion policial (REQ-RES-007 a REQ-RES-007D).

---

## 3. Maquina de Estados del Workflow de Rescate

### 3.1. Estados de Solicitud de Auxilio (WF-001+)

```
CREADA ──→ EN_REVISION ──→ ASIGNADA ──→ EN_PROGRESO ──→ COMPLETADA
  │             │                                           ↑
  │             └──→ RECHAZADA                              │
  └──→ ASIGNADA ────────────────────────────────────────────┘
  └──→ RECHAZADA
```

| Estado | Transiciones permitidas | Descripcion |
|--------|------------------------|-------------|
| `CREADA` | `EN_REVISION`, `ASIGNADA`, `RECHAZADA` | El centinela creo la solicitud de auxilio |
| `EN_REVISION` | `ASIGNADA`, `RECHAZADA` | El sistema esta buscando auxiliares |
| `ASIGNADA` | `EN_PROGRESO`, `COMPLETADA` | Un auxiliar acepto la solicitud |
| `EN_PROGRESO` | `COMPLETADA` | El auxiliar esta en camino o capturando al animal |
| `COMPLETADA` | _(estado final)_ | El auxiliar documento la captura |
| `RECHAZADA` | _(estado final)_ | La solicitud fue rechazada |

**Transicion automatica WF-040**: Cuando una solicitud de auxilio pasa a `COMPLETADA`, el sistema crea automaticamente una solicitud de rescate si el auxiliar no tiene casa cuna propia.

### 3.2. Estados de Solicitud de Rescate (WF-010+)

```
CREADA ──→ PENDIENTE_SUBVENCION ──→ SUBVENCION_APROBADA ──→ ASIGNADA ──→ EN_PROGRESO ──→ RESCATADO ──→ COMPLETADA
  │             │                                                ↑
  │             └──→ SUBVENCION_RECHAZADA ──────────────────────┘
  │                                                              ↑
  └──→ AUTORIZADA ──────────────────────────────────────────────┘
  └──→ RECHAZADA
```

| Estado | Transiciones permitidas | Descripcion |
|--------|------------------------|-------------|
| `CREADA` | `PENDIENTE_SUBVENCION`, `AUTORIZADA`, `RECHAZADA` | El auxiliar creo la solicitud de rescate |
| `PENDIENTE_SUBVENCION` | `SUBVENCION_APROBADA`, `SUBVENCION_RECHAZADA`, `AUTORIZADA` | Esperando respuesta de subvencion municipal |
| `SUBVENCION_APROBADA` | `ASIGNADA` | La municipalidad aprobo la subvencion veterinaria |
| `SUBVENCION_RECHAZADA` | `ASIGNADA` | La subvencion fue rechazada; el rescatista asume el costo |
| `AUTORIZADA` | `ASIGNADA` | El rescate fue autorizado sin subvencion |
| `ASIGNADA` | `EN_PROGRESO` | Un rescatista con capacidad acepto la transferencia |
| `EN_PROGRESO` | `RESCATADO` | La transferencia del animal esta en curso |
| `RESCATADO` | `COMPLETADA` | El animal fue recibido en la casa cuna |
| `COMPLETADA` | _(estado final)_ | El rescate concluyo exitosamente |
| `RECHAZADA` | _(estado final)_ | La solicitud fue rechazada |

**Transicion automatica REQ-BR-060**: Cuando se crea una solicitud de rescate y el animal tiene condicion `callejero = TRUE`, `herido = TRUE` o `enfermo = TRUE`, el sistema crea automaticamente una solicitud de subvencion veterinaria y transiciona a `PENDIENTE_SUBVENCION`.

**Transicion automatica REQ-WF-052**: Cuando la subvencion es aprobada, se emite factura municipal automatica.

**Transicion automatica REQ-WF-053, REQ-WF-054**: Cuando la subvencion es rechazada o expirada, se emite factura al rescatista automatica.

### 3.3. Estados de la Entidad Animal

```
REPORTADO → EVALUADO → EN_RESCATE → EN_CUIDADO → ADOPTABLE → ADOPTADO
                                         │
                                         ├──→ NO_ADOPTABLE
                                         └──→ FALLECIDO

Cualquier estado → INALCANZABLE
Cualquier estado → FALSA_ALARMA
```

| Estado | Descripcion |
|--------|-------------|
| `REPORTADO` | Animal avistado por centinela, solicitud de auxilio creada |
| `EVALUADO` | Auxiliar documento al animal con fotos y evaluacion |
| `EN_RESCATE` | Animal en proceso de transferencia a rescatista |
| `EN_CUIDADO` | Animal en casa cuna bajo cuidado del rescatista |
| `ADOPTABLE` | El rescatista marco al animal como listo para adopcion (BR-050, BR-051) |
| `ADOPTADO` | El animal fue adoptado exitosamente |
| `NO_ADOPTABLE` | El animal no cumple criterios de adoptabilidad |
| `FALLECIDO` | El animal fallecio durante el proceso |
| `INALCANZABLE` | No fue posible capturar al animal |
| `FALSA_ALARMA` | El reporte original no correspondia a una situacion real |

**Transicion automatica WF-041**: Cuando se actualizan los atributos de un animal en estado `EN_CUIDADO`, el sistema evalua automaticamente la adoptabilidad. Si cumple todos los requisitos (BR-050) y no tiene restricciones (BR-051), transiciona a `ADOPTABLE`.

---

## 4. Gestion de Casas Cuna

### 4.1. Registro de Casa Cuna (REQ-RES-001)

El registro de una casa cuna requiere obligatoriamente:

**Informacion basica del rescatista:**
- Capacidad de casa cuna (numero maximo de animales)
- Experiencia previa en rescate animal (anos, casos atendidos)
- Ubicacion geografica precisa de las instalaciones (GPS)
- Recursos disponibles (economicos, veterinarios, suministros)

**Contactos de emergencia OBLIGATORIOS (REQ-RES-001A):**
- Contacto familiar directo con acceso fisico a las instalaciones
- Rescatista "padrino" verificado que pueda asumir todos los animales bajo cuidado
- Contacto de acceso con informacion de llaves, codigos, alarmas y ubicacion de suministros

**Contactos de emergencia OPCIONALES:**
- Veterinario de confianza (se puede asignar despues del primer rescate)

**Informacion de contingencia OBLIGATORIA:**
- Inventario inicial de capacidad de casa cuna
- Protocolos especificos de cuidado por tipo de animal
- Ubicacion de suministros medicos y alimentarios
- Instrucciones de emergencia para acceso a instalaciones

### 4.2. Reglas de Asociacion Rescatista-Casa Cuna

| Regla | ID | Descripcion |
|-------|-----|-------------|
| Un rescatista puede tener multiples casas cuna | REQ-BR-001 | Relacion 1:N rescatista -> casas cuna |
| Una casa cuna puede tener multiples rescatistas | REQ-BR-002 | Relacion N:1 rescatistas -> casa cuna |
| Autorizacion bilateral requerida | REQ-BR-003 | Ambas partes deben aprobar explicitamente la asociacion |

**Modelo de datos de la asociacion:**

```sql
CREATE TABLE rescatista_casa_cuna_associations (
  id UUID PRIMARY KEY,
  rescatista_id UUID NOT NULL,
  casa_cuna_id UUID NOT NULL,
  rescatista_approved BOOLEAN DEFAULT FALSE,
  casa_cuna_approved BOOLEAN DEFAULT FALSE,
  rescatista_approved_at TIMESTAMP,
  casa_cuna_approved_at TIMESTAMP,
  association_active BOOLEAN GENERATED ALWAYS AS (
    rescatista_approved = TRUE AND casa_cuna_approved = TRUE
  ) STORED,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(rescatista_id, casa_cuna_id)
);
```

### 4.3. Verificacion del Rescatista "Padrino" (REQ-RES-001B)

El rescatista "padrino" debe cumplir:
- Experiencia minima de 2 anos como rescatista activo
- Reputacion minima de 4.0/5.0 estrellas
- Capacidad fisica adicional para asumir animales de emergencia
- Ubicado en radio maximo de 25km del rescatista titular
- Confirmacion explicita de disponibilidad para emergencias

### 4.4. Apoyo para Encontrar Veterinario de Confianza (REQ-RES-001C)

- Mostrar veterinarios registrados en radio de 25km con tarifas preferenciales
- Proporcionar recomendaciones de otros rescatistas en la zona
- Facilitar contacto con Bienestar Animal local
- Permitir operar sin veterinario asignado por maximo 90 dias
- Enviar recordatorios semanales para asignar veterinario
- Requerir veterinario asignado antes de recibir el tercer animal rescatado

### 4.5. Inventario y Capacidad

- Vista de inventario: animales actuales y espacios disponibles
- Gestion de capacidad dinamica por especie aceptada
- La capacidad disponible alimenta el algoritmo de matching de rescatistas (GEO-011)

### 4.6. Lista de Necesidades

Publicacion de necesidades visibles para donantes (P10):
- Comida
- Medicina
- Suministros
- Juguetes
- Las necesidades alimentan el flujo de donaciones (J8)

---

## 5. Geolocalizacion y Matching

### 5.1. Geolocation Service

**Responsabilidades:**
- Calculos geoespaciales y busquedas por proximidad (PostGIS)
- Optimizacion de rutas para rescates
- Matching de rescatistas por distancia y disponibilidad
- Gestion de jurisdicciones gubernamentales

**Stack:**
- PostGIS (extension PostgreSQL) con indices GIST
- Redis para cache de consultas frecuentes de proximidad
- API endpoints: `POST /api/v1/location/proximity`, `GET /api/v1/location/rescuers/nearby`, `POST /api/v1/location/route/optimize`

### 5.2. Reglas de Busqueda de Auxiliares (GEO-001 a GEO-004)

Busqueda escalonada con expansion automatica por tiempo:

| Regla | Radio | Tiempo | Descripcion |
|-------|-------|--------|-------------|
| GEO-001 | 10 km | Inmediato | Busqueda inicial de auxiliares disponibles |
| GEO-002 | 25 km | +30 minutos | Expansion automatica si no hay auxiliares en el radio inicial |
| GEO-003 | 50 km | +60 minutos | Expansion maxima intermedia + alerta a supervisores |
| GEO-004 | 100 km | Limite maximo | Radio maximo absoluto para busqueda de auxiliares |

**Implementacion PostGIS:**

```sql
CREATE OR REPLACE FUNCTION find_auxiliares_by_proximity(
  center_point GEOMETRY(POINT, 4326),
  initial_radius_km INTEGER DEFAULT 10
) RETURNS TABLE (
  auxiliar_id UUID,
  distance_km DECIMAL,
  priority_score DECIMAL
) AS $$
DECLARE
  current_radius INTEGER := initial_radius_km;
  max_radius INTEGER := 100; -- GEO-004: Maximo 100km
BEGIN
  RETURN QUERY
  SELECT
    l.user_id,
    ST_Distance(l.coordinates, center_point) / 1000 AS distance_km,
    calculate_auxiliar_priority_score(l.user_id, center_point) AS priority_score
  FROM locations l
  JOIN users u ON u.id = l.user_id
  WHERE u.user_type = 'AUXILIAR'
    AND u.is_available = TRUE
    AND ST_DWithin(l.coordinates, center_point, current_radius * 1000)
  ORDER BY priority_score DESC, distance_km ASC;
END;
$$ LANGUAGE plpgsql;
```

### 5.3. Reglas de Busqueda de Rescatistas (GEO-010 a GEO-012)

| Regla | Radio | Descripcion |
|-------|-------|-------------|
| GEO-010 | 15 km | Radio inicial de busqueda de rescatistas con casa cuna |
| GEO-011 | -- | Priorizar rescatistas con capacidad disponible (`get_casa_cuna_available_capacity > 0`) |
| GEO-012 | -- | Ordenamiento por score de priorizacion (ver algoritmo abajo) |

**Implementacion PostGIS:**

```sql
CREATE OR REPLACE FUNCTION find_rescatistas_by_proximity(
  center_point GEOMETRY(POINT, 4326),
  radius_km INTEGER DEFAULT 15
) RETURNS TABLE (
  rescatista_id UUID,
  distance_km DECIMAL,
  priority_score DECIMAL,
  available_capacity INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    l.user_id,
    ST_Distance(l.coordinates, center_point) / 1000 AS distance_km,
    calculate_rescatista_priority_score(l.user_id, center_point) AS priority_score,
    get_casa_cuna_available_capacity(l.user_id) AS available_capacity
  FROM locations l
  JOIN users u ON u.id = l.user_id
  WHERE u.user_type = 'RESCATISTA'
    AND u.is_available = TRUE
    AND ST_DWithin(l.coordinates, center_point, radius_km * 1000)
    AND get_casa_cuna_available_capacity(l.user_id) > 0 -- GEO-011
  ORDER BY priority_score DESC, distance_km ASC;
END;
$$ LANGUAGE plpgsql;
```

### 5.4. Algoritmo de Scoring de Rescatistas (GEO-012)

El score de priorizacion combina cuatro factores con pesos ponderados:

```
score_final = (scoreDistancia * 0.30) +
              (scoreCapacidad * 0.25) +
              (scoreReputacion * 0.25) +
              (scoreEspecializacion * 0.20)
```

| Factor | Peso | Calculo | Rango |
|--------|------|---------|-------|
| **Distancia** | 30% | `max(0, 100 - (distancia_metros / 1000))` | 0-100 |
| **Capacidad disponible** | 25% | `min(100, espacios_disponibles * 10)` | 0-100 |
| **Reputacion** | 25% | `reputacion_estrellas * 20` | 0-100 |
| **Especializacion** | 20% | `100` si tiene especializacion en condicion del animal, `50` si no | 50 o 100 |

**Fuente del calculo:**

```typescript
private calculateRescatistaScore(rescatista: Rescatista, solicitud: SolicitudRescate): number {
  const distancia = this.calculateDistance(rescatista.ubicacion, solicitud.ubicacion);
  const scoreDistancia = Math.max(0, 100 - (distancia / 1000));

  const capacidadDisponible = rescatista.casasCuna.reduce((total, casa) =>
    total + (casa.capacidadMaxima - casa.animalesActuales), 0);
  const scoreCapacidad = Math.min(100, capacidadDisponible * 10);

  const scoreReputacion = rescatista.reputacion * 20;

  const tieneEspecializacion = rescatista.especializaciones.some(esp =>
    solicitud.animal.condiciones.includes(esp));
  const scoreEspecializacion = tieneEspecializacion ? 100 : 50;

  return (scoreDistancia * 0.3) +
         (scoreCapacidad * 0.25) +
         (scoreReputacion * 0.25) +
         (scoreEspecializacion * 0.2);
}
```

### 5.5. Agent AI Service (Matching Avanzado)

Microservicio NestJS independiente (puerto 4000) con GraphQL que utiliza inteligencia artificial para recomendar rescatistas optimos. Consulta el backend principal via GraphQL y mantiene un grafo de conocimiento en FalkorDB.

**Operacion principal:**

```graphql
type Mutation {
  recommendRescuers(
    captureRequestId: String!
    latitude: Float!
    longitude: Float!
    animalType: String!
  ): RecommendationResult!
}

type RescuerRecommendation {
  userId: String!
  username: String!
  roles: [String!]!
  distanceKm: Float!
  score: Float!
  reasoning: String!
}
```

**Stack AI**: LangGraph (StateGraph) + OpenAI GPT-4o + Zep Cloud (memoria conversacional) + Langfuse (observabilidad) + FalkorDB (grafo de rescatistas).

### 5.6. Validacion de Jurisdicciones (JUR-001 a JUR-022)

Las reglas de jurisdiccion son relevantes para el rescue pipeline cuando se activa la subvencion veterinaria automatica:

| Regla | Descripcion |
|-------|-------------|
| JUR-010 | Solo encargados de la jurisdiccion correspondiente pueden autorizar subvenciones |
| JUR-011 | La jurisdiccion se determina por ubicacion exacta del animal |
| JUR-012 | Casos fronterizos requieren autorizacion multiple de ambas jurisdicciones |
| JUR-020 | Animales en carreteras nacionales: se asigna al canton mas cercano |
| JUR-021 | Animales en zonas protegidas: requiere autorizacion ambiental adicional (SINAC en Costa Rica, SEMARNAT en Mexico) |

---

## 6. Entidad Animal

### 6.1. Modelo de Datos

```sql
CREATE TABLE animals (
  id UUID PRIMARY KEY,
  name VARCHAR(255),
  species species_enum,
  breed VARCHAR(255),
  age_months INTEGER,
  sex sex_enum,

  -- Condiciones del animal (BR-060: disparadores de subvencion)
  discapacitado BOOLEAN DEFAULT FALSE,
  paciente_cronico BOOLEAN DEFAULT FALSE,
  zeropositivo BOOLEAN DEFAULT FALSE,
  callejero BOOLEAN DEFAULT FALSE,

  -- Requisitos de adoptabilidad (BR-050: TODOS deben ser TRUE)
  usa_arenero BOOLEAN DEFAULT FALSE,
  come_por_si_mismo BOOLEAN DEFAULT FALSE,

  -- Restricciones de adoptabilidad (BR-051: CUALQUIERA impide adopcion)
  arizco_con_humanos BOOLEAN DEFAULT FALSE,
  arizco_con_animales BOOLEAN DEFAULT FALSE,
  lactante BOOLEAN DEFAULT FALSE,
  nodriza BOOLEAN DEFAULT FALSE,
  enfermo BOOLEAN DEFAULT FALSE,
  herido BOOLEAN DEFAULT FALSE,
  recien_parida BOOLEAN DEFAULT FALSE,
  recien_nacido BOOLEAN DEFAULT FALSE,

  -- Estado y metadatos
  current_state animal_state DEFAULT 'REPORTADO',
  current_caretaker_id UUID,      -- FK al rescatista actual
  casa_cuna_id UUID,              -- FK a la casa cuna donde reside
  rescue_date TIMESTAMP,
  adoptability_last_checked TIMESTAMP,

  -- Campo calculado de adoptabilidad
  is_adoptable BOOLEAN GENERATED ALWAYS AS (
    usa_arenero = TRUE AND come_por_si_mismo = TRUE AND
    arizco_con_humanos = FALSE AND arizco_con_animales = FALSE AND
    lactante = FALSE AND nodriza = FALSE AND enfermo = FALSE AND
    herido = FALSE AND recien_parida = FALSE AND recien_nacido = FALSE
  ) STORED,

  version INTEGER DEFAULT 1,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### 6.2. Enum de Estados

```sql
CREATE TYPE animal_state AS ENUM (
  'REPORTADO', 'EVALUADO', 'EN_RESCATE', 'EN_CUIDADO', 'ADOPTABLE',
  'ADOPTADO', 'NO_ADOPTABLE', 'FALLECIDO', 'INALCANZABLE', 'FALSA_ALARMA'
);
```

### 6.3. Triggers de Integridad

**BR-082: Recien nacido implica lactante**

```sql
IF NEW.recien_nacido = TRUE THEN
  NEW.lactante = TRUE;
END IF;
```

**BR-081: Incompatibilidad comer por si mismo vs lactante**

```sql
IF NEW.come_por_si_mismo = TRUE AND NEW.lactante = TRUE THEN
  RAISE EXCEPTION 'Un animal lactante no puede comer por si mismo (BR-081)';
END IF;
```

**BR-060: Trigger de autorizacion veterinaria automatica**

Cuando se crea una `solicitud_rescate`, si el animal tiene `callejero = TRUE`, `herido = TRUE` o `enfermo = TRUE`, se crea automaticamente una `veterinary_authorization` y se marca `requires_veterinary_auth = TRUE` en la solicitud.

### 6.4. Relaciones

| Relacion | Tipo | Descripcion |
|----------|------|-------------|
| `animals.current_caretaker_id` → `users.id` | N:1 | Rescatista responsable actual |
| `animals.casa_cuna_id` → casa cuna | N:1 | Casa cuna donde reside |
| `solicitudes_rescate.solicitud_auxilio_id` → `solicitudes_auxilio.id` | N:1 | Referencia al auxilio original |
| `solicitudes_rescate.assigned_rescatista_id` → `users.id` | N:1 | Rescatista asignado |
| `solicitudes_auxilio.assigned_auxiliar_id` → `users.id` | N:1 | Auxiliar asignado |
| `rescatista_casa_cuna_associations` | N:M | Asociacion many-to-many rescatistas-casas cuna |

---

## 7. Reglas de Negocio

### 7.1. Coordinacion de Rescate

| ID | Regla |
|----|-------|
| REQ-COORD-001 | Cuando un centinela identifique un animal vulnerable, el sistema debe permitir crear solicitud de captura con GPS, descripcion, fotos y urgencia, notificar a auxiliares en 5km y establecer chat directo |
| REQ-COORD-002 | Cuando un auxiliar reciba solicitud de captura, el sistema debe mostrar push inmediata, permitir aceptar/declinar con justificacion y proporcionar navegacion GPS |
| REQ-COORD-003 | Cuando un auxiliar capture un animal y no tenga casa cuna propia, el sistema debe permitir crear solicitud de rescate, mostrar rescatistas con casa cuna en 15km, documentar estado y facilitar transferencia |
| REQ-COORD-004 | Cuando se inicie un proceso de captura o rescate, el sistema debe generar codigo de seguimiento unico, mantener historial completo y permitir consultar estado a todos los participantes |

### 7.2. Funciones por Rol

| ID | Regla |
|----|-------|
| REQ-CEN-001 | Registro de centinelas con datos basicos, ubicacion y motivacion |
| REQ-CEN-002 | Creacion de solicitudes de captura con GPS, descripcion, fotos opcionales y urgencia |
| REQ-CEN-003 | Seguimiento de solicitudes via codigo de seguimiento unico |
| REQ-CEN-004 | Comunicacion directa centinela-auxiliar por chat interno |
| REQ-AUX-001 | Registro de auxiliares con verificacion de transporte, disponibilidad y experiencia |
| REQ-AUX-002 | Recepcion de solicitudes con push inmediata incluyendo detalles y distancia |
| REQ-AUX-003 | Procesamiento con info de contacto del centinela y navegacion GPS |
| REQ-AUX-004 | Creacion de solicitudes de rescate cuando no tenga casa cuna propia |
| REQ-AUX-005 | Documentacion de captura con fotos y descripcion |
| REQ-AUX-006 | Solicitud de crowdfunding para gastos de transporte (maximo $50 USD, 2 por mes) |
| REQ-RES-001 | Registro con contactos de emergencia obligatorios (familiar, padrino, acceso) |
| REQ-RES-002 | Gestion de casa cuna: registrar datos medicos, comportamiento, fotos |
| REQ-RES-003 | Gestion financiera: registrar gastos por categorias |
| REQ-RES-004 | Coordinacion veterinaria: mostrar veterinarios cercanos y solicitar atencion |
| REQ-RES-005 | Marcado de animal "Listo para Adoptar" y publicacion automatica en catalogo |
| REQ-RES-006 | Recepcion de donaciones con registro automatico y agradecimiento |

### 7.3. Asociaciones Rescatista-Casa Cuna

| ID | Regla |
|----|-------|
| REQ-BR-001 | Un rescatista puede tener multiples casas cuna |
| REQ-BR-002 | Una casa cuna puede estar asociada a multiples rescatistas |
| REQ-BR-003 | Toda asociacion requiere autorizacion explicita de ambas partes |

### 7.4. Principio de Responsabilidad Unica para Solicitudes

| ID | Regla |
|----|-------|
| REQ-BR-010 | Centinela SOLO envia solicitudes de auxilio |
| REQ-BR-011 | Centinela NO puede enviar informes |
| REQ-BR-012 | Solicitud de auxilio requiere geolocalizacion obligatoria |
| REQ-BR-020 | Auxiliar SOLO envia solicitudes de rescate |
| REQ-BR-021 | Auxiliar NO puede enviar informes |
| REQ-BR-022 | Solicitud de rescate requiere referencia a auxilio previo valido |
| REQ-BR-025 | Reconocimiento formal de que rescatistas violan el principio por razones de dominio |
| REQ-BR-026 | Criterios para solicitudes veterinarias: evaluar conocimientos, insumos, diagnostico, riesgo |
| REQ-BR-027 | Criterios para solicitudes de adopcion: animal debe cumplir BR-050 y BR-051 |
| REQ-BR-028 | Implementar formularios diferenciados, validaciones especificas, trazabilidad |
| REQ-BR-030 | Rescatista puede enviar solicitudes veterinarias Y de adopcion (excepcion justificada) |
| REQ-BR-031 | Rescatista NO puede enviar informes |
| REQ-BR-032 | Solicitud de adopcion requiere adoptabilidad completa verificada |

### 7.5. Adoptabilidad de Animales

| ID | Regla |
|----|-------|
| REQ-BR-050 | Requisitos minimos: `usa_arenero = TRUE` Y `come_por_si_mismo = TRUE` (todos deben cumplirse) |
| REQ-BR-051 | Restricciones que impiden adopcion: `arizco_con_humanos`, `arizco_con_animales`, `lactante`, `nodriza`, `enfermo`, `herido`, `recien_parida`, `recien_nacido` (cualquiera impide) |
| REQ-BR-060 | Solicitud de atencion veterinaria automatica si animal es callejero, herido o enfermo |
| REQ-BR-070 | Autorizacion veterinaria gubernamental solo si esta en jurisdiccion Y animal es callejero |
| REQ-BR-080 | Validar que no existan conflictos entre requisitos y restricciones |
| REQ-BR-081 | Incompatibilidad: `come_por_si_mismo = TRUE` Y `lactante = TRUE` es invalido |
| REQ-BR-082 | `recien_nacido = TRUE` implica automaticamente `lactante = TRUE` |

### 7.6. Continuidad y Contingencia

| ID | Regla |
|----|-------|
| REQ-CONT-001 | Deteccion automatica de inactividad tras 7 dias sin acceso |
| REQ-CONT-002 | Contactos de emergencia obligatorios para rescatistas |
| REQ-CONT-006 | Protocolo de transferencia automatica cuando rescatista no puede continuar |
| REQ-CONT-007 | Escalamiento automatico por rol (centinelas: redistribucion; auxiliares: radio expandido; rescatistas: emergencia critica) |

---

## 8. Criterios de Aceptacion

### 8.1. J2 -- Pipeline de Coordinacion de Rescate

| # | Criterio | Estado | Fix estimado |
|---|----------|--------|-------------|
| AC-J2-01 | El centinela crea alerta con GPS + fotos en <3 minutos | FALLA | T0-1, T1-1 |
| AC-J2-02 | Auxiliares cercanos reciben push en 30 segundos | FALLA | T1-1, T1-3 |
| AC-J2-03 | El auxiliar navega a la ubicacion GPS exacta | FALLA | T1-1 |
| AC-J2-04 | El sistema muestra rescatistas con espacio disponible en 15km | FALLA | T0-9, T1-1 |
| AC-J2-05 | Animal registrado con codigo de seguimiento al colocarse en hogar temporal | FALLA | T0-1, T0-2 |
| AC-J2-06 | Todos los participantes rastrean el caso en tiempo real | FALLA | T1-4 |

### 8.2. J6 -- Casa Cuna y Gestion Animal

| # | Criterio | Estado | Fix estimado |
|---|----------|--------|-------------|
| AC-J6-01 | Registrar hogar temporal con ubicacion y capacidad | FALLA | T0-2 |
| AC-J6-02 | Agregar/eliminar animales con fotos y notas medicas | FALLA | T0-1, T0-2 |
| AC-J6-03 | Vista de inventario muestra animales actuales y espacios disponibles | FALLA | T0-2 |
| AC-J6-04 | Lista de necesidades publicada y visible para donantes | FALLA | T0-2 |

---

## 9. Referencias a Recorridos SRD

### 9.1. J2: Pipeline de Coordinacion de Rescate

- **Puntuacion SRD**: 15%
- **Personas**: P07 (Centinela), P08 (Auxiliar), P05/P06 (Rescatista)
- **Etiqueta de ingresos**: Value-Delivery
- **Ingresos en riesgo**: $255/mes
- **Dependencias**: J1 (Registro/Incorporacion) + J6 (Gestion Casa Cuna) + J10 (Chat)

**Pasos del recorrido:**

| Paso | Accion | Pantalla | Datos |
|------|--------|----------|-------|
| 1 | Centinela abre "Crear Alerta de Auxilio" | `/rescues/new-alert` [TBD] | GPS, camara |
| 2 | Centinela envia solicitud de auxilio | GraphQL `createCaptureRequest` | Centinela autenticado |
| 3 | Sistema encuentra auxiliares cercanos | Servicio de Geolocalizacion | PostGIS, disponibilidad |
| 4 | Auxiliar recibe notificacion push | Push -> `/rescues/alert/{id}` [TBD] | Token Firebase |
| 5 | Auxiliar acepta y navega | `/rescues/alert/{id}/navigate` [TBD] | Integracion mapas |
| 6 | Auxiliar documenta al animal | `/rescues/alert/{id}/update` [TBD] | Camara |
| 7 | Sistema encuentra rescatistas con espacio | Servicio de Geolocalizacion | PostGIS, datos casa cuna |
| 8 | Rescatista acepta la transferencia | `/rescues/alert/{id}` [TBD] | Disponibilidad |
| 9 | Animal registrado en casa cuna | `/casa-cuna/animals/new` [TBD] | Entidad animal |
| 10 | Todos ven el estado | `/rescues/alert/{id}/status` [TBD] | WebSocket |

**Estado actual:**
- Paso 2: **Parcial** -- `createCaptureRequest` existe pero falta guard de auth (brecha de seguridad), sin flujo de estados, sin FK `userId`.
- Pasos 1, 4-10: **Faltante** -- Sin UI de creacion de alertas, sin PostGIS, sin push, sin logica de asignacion, sin entidad Animal.
- Movil `rescues_page.dart`: Cuadricula de tarjetas de servicio, todos `onTap: () {}` no-ops.

### 9.2. J6: Casa Cuna y Gestion Animal

- **Puntuacion SRD**: 10%
- **Personas**: P05, P06
- **Etiqueta de ingresos**: Value-Delivery
- **Ingresos en riesgo**: $720/mes
- **Dependencias**: J1 (Registro/Incorporacion)
- **Dependientes**: J2 (Coordinacion de Rescate), J3 (Adopcion), J4 (Subsidio Veterinario), J8 (Donacion)

**Pasos del recorrido:**

| Paso | Accion | Pantalla | Datos |
|------|--------|----------|-------|
| 1 | Registrar casa cuna | `/profile/foster-homes` (stub existe) | GPS, entidad |
| 2 | Agregar animal | `/casa-cuna/animals/new` [TBD] | Entidad animal |
| 3 | Actualizar estado del animal | `/casa-cuna/animals/{id}` [TBD] | Notas medicas, peso, comportamiento |
| 4 | Gestionar capacidad | `/profile/foster-homes` | Inventario, espacios, necesidades |
| 5 | Publicar lista de necesidades | `/casa-cuna/needs` [TBD] | Comida, medicina, suministros |

**Estado actual:**
- `foster_homes_management_page.dart` existe como shell de UI con botones pero sin llamadas al backend.
- Sin entidad Animal en la BD.

### 9.3. Grafo de Dependencia

```
J1 (Registro/Incorporacion) <- RAIZ
  |
  +-- J6 (Gestion Casa Cuna) <- depende de J1
  |     +-- J3 (Adopcion) <- depende de J1 + J6
  |     +-- J4 (Subsidio Veterinario) <- depende de J1 + J6 + J9
  |     +-- J8 (Donacion) <- depende de J1 + J6 (necesita listados del inventario)
  |
  +-- J2 (Coordinacion de Rescate) <- depende de J1 + J6 + J10
```

J6 es prerequisito de J2. Sin gestion de casas cuna funcional, el pipeline de rescate no puede completar la colocacion de animales.

---

## Apendice A: Modelo de Datos de Solicitudes

### Solicitudes de Auxilio

```sql
CREATE TABLE solicitudes_auxilio (
  id UUID PRIMARY KEY,
  centinela_id UUID,
  location POINT NOT NULL,
  description TEXT,
  urgency urgency_level_enum,
  status solicitud_auxilio_state DEFAULT 'CREADA',
  assigned_auxiliar_id UUID,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Solicitudes de Rescate

```sql
CREATE TABLE solicitudes_rescate (
  id UUID PRIMARY KEY,
  auxiliar_id UUID NOT NULL,
  solicitud_auxilio_id UUID REFERENCES solicitudes_auxilio(id),
  location POINT NOT NULL,
  description TEXT,
  status solicitud_rescate_state DEFAULT 'CREADA',
  assigned_rescatista_id UUID,
  requires_veterinary_auth BOOLEAN DEFAULT FALSE,
  veterinary_auth_requested_at TIMESTAMP,
  veterinary_auth_approved_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Autorizaciones Veterinarias

```sql
CREATE TABLE veterinary_authorizations (
  id UUID PRIMARY KEY,
  solicitud_rescate_id UUID REFERENCES solicitudes_rescate(id),
  encargado_bienestar_id UUID NOT NULL,
  jurisdiction_id UUID NOT NULL,
  animal_location POINT NOT NULL,
  authorization_status authorization_status_enum DEFAULT 'PENDIENTE',
  justification TEXT,
  authorized_at TIMESTAMP,
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);
```

## Apendice B: Esquema PostGIS de Geolocalizacion

```sql
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE locations (
  id UUID PRIMARY KEY,
  user_id UUID,
  coordinates GEOMETRY(POINT, 4326),
  address TEXT,
  precision_meters DECIMAL(5,2),
  location_type location_type_enum DEFAULT 'NORMAL',
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE government_jurisdictions (
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  government_entity_id UUID NOT NULL,
  jurisdiction_polygon GEOMETRY(POLYGON, 4326) NOT NULL,
  jurisdiction_type jurisdiction_type_enum DEFAULT 'MUNICIPAL',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE special_zones (
  id UUID PRIMARY KEY,
  zone_type special_zone_type_enum NOT NULL,
  zone_polygon GEOMETRY(POLYGON, 4326) NOT NULL,
  zone_name VARCHAR(255),
  requires_environmental_auth BOOLEAN DEFAULT FALSE,
  environmental_entity VARCHAR(255),
  metadata JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE proximity_searches (
  id UUID PRIMARY KEY,
  search_type proximity_search_type_enum,
  center_point GEOMETRY(POINT, 4326),
  radius_km INTEGER,
  search_criteria JSONB,
  results JSONB,
  cached_until TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Indices espaciales
CREATE INDEX idx_locations_geom ON locations USING GIST (coordinates);
CREATE INDEX idx_jurisdictions_polygon ON government_jurisdictions USING GIST (jurisdiction_polygon);
CREATE INDEX idx_special_zones_polygon ON special_zones USING GIST (zone_polygon);
CREATE INDEX idx_proximity_searches_point ON proximity_searches USING GIST (center_point);
```

## Apendice C: Eventos del Sistema

Eventos publicados por el Animal Rescue Service via message broker:

```yaml
AnimalRescueService:
  - rescue.requested     # Solicitud de rescate creada
  - rescue.completed     # Rescate completado
  - animal.rescued       # Animal registrado en casa cuna
```

Eventos consumidos desde otros servicios:

```yaml
FinancialService:
  - veterinary.subsidy.requested   # Subvencion solicitada (REQ-BR-060 automatico)
  - veterinary.subsidy.approved    # Subvencion aprobada (REQ-WF-052)
  - veterinary.subsidy.rejected    # Subvencion rechazada (REQ-WF-053)
  - veterinary.subsidy.expired     # Subvencion expirada (REQ-WF-054)

NotificationService:
  - notification.sent              # Notificacion enviada a participante
```
