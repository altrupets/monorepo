# AltruPets - Plataforma de Proteccion Animal

## 1. Vision General del Sistema

AltruPets es una plataforma integral de proteccion animal basada en arquitectura de microservicios cloud-native, desplegada como SaaS. Su mision es conectar eficientemente a todos los actores del ecosistema de rescate animal: centinelas, auxiliares, rescatistas, adoptantes, donantes, veterinarios y gobiernos locales.

**Funcionalidades principales:**

- Coordinacion de redes de rescate animal entre centinelas, auxiliares y rescatistas
- Gestion de denuncias de maltrato animal (autenticadas, no anonimas — regla SRD #9)
- Administracion de casas cuna y procesos de adopcion
- Sistema de subvencion municipal veterinaria (REQ-FIN-VET-001 a REQ-FIN-VET-014)
- Donaciones peer-to-peer y gestion de transparencia financiera
- Red de veterinarios colaboradores con tiers de suscripcion
- Administracion gubernamental multi-tenant con dashboards jurisdiccionales
- Sistema de reputacion y calificaciones

**Funcionalidades excluidas:**

- Procesamiento directo de pagos con tarjetas (delegado a ONVOPay / SINPE)
- Servicios veterinarios directos (solo coordinacion)
- Aplicacion de leyes (solo facilitacion de reportes)
- AltruPets **nunca** retiene, procesa ni enruta fondos a traves de sus cuentas

**Geografia objetivo:** Costa Rica (primario) + 1-2 paises LATAM (Colombia o Mexico). Objetivo de expansion a regulaciones de otros paises latinoamericanos.

**Objetivo de negocio:** MVP funcional con revenue B2G de $10K MRR (~$120K ARR) en 6 meses.

---

## 2. Roles de Usuario

### Roles Operativos

| Rol | Descripcion | Frecuencia de uso | Nivel tecnico |
|-----|-------------|-------------------|---------------|
| **Centinela** | Persona que alerta sobre animales abandonados, maltratados, desnutridos, malheridos, enfermos o accidentados que necesitan captura inmediata. Alta sensibilidad hacia el bienestar animal. | Esporadica (por avistamientos) | Basico a intermedio |
| **Auxiliar** | Persona con capacidad de capturar animales vulnerables y brindarles auxilio inmediato. Si no tiene casa cuna propia, crea solicitudes de rescate para que un rescatista acoja al animal. | Regular (segun disponibilidad) | Intermedio |
| **Rescatista** | Persona con casa cuna que rescata y cuida animales a largo plazo (comida, vacunas, castracion, cuidado maternal). Determina cuando un animal esta listo para adopcion y gestiona las solicitudes de adopcion. Puede enviar dos tipos de solicitudes: solicitudes de auxilio y solicitudes de adopcion (REQ-BR-030). | Diaria | Intermedio a avanzado |
| **Adoptante** | Persona que desea adoptar animales rescatados. Envia solicitudes de adopcion que son aprobadas o rechazadas por los rescatistas. | Esporadica (proceso de busqueda) | Basico a intermedio |
| **Donante** | Persona fisica o juridica que sufraga gastos asociados al rescate animal sin adoptar. Donaciones monetarias (SINPE/transferencia) o en especie. | Esporadica a regular | Basico a intermedio |
| **Veterinario** | Profesional con credenciales (colegiado y licencias sanitarias) para atencion medica animal. Participa en el workflow de subvencion municipal. | Regular | Intermedio a avanzado |

### Roles Administrativos

| Rol | Descripcion |
|-----|-------------|
| **Representante Legal** | Maxima autoridad de una organizacion registrada |
| **Administrador de Usuarios** | Gestiona membresias y roles dentro de una organizacion |
| **Administrador Gubernamental** | Autoridad local que supervisa actividades en su jurisdiccion. Uso diario, supervision continua. Gestiona subvenciones veterinarias, reportes de abuso y dashboards de KPIs jurisdiccionales |

### Personas SRD (Revenue-Critical)

| Persona | Rol | Impacto en Revenue |
|---------|-----|-------------------|
| P01 Gabriela | Compradora municipal | 75% del revenue ($7,500/mo at risk) |
| P02 Laura | Operadora municipal | (incluido en P01) |
| P03 Dr. Carlos | Clinica vet (pagador) | 18% del revenue ($2,000/mo at risk) |
| P04 Dr. Priscilla | Empleada vet | (incluido en P03) |
| P05 Sofia | Rescatista power user | Colapso del ecosistema |
| P06 Miguel | Lider de ONG | Colapso del ecosistema |
| P07 Andrea | Centinela | Perdida de top-of-funnel |
| P08 Diego | Auxiliar | Perdida del pipeline de rescate |
| P09 Maria Elena | Adoptante | Perdida del pipeline de adopcion |
| P10 Roberto | Donante | Perdida de financiamiento |

---

## 3. Modelo de Revenue

### Desglose de Ingresos (objetivo $10K MRR)

| Fuente | MRR | % del Total | Unidad Economica |
|--------|-----|-------------|------------------|
| **Contratos B2G Municipales** | $7,500 | 75% | 10 municipalidades x $750/mo promedio |
| **Suscripciones Clinicas Vet** | $2,000 | 20% | 25 clinicas x $80/mo promedio |
| **Features Premium** | $500 | 5% | Dashboards analytics, acceso API, soporte prioritario |

### Tiers de Contratos Municipales

| Tier | Poblacion | Precio | Incluye |
|------|-----------|--------|---------|
| Pequeno | <50K | $500/mo | Workflow de subsidio + reportes basicos |
| Mediano | 50-200K | $800/mo | Dashboard completo + reportes de abuso + analytics |
| Grande | >200K | $1,500/mo | Multi-departamento + integraciones API + soporte prioritario |

### Tiers de Clinicas Veterinarias

| Tier | Precio | Incluye |
|------|--------|---------|
| Free | $0/mo | Listado en directorio, recibir solicitudes de subsidio, perfil basico |
| Standard | $50/mo | Gestion de pacientes, herramientas de facturacion de subsidio, analytics |
| Premium | $100/mo | Posicionamiento preferente en proximidad, multi-ubicacion, reportes avanzados, procesamiento prioritario de subsidios |

**Prompt de conversion:** Cuando una clinica procesa >5 subsidios/mes, se muestra prompt de upgrade a Premium (tarea VET1).

### Decision Regulatoria Clave

AltruPets es una **plataforma de coordinacion, NO un intermediario financiero**:

- Las donaciones fluyen peer-to-peer: donante -> cuenta bancaria de la organizacion (via SINPE/transferencia)
- Los pagos de subsidio veterinario fluyen: municipalidad -> clinica vet (facilitado por AltruPets)
- AltruPets **nunca** retiene, procesa ni enruta fondos
- Esto evita supervision de SUGEF (Ley 7786, Arts. 15/15 bis) y costos de compliance asociados

---

## 4. Restricciones de la Plataforma

### Restricciones Regulatorias

- **PCI DSS nivel 1:** Cumplimiento obligatorio para integracion con ONVOPay (AltruPets no procesa pagos directamente)
- **KYC (Know Your Customer):** Controles segun regulaciones SUGEF, simplificado para donaciones de alto monto (>umbral definido por pais). Solo aplica para compliance de organizaciones receptoras
- **SUGEF:** Superintendencia General de Entidades Financieras de Costa Rica. Evitado al no intermediar fondos
- **Leyes de maltrato animal:** Adherencia a legislacion del pais de operacion (ej: Ley N° 9458 de Costa Rica)
- **Proteccion de datos personales:** Segun legislacion local
- **Retencion de auditoria:** Minimo 7 anos para registros de subvencion (REQ-FIN-VET-013)

### Restricciones Tecnicas

- **Arquitectura:** Microservicios obligatorios en Kubernetes/OpenShift
- **Principios 12-Factor App:** Implementacion obligatoria
- **Comunicacion:** TLS 1.3 encriptado entre todos los componentes
- **Pagos:** Uso exclusivo de ONVOPay para transacciones con tarjeta
- **Base de datos:** Database per Service (independiente por microservicio)
- **Comunicacion entre servicios:** gRPC (sincrono) + message broker Kafka/RabbitMQ (asincrono)
- **Geolocalización:** PostGIS para consultas de proximidad y mapeo de jurisdicciones

### Restricciones de Infraestructura

- Contenedores Docker/Podman
- Orquestacion Kubernetes o Red Hat OpenShift
- Observabilidad con OpenTelemetry (OTLP): Prometheus (metricas), Loki (logs), Grafana Tempo (trazas)
- Frontend: Flutter multiplataforma (iOS/Android) con capacidades offline-first
- Backend: 9 microservicios especializados

### Integraciones Externas

| Servicio | Proposito |
|----------|-----------|
| ONVOPay | Procesamiento de pagos con tarjeta |
| SINPE | Transferencias bancarias (Costa Rica) |
| Google Maps / MapBox | Geolocalizacion y mapas |
| Firebase (FCM) | Notificaciones push |
| Firebase Firestore | Chat en tiempo real (base existente) |
| Servicios gubernamentales | Reportes oficiales |

---

## 5. Roadmap de Sprints

**Duracion total:** 6 meses | **Version:** 0.3.0 -> 1.0.0

> **Cambio de enfoque SRD:** El orden original priorizaba coordinacion de rescate (value-delivery). El SRD identifica que el subsidio veterinario municipal y los reportes de abuso son los revenue drivers #1 y #2. Se reorganizan los sprints para construir revenue primero.

| Sprint | Version | Foco | Duracion | Prioridad | SRD Phase | Revenue Impact |
|--------|---------|------|----------|-----------|-----------|----------------|
| **1** | v0.3.0 | Foundation: Animal + Auth + Vet + PostGIS | 2 sem | CRITICA | Phase 1 | Desbloquea todo ($9,372/mo at risk) |
| **2** | v0.4.0 | Revenue B2G: Subsidios + Abuso + Dashboard | 3 sem | CRITICA | Phase 2-4 | $6,825/mo |
| **3** | v0.5.0 | Value: Rescate + Adopcion + Push Notifications | 3 sem | ALTA | Phase 5 | $1,135/mo |
| **4** | v0.6.0 | Ecosistema Vet completo + Donaciones P2P + Chat | 2.5 sem | ALTA | Phase 6 | $672/mo |
| **5** | v0.7.0 | Retencion: Contratos + Impact + Reputacion | 2 sem | MEDIA | Phase 7 | Churn reduction |
| **6** | v0.8.0 | Hardening: Security + Offline + Performance | 2 sem | MEDIA | -- | Reliability |
| **7** | v0.9.0 | Infraestructura Cloud: Testing + CI/CD + Monitoring | 2 sem | MEDIA | -- | Deployability |
| **8** | v1.0.0 | Release Produccion: Security + Launch | 2 sem | CRITICA | -- | Go-live |

### Detalle por Sprint

**Sprint 1 (v0.3.0) - Foundation + Quick Wins:**
Entidad Animal con PostGIS, hardening de auth (JWT refresh, guards), perfil veterinario + registro de clinica, funciones de geolocalizacion (jurisdiccion por GPS). Tracks paralelos: A (Animal + Casa Cuna), B (Auth), C (Vet Profile), D (PostGIS).

**Sprint 2 (v0.4.0) - Revenue B2G:**
Workflow completo de subsidio veterinario municipal (REQ-FIN-VET-001 a REQ-FIN-VET-014): solicitud -> revision -> aprobacion/rechazo -> facturacion. Reportes de abuso autenticados con GPS + fotos. Dashboard gubernamental web (Inertia.js) con KPIs jurisdiccionales y segregacion multi-tenant.

**Sprint 3 (v0.5.0) - Value Delivery:**
Pipeline de coordinacion de rescate (centinela -> auxiliar -> rescatista). Flujo de adopcion completo con galeria y screening. Push notifications diferenciadas por rol via Firebase. Auth complementario (password reset, verificacion email).

**Sprint 4 (v0.6.0) - Ecosistema Vet + Donaciones:**
Gestion de pacientes veterinarios. Historial medico de animales. Donaciones P2P (monetarias via SINPE + en especie). Integracion de chat con workflows. Reportes de transparencia financiera.

**Sprint 5 (v0.7.0) - Retencion:**
Contratos digitales de adopcion con e-signature. Seguimiento post-adopcion automatizado (30/60/90 dias). Dashboard de impacto para donantes. Prompts de upgrade para clinicas vet. Sistema de reputacion y calificaciones.

**Sprint 6 (v0.8.0) - Hardening:**
Deteccion de actividad sospechosa. KYC simplificado para donaciones de alto monto. Funcionalidades offline-first. Optimizaciones de performance (lazy loading, compresion de imagenes, cache).

**Sprint 7 (v0.9.0) - Infraestructura Cloud:**
Analytics y metricas. Suite de testing completa (unit, widget, integration, golden). CI/CD y despliegue automatizado (QA, STAGING, PROD). Monitoreo y observabilidad.

**Sprint 8 (v1.0.0) - Release Produccion:**
Testing de seguridad y penetracion. Certificate pinning, ofuscacion, deteccion root/jailbreak. Rate limiting y proteccion DDoS.

---

## 6. Preocupaciones Transversales (Cross-cutting Concerns)

### 6.1. Sistema de Reputacion

El sistema de reputacion es un **microservicio independiente** (Reputation Service, PostgreSQL) que afecta multiples flujos del sistema.

**Calificaciones (Sprint 5, tareas 27 y 28):**
- Post-rescate, post-adopcion, post-atencion veterinaria
- Validacion de calificaciones autenticas con deteccion de patrones sospechosos (ML)
- Expiracion automatica de calificaciones a los 3 meses
- Puntuacion visible en perfil con historial

**Impacto en matching de proximidad:**

Para **auxiliares**, la reputacion pesa un 30% en el algoritmo de scoring:
```
Score = (distancia * 0.4) + (reputacion * 0.3) + (disponibilidad * 0.2) + (experiencia * 0.1)
```

Para **rescatistas**, la reputacion pesa un 25%:
```
Score = (distancia * 0.3) + (capacidadCasaCuna * 0.25) + (reputacion * 0.25) + (especializacion * 0.2)
```

**Requisitos de reputacion minima:**
- Rescatista "padrino" requiere minimo 4.0/5.0 estrellas y 2 anos de experiencia activa

### 6.2. Patrones de Notificacion

Notificaciones implementadas via Firebase Cloud Messaging (FCM) con centro de notificaciones interno como fallback.

**Notificaciones por tipo (REQ-NOT-001 a REQ-NOT-008):**

| ID | Trigger | Destinatario | Comportamiento |
|----|---------|-------------|----------------|
| REQ-NOT-001 | Solicitud de auxilio creada | Auxiliares en radio 10km | Automatica |
| REQ-NOT-002 | Sin respuesta en 30 min | Auxiliares en radio 25km | Expansion automatica |
| REQ-NOT-003 | Solicitud de rescate creada | Rescatistas disponibles en zona | Automatica |
| REQ-NOT-004 | Autorizacion vet requerida | Encargado jurisdiccional | Automatica |
| REQ-NOT-005 | Animal disponible para adopcion | Adoptantes con preferencias coincidentes | Automatica |
| REQ-NOT-006 | Subvencion creada/resuelta | Municipal (creacion), vet + rescatista (resolucion) | REQ-FIN-VET-006 |
| REQ-NOT-007 | Intervencion policial creada | Estacion de policia jurisdiccional | Automatica |
| REQ-NOT-008 | Sin respuesta policial | Escalamiento automatico | Automatica |

**Notificaciones diferenciadas por rol (Sprint 3, tarea 26):**
- **Rescatista:** Nuevo subsidio aprobado/rechazado, nueva solicitud de adopcion
- **Auxiliar:** Nueva alerta de auxilio cercana
- **Centinela:** Actualizacion de estado de su reporte
- **Municipalidad:** Nuevo subsidio/reporte pendiente
- **Veterinario:** Nueva solicitud de subsidio asignada

### 6.3. Multi-tenancy

La plataforma implementa multi-tenancy para datos gubernamentales con segregacion por jurisdiccion:

- Cada municipalidad opera como tenant independiente con sus propios datos
- Segregacion multi-tenant: cada municipalidad solo ve datos de su jurisdiccion
- Asignacion automatica de subsidios y reportes de abuso a la municipalidad correcta via PostGIS (`getJurisdictionByLocation`)
- Tiers de suscripcion por tenant: BASIC, PREMIUM, ENTERPRISE
- SLA de respuesta configurable por municipalidad (REQ-FIN-VET-014)
- El Government Service gestiona: subvenciones veterinarias municipales, mediacion de conflictos, reportes de transparencia

### 6.4. Auditoria y Transparencia

- Event Sourcing para almacenamiento de eventos de auditoria
- Retencion minima de 7 anos para registros de subvencion (REQ-FIN-VET-013)
- Transparency score por organizacion (visible para donantes)
- Reportes financieros configurables por periodo con exportacion PDF/Excel
- Metricas de impacto: animales rescatados, adoptados, subsidiados, donaciones recibidas

### 6.5. Seguridad y Autenticacion

- JWT con renovacion automatica de tokens
- RBAC (Role-Based Access Control)
- Deteccion de actividad sospechosa (multiples logins desde ubicaciones diferentes)
- Revocacion de sesiones activas
- Certificate pinning, ofuscacion de codigo, deteccion root/jailbreak (produccion)

---

## 7. Glosario

### Roles de Usuario

| Termino | Definicion |
|---------|-----------|
| **Centinela** | Persona que alerta sobre animales vulnerables que necesitan captura inmediata |
| **Auxiliar** | Persona que captura animales vulnerables y brinda auxilio inmediato; puede o no tener casa cuna |
| **Rescatista** | Persona con casa cuna que cuida animales a largo plazo y gestiona adopciones |
| **Adoptante** | Persona que solicita adoptar animales rescatados |
| **Donante** | Persona fisica o juridica que sufraga gastos de rescate sin adoptar |
| **Casa cuna** | Hogar temporal de acogida para animales rescatados |

### Terminos de Negocio

| Termino | Definicion |
|---------|-----------|
| **Subvencion Municipal** | Subsidio gubernamental para cubrir costos veterinarios de animales callejeros (REQ-FIN-VET-001..014) |
| **B2G** | Business-to-Government; modelo de venta de contratos a municipalidades |
| **MRR** | Monthly Recurring Revenue; ingreso mensual recurrente |
| **SRD** | Synthetic Reality Development; framework de priorizacion usado en el proyecto |
| **Solicitud de auxilio** | Alerta creada por centinela o rescatista sobre animal vulnerable |
| **Solicitud de rescate** | Pedido de auxiliar sin casa cuna para que un rescatista acoja al animal |

### Acronimos Tecnicos

| Acronimo | Significado |
|----------|-----------|
| **PCI DSS** | Payment Card Industry Data Security Standard |
| **SUGEF** | Superintendencia General de Entidades Financieras (Costa Rica) |
| **KYC** | Know Your Customer - Verificacion de identidad para cumplimiento regulatorio |
| **RBAC** | Role-Based Access Control |
| **CQRS** | Command Query Responsibility Segregation |
| **JWT** | JSON Web Token |
| **gRPC** | Protocolo de comunicacion entre microservicios |
| **PostGIS** | Extension geoespacial de PostgreSQL |
| **OTel / OTLP** | OpenTelemetry / OpenTelemetry Protocol |
| **FCM** | Firebase Cloud Messaging |
| **SINPE** | Sistema Nacional de Pagos Electronicos (Costa Rica) |
| **ONVOPay** | Pasarela de pagos integrada |
| **IaC** | Infrastructure as Code |
| **CI/CD** | Continuous Integration / Continuous Deployment |

---

*Fuentes: specs/altrupets/requirements.md (secciones 1-2, 3.6.3, 3.6.12), specs/altrupets/design.md (Resumen + Sprint priorities), specs/altrupets/tasks.md (Plan de 8 sprints), srd/success-reality.md, srd/gap-audit.md*
