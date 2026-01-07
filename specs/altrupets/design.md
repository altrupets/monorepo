# Documento de Diseño - AltruPets

## Resumen

AltruPets es una plataforma integral de protección animal basada en arquitectura de microservicios cloud-native que conecta centinelas, auxiliares, rescatistas, adoptantes, donantes y veterinarios. El sistema utiliza una **arquitectura de microservicios cloud-native** desplegada en Kubernetes/OpenShift, siguiendo los principios de 12-factor app y patrones de diseño para microservicios, priorizando la seguridad, cumplimiento regulatorio PCI DSS, y las reglas de negocio fundamentales definidas en los requisitos.

## Priorización de Desarrollo por Sprints

### Sprint 01: Funcionalidades Core de Rescate
- Coordinación básica entre centinelas, auxiliares y rescatistas
- Sistema de denuncias anónimas
- Gestión básica de casas cuna
- Autenticación y RBAC básico
- Geolocalización y matching por proximidad

### Sprint 02: Sistema de Subvención Municipal Veterinaria (PRIORIDAD ALTA)

**Decisión de Diseño**: El **Sistema de Subvención Municipal para Atención Veterinaria** (REQ-FIN-VET-001 a REQ-FIN-VET-014) se implementa como prioridad alta en el Sprint 02 debido a su impacto crítico en:

1. **Sostenibilidad Financiera**: Permite que las municipalidades subsidien los costos veterinarios, reduciendo la carga financiera sobre rescatistas individuales
2. **Cumplimiento Regulatorio**: Establece el marco legal para que gobiernos locales participen activamente en el bienestar animal
3. **Escalabilidad del Sistema**: Sin subvención municipal, el sistema no es viable a largo plazo para rescatistas con recursos limitados
4. **Diferenciación Competitiva**: Ninguna plataforma similar ofrece integración gubernamental para subvenciones veterinarias

**Componentes Críticos del Sprint 02**:
- Workflow completo de solicitud → revisión → aprobación/rechazo → facturación
- Segregación multi-tenant para datos gubernamentales
- Integración con Financial Service para facturación dual (municipal vs rescatista)
- Dashboard gubernamental para gestión de subvenciones
- Notificaciones automáticas y expiración de solicitudes
- Auditoría completa para transparencia gubernamental

### Sprint 03: Red Veterinaria y Adopciones
- Sistema completo de veterinarios colaboradores
- Proceso de adopción con contratos digitales
- Historial médico de animales
- Sistema de reputación y calificaciones

### Sprint 04: Sistema Financiero Completo
- Donaciones y suscripciones recurrentes
- Cumplimiento KYC y PCI DSS
- Reportes financieros y transparencia
- Integración completa con ONVOPay

## Arquitectura de Microservicios Cloud-Native

### Arquitectura General del Sistema

El sistema implementa una arquitectura de microservicios autocontenidos con separación clara de responsabilidades:

```
┌─────────────────────────────────────┐
│        Frontend (Flutter App)       │
├─────────────────────────────────────┤
│ • Client-side UI composition        │
│ • Stateless processes              │
│ • Externalized configuration       │
│ • Offline-first design             │
│ • API Gateway communication        │
└─────────────────────────────────────┘
                    │
              API Gateway (Kong/Istio)
                    │
┌─────────────────────────────────────┐
│     Microservicios Cloud-Native     │
├─────────────────────────────────────┤
│ ┌─────────────┐ ┌─────────────────┐ │
│ │User Mgmt    │ │Animal Rescue    │ │
│ │Service      │ │Service          │ │
│ └─────────────┘ └─────────────────┘ │
│ ┌─────────────┐ ┌─────────────────┐ │
│ │Financial    │ │Veterinary       │ │
│ │Service      │ │Service          │ │
│ └─────────────┘ └─────────────────┘ │
│ ┌─────────────┐ ┌─────────────────┐ │
│ │Notification │ │Geolocation      │ │
│ │Service      │ │Service          │ │
│ └─────────────┘ └─────────────────┘ │
│ ┌─────────────┐ ┌─────────────────┐ │
│ │Reputation   │ │Government       │ │
│ │Service      │ │Service          │ │
│ └─────────────┘ └─────────────────┘ │
│ ┌─────────────┐                     │
│ │Analytics    │                     │
│ │Service      │                     │
│ └─────────────┘                     │
└─────────────────────────────────────┘
```

### Principios Arquitectónicos Implementados

**Microservicios Autocontenidos**: Cada servicio es una unidad independiente con su propia base de datos, siguiendo el patrón "Database per Service" para garantizar desacoplamiento flexible.

**API-First**: Comunicación a través de APIs REST bien definidas y gRPC para comunicación interna, garantizando interoperabilidad.

**Cloud-Native**: Optimizado para contenedorización con Docker/Podman y orquestación con Kubernetes, aprovechando autoescalado y gestión elástica.

**Headless**: Desacoplamiento completo entre frontend móvil y microservicios backend.

**Principios 12-Factor App**:
- **Codebase**: Un repositorio por microservicio
- **Dependencies**: Dependencias declaradas en contenedores
- **Config**: ConfigMaps y Secrets de Kubernetes
- **Backing Services**: Bases de datos como recursos adjuntos
- **Stateless Processes**: Sin estado en memoria, datos externalizados
- **Port Binding**: Cada servicio expone su propio puerto
- **Disposability**: Inicio/parada rápida de contenedores

## Microservicios y Patrones de Diseño

### 1. User Management Service (Microservicio de Gestión de Usuarios)

#### Responsabilidades del Dominio
- Autenticación y autorización (RBAC)
- Gestión de usuarios individuales y organizacionales
- Control de acceso basado en roles
- Gestión de membresías organizacionales

#### Patrones Implementados
- **Single Responsibility Principle**: Responsable únicamente del dominio de usuarios
- **Database per Service**: PostgreSQL dedicada con encriptación
- **Access Token Pattern**: JWT con OAuth 2.0/OpenID Connect
- **Health Check API**: Endpoint /health para monitoreo
- **Externalized Configuration**: Credenciales en Kubernetes Secrets

#### Componentes Frontend
- **RegistrationFlow**: Maneja flujo de registro con validación básica
- **AuthenticationService**: Gestiona tokens JWT y estado de autenticación
- **RoleBasedUI**: Adapta interfaz según roles (Client-side UI composition)

#### API Endpoints
```
POST /api/v1/users/register
POST /api/v1/users/login  
GET  /api/v1/users/profile
PUT  /api/v1/users/roles
GET  /api/v1/organizations
POST /api/v1/organizations/membership
GET  /health
```

#### Jerarquía de Roles (RBAC) y Principio de Responsabilidad Única

```
Administrador Gubernamental (Máximo nivel jurisdiccional)
├── Encargado de Bienestar Animal (autoriza atención veterinaria)
├── Mediador de Conflictos
└── [Organizaciones en su jurisdicción]

Representante Legal (Máximo nivel organizacional)
├── Administrador de Usuarios
├── Centinela Organizacional
├── Auxiliar Organizacional
├── Rescatista Organizacional
├── Adoptante Organizacional
├── Donante Organizacional
└── Veterinario Organizacional

Usuarios Individuales (con responsabilidades específicas)
├── Centinela Individual (SOLO solicitudes de auxilio)
├── Auxiliar Individual (SOLO solicitudes de auxilio inmediato)
├── Rescatista Individual (SOLO solicitudes de adopción)
├── Adoptante Individual
├── Donante Individual
└── Veterinario Individual
```

**Decisión de Diseño**: La jerarquía RBAC implementa el **Principio de Responsabilidad Única** donde cada rol tiene tipos específicos de solicitudes que puede crear, siguiendo las reglas BR-010 a BR-032. Cada servicio valida permisos independientemente usando tokens JWT con claims de roles.

### 2. Animal Rescue Service (Microservicio de Rescate Animal)

#### Responsabilidades del Dominio
- Gestión de solicitudes de auxilio (centinelas) y rescate (auxiliares)
- Coordinación de rescates entre centinelas, auxiliares y rescatistas
- Gestión de casas cuna e inventario de animales con reglas de adoptabilidad
- Implementación de estados de workflow y transiciones automáticas
- Matching de proximidad con Geolocation Service según reglas GEO-001 a GEO-022

#### Patrones Implementados
- **State Machine Pattern**: Gestión de estados de workflow (WF-001 a WF-042)
- **Saga Pattern**: Coordinación de rescates entre múltiples servicios
- **Event Sourcing**: Trazabilidad completa de rescates para auditoría
- **Business Rules Engine**: Validación automática de reglas BR-050, BR-051, BR-080-082
- **Circuit Breaker**: Tolerancia a fallos en comunicación con otros servicios
- **API Composition**: Consultas distribuidas para datos de rescate
- **Loose Coupling**: Comunicación asíncrona vía eventos

#### Componentes Frontend
- **AnonymousReportForm**: Formulario sin autenticación (stateless)
- **RescueRequestForm**: Creación de solicitudes con geolocalización
- **StatusTracker**: Seguimiento en tiempo real vía WebSockets
- **CasaCunaManager**: Gestión de inventario offline-first

#### API Endpoints
```
POST /api/v1/reports/anonymous
POST /api/v1/rescues/request
GET  /api/v1/rescues/{id}/status
PUT  /api/v1/rescues/{id}/update
GET  /api/v1/casa-cuna/inventory
POST /api/v1/casa-cuna/animals
GET  /health
```

### 3. Financial Service (Microservicio Financiero)

#### Responsabilidades del Dominio
- Procesamiento de donaciones y pagos (PCI DSS compliant)
- Gestión financiera y contable de rescatistas
- **Sistema de Subvención Municipal para Atención Veterinaria** (REQ-FIN-VET-001 a REQ-FIN-VET-014)
- Integración con ONVOPay mediante patrón Adapter
- Cumplimiento regulatorio y KYC
- Gestión de obligaciones de pago municipales vs rescatistas

#### Patrones Implementados
- **Adapter Pattern**: Integración flexible con múltiples pasarelas de pago
- **Event Sourcing**: Auditoría completa de transacciones financieras
- **CQRS**: Separación de comandos (pagos) y consultas (reportes)
- **Saga Pattern**: Transacciones distribuidas para donaciones
- **Circuit Breaker**: Tolerancia a fallos en pagos externos

#### Componentes Frontend
- **DonationInterface**: Múltiples métodos de pago con WebView seguro
- **KYCForms**: Formularios de debida diligencia
- **FinancialReports**: Configuración y descarga de reportes
- **SubscriptionManager**: Gestión de donaciones recurrentes

#### API Endpoints
```
POST /api/v1/donations/process
POST /api/v1/donations/recurring
GET  /api/v1/financial/reports
POST /api/v1/kyc/validate
GET  /api/v1/transactions/history
POST /api/v1/webhooks/onvopay

# Sistema de Subvención Municipal Veterinaria
POST /api/v1/veterinary-subsidy/request
GET  /api/v1/veterinary-subsidy/{id}/status
PUT  /api/v1/veterinary-subsidy/{id}/approve
PUT  /api/v1/veterinary-subsidy/{id}/reject
GET  /api/v1/veterinary-subsidy/municipal/{tenantId}
POST /api/v1/veterinary-subsidy/{id}/invoice
GET  /api/v1/veterinary-subsidy/reports/{tenantId}

GET  /health
```

## Sistema de Subvención Municipal para Atención Veterinaria (Sprint 02)

### Diseño del Flujo de Subvención

**Decisión de Diseño Crítica para Sprint 02**: El sistema de subvención municipal NO condiciona la realización de procedimientos médicos. Los rescatistas pueden actuar libremente para rescatar animales. La subvención afecta únicamente la facturación y el sujeto obligado de pago (REQ-FIN-VET-008).

**Justificación de Prioridad Alta**: Esta funcionalidad es fundamental para la viabilidad económica del sistema, ya que permite que las municipalidades asuman los costos veterinarios de animales callejeros, heridos o enfermos, reduciendo significativamente la barrera financiera para los rescatistas.

#### Arquitectura del Sistema de Subvención

```typescript
// Modelo de datos para Solicitud de Subvención Municipal
interface SolicitudSubvencionMunicipal {
  id: string;
  veterinarioId: string;
  rescatistaId: string;
  animalId: string;
  tenantMunicipalId: string; // Segregación multi-tenant
  
  // Detalles del procedimiento
  montoTentativo: number;
  desgloceServicios: ServicioVeterinario[];
  fechaProcedimiento: Date;
  ubicacionAnimal: Coordenadas;
  
  // Estados del workflow
  estado: 'CREADA' | 'EN_REVISION' | 'APROBADA' | 'RECHAZADA' | 'EXPIRADA';
  
  // Configuración municipal
  tiempoMaximoRespuesta: number; // En horas, configurable por municipalidad
  fechaCreacion: Date;
  fechaExpiracion: Date;
  
  // Auditoría
  aprobadoPor?: string;
  motivoRechazo?: string;
  facturaEmitida?: FacturaVeterinaria;
}

// Motor de reglas para subvención
class SubvencionMunicipalEngine {
  
  // REQ-FIN-VET-002: Asignación automática por jurisdicción
  async asignarJurisdiccion(ubicacionAnimal: Coordenadas): Promise<string> {
    const jurisdiccion = await this.geolocationService.getJurisdictionByLocation(ubicacionAnimal);
    
    // Validar casos especiales (JUR-020, JUR-021)
    if (await this.isSpecialCase(ubicacionAnimal)) {
      return await this.handleSpecialJurisdictionCase(ubicacionAnimal);
    }
    
    return jurisdiccion.tenantId;
  }
  
  // REQ-FIN-VET-003: Gestión de estados
  async procesarTransicionEstado(
    solicitudId: string, 
    nuevoEstado: EstadoSubvencion,
    usuarioId: string
  ): Promise<void> {
    const solicitud = await this.getSolicitud(solicitudId);
    
    switch (nuevoEstado) {
      case 'APROBADA':
        // REQ-FIN-VET-004: Factura a municipalidad
        await this.emitirFacturaMunicipal(solicitud);
        await this.registrarObligacionPagoMunicipal(solicitud);
        break;
        
      case 'RECHAZADA':
      case 'EXPIRADA':
        // REQ-FIN-VET-005: Factura a rescatista
        await this.emitirFacturaRescatista(solicitud);
        await this.registrarObligacionPagoRescatista(solicitud);
        break;
    }
    
    // REQ-FIN-VET-006: Notificaciones automáticas
    await this.enviarNotificacionesEstado(solicitud, nuevoEstado);
    
    // REQ-FIN-VET-013: Auditoría completa
    await this.registrarAuditoria(solicitud, nuevoEstado, usuarioId);
  }
  
  // REQ-FIN-VET-014: Expiración automática
  async verificarExpiraciones(): Promise<void> {
    const solicitudesPendientes = await this.getSolicitudesEnRevision();
    
    for (const solicitud of solicitudesPendientes) {
      if (this.haExpirado(solicitud)) {
        await this.procesarTransicionEstado(solicitud.id, 'EXPIRADA', 'SYSTEM');
      }
    }
  }
  
  private haExpirado(solicitud: SolicitudSubvencionMunicipal): boolean {
    const ahora = new Date();
    return ahora > solicitud.fechaExpiracion;
  }
}
```

#### Integración Multi-Tenant con Government Service

```typescript
// Segregación de datos gubernamentales para subvenciones
class SubvencionMultiTenantService {
  
  // REQ-MT-002: Solo datos gubernamentales segregados
  async getSolicitudesPorTenant(tenantId: string): Promise<SolicitudSubvencionMunicipal[]> {
    // Row Level Security aplicada automáticamente
    return await this.db.query(`
      SELECT * FROM solicitudes_subvencion_municipal 
      WHERE tenant_municipal_id = $1
    `, [tenantId]);
  }
  
  // REQ-MT-004: Reportes filtrados por jurisdicción
  async generarReporteTransparencia(
    tenantId: string, 
    periodo: PeriodoReporte
  ): Promise<ReporteTransparencia> {
    
    // Datos centralizados filtrados por jurisdicción geográfica
    const rescatesEnJurisdiccion = await this.animalRescueService
      .getRescatesPorJurisdiccion(tenantId, periodo);
    
    // Datos segregados del tenant
    const subvencionesAprobadas = await this.getSolicitudesPorTenant(tenantId)
      .filter(s => s.estado === 'APROBADA' && this.enPeriodo(s, periodo));
    
    return {
      rescatesTotales: rescatesEnJurisdiccion.length,
      subvencionesAprobadas: subvencionesAprobadas.length,
      montoTotalSubvencionado: subvencionesAprobadas.reduce((sum, s) => sum + s.montoTentativo, 0),
      transparenciaFinanciera: this.calcularMetricasTransparencia(subvencionesAprobadas)
    };
  }
}
```

#### Estados de Workflow para Subvención

```typescript
// REQ-WF-050 a REQ-WF-054: Estados específicos de subvención
class SubvencionWorkflowStateMachine {
  
  private transiciones = {
    'CREADA': ['EN_REVISION'],
    'EN_REVISION': ['APROBADA', 'RECHAZADA', 'EXPIRADA'],
    'APROBADA': [], // Estado final
    'RECHAZADA': [], // Estado final
    'EXPIRADA': []   // Estado final
  };
  
  // REQ-WF-052: Aprobación municipal
  async aprobarSubvencion(solicitudId: string, encargadoId: string): Promise<void> {
    const solicitud = await this.getSolicitud(solicitudId);
    
    // Validar autorización jurisdiccional
    await this.validarAutoridadMunicipal(encargadoId, solicitud.tenantMunicipalId);
    
    // Cambiar estado y emitir factura municipal
    await this.transicionarEstado(solicitudId, 'APROBADA');
    await this.financialService.emitirFacturaMunicipal(solicitud);
  }
  
  // REQ-WF-054: Expiración automática
  async procesarExpiracionAutomatica(): Promise<void> {
    const solicitudesVencidas = await this.getSolicitudesVencidas();
    
    for (const solicitud of solicitudesVencidas) {
      await this.transicionarEstado(solicitud.id, 'EXPIRADA');
      await this.financialService.emitirFacturaRescatista(solicitud);
    }
  }
}
```

### Decisiones de Diseño Específicas para Sprint 02

#### 1. Arquitectura de Integración entre Servicios

**Decisión**: El sistema de subvención se implementa como una funcionalidad distribuida entre Financial Service y Government Service, con eventos asíncronos para coordinación.

**Rationale**: 
- Financial Service maneja la lógica de facturación y obligaciones de pago
- Government Service maneja la aprobación/rechazo y políticas municipales
- La comunicación asíncrona permite que cada servicio mantenga su responsabilidad única

#### 2. Estrategia de Datos Multi-Tenant

**Decisión**: Segregación híbrida donde solo los datos gubernamentales específicos (subvenciones, reportes) se segregan por tenant, mientras que los datos core de AltruPets permanecen centralizados.

**Rationale**:
- Permite que múltiples municipalidades usen el sistema sin ver datos de otras jurisdicciones
- Mantiene la eficiencia de búsquedas y matching a nivel regional
- Simplifica la arquitectura comparado con multi-tenancy completo

#### 3. Modelo de Facturación Dual

**Decisión**: El sistema emite automáticamente facturas a diferentes sujetos obligados según el resultado de la subvención:
- **Subvención APROBADA** → Factura a municipalidad
- **Subvención RECHAZADA/EXPIRADA** → Factura a rescatista

**Rationale**:
- Automatiza completamente el proceso de facturación
- Elimina ambigüedad sobre quién debe pagar
- Facilita la transparencia financiera y auditoría

#### 4. Configuración Municipal Flexible

**Decisión**: Cada municipalidad puede configurar su "tiempo máximo de respuesta" para subvenciones, con expiración automática.

**Rationale**:
- Permite que cada gobierno local adapte el sistema a sus procesos internos
- Evita que solicitudes queden indefinidamente pendientes
- Garantiza que los rescatistas tengan certeza sobre el financiamiento

### 4. Notification Service (Microservicio de Notificaciones)

#### Responsabilidades del Dominio
- Gestión de notificaciones push
- Sistema de chat interno en tiempo real
- Procesamiento de eventos de otros microservicios
- WebSockets para comunicación instantánea

#### Patrones Implementados
- **Event-Driven Architecture**: Procesamiento de eventos de otros servicios
- **Message Queue**: Cola de mensajes para entrega garantizada
- **WebSocket Pattern**: Comunicación bidireccional en tiempo real
- **Publish-Subscribe**: Distribución de notificaciones por tipo de usuario

#### Componentes Frontend
- **ChatInterface**: Mensajería en tiempo real con WebSockets
- **NotificationCenter**: Centro unificado de notificaciones
- **MediaSharing**: Compartir fotos y ubicación en chat
- **OfflineSync**: Sincronización de mensajes offline

#### API Endpoints
```
POST /api/v1/notifications/send
GET  /api/v1/chat/conversations
POST /api/v1/chat/messages
WS   /api/v1/chat/websocket
GET  /api/v1/notifications/preferences
PUT  /api/v1/notifications/preferences
GET  /health
```

### 5. Geolocation Service (Microservicio de Geolocalización)

#### Responsabilidades del Dominio
- Cálculos geoespaciales y búsquedas por proximidad
- Optimización de rutas para rescates
- Matching de rescatistas por distancia y disponibilidad
- Gestión de jurisdicciones gubernamentales

#### Patrones Implementados
- **Single Responsibility Principle**: Especializado en operaciones geoespaciales
- **Database per Service**: PostGIS (PostgreSQL con extensiones geoespaciales)
- **API Composition**: Consultas distribuidas con otros servicios
- **Caching Pattern**: Redis para consultas frecuentes de proximidad

#### Componentes Frontend
- **LocationCapture**: Captura automática de GPS
- **ProximityMatcher**: Visualización de rescatistas cercanos
- **MapIntegration**: Integración con Google Maps/OpenStreetMap
- **RouteOptimizer**: Navegación optimizada para rescates

#### API Endpoints
```
POST /api/v1/location/proximity
GET  /api/v1/location/rescuers/nearby
POST /api/v1/location/route/optimize
GET  /api/v1/location/jurisdictions
PUT  /api/v1/location/update
GET  /health
```

### 6. Veterinary Service (Microservicio Veterinario)

#### Responsabilidades del Dominio
- Red de veterinarios colaboradores
- Gestión de solicitudes de atención médica
- Historial médico de animales
- Sistema de derivaciones especializadas

#### Patrones Implementados
- **Domain-Driven Design**: Modelado específico del dominio veterinario
- **Event Sourcing**: Historial médico inmutable para auditoría
- **Saga Pattern**: Coordinación de atención médica entre servicios
- **Specialty Matching**: Algoritmo de matching por especialidades

#### API Endpoints
```
POST /api/v1/veterinary/register
GET  /api/v1/veterinary/available
POST /api/v1/veterinary/request
PUT  /api/v1/veterinary/treatment
GET  /api/v1/veterinary/medical-records
POST /api/v1/veterinary/referral
GET  /health
```

### 7. Reputation Service (Microservicio de Reputación)

#### Responsabilidades del Dominio
- Sistema de calificaciones y reputación
- Detección de patrones sospechosos con ML
- Gestión de expiración de calificaciones (3 meses)
- Validación de calificaciones auténticas

#### Patrones Implementados
- **Event Sourcing**: Historial inmutable de calificaciones
- **CQRS**: Separación de escritura de calificaciones y consultas de reputación
- **Temporal Pattern**: Expiración automática de calificaciones
- **ML Pattern**: Detección de anomalías en calificaciones

#### API Endpoints
```
POST /api/v1/reputation/rate
GET  /api/v1/reputation/score/{userId}
GET  /api/v1/reputation/history
POST /api/v1/reputation/report-abuse
GET  /api/v1/reputation/analytics
GET  /health
```

### 8. Government Service (Microservicio Gubernamental)

#### Responsabilidades del Dominio
- Administración gubernamental multi-tenant
- **Gestión de Subvenciones Veterinarias Municipales** (REQ-FIN-VET-001 a REQ-FIN-VET-014)
- Mediación de conflictos
- Reportes de transparencia
- Supervisión jurisdiccional
- Configuración de políticas municipales (tiempos de respuesta, etc.)

#### Patrones Implementados
- **Multi-Tenant Pattern**: Segregación por jurisdicción gubernamental
- **Event-Driven Architecture**: Procesamiento de eventos de otros servicios
- **Audit Trail Pattern**: Trazabilidad completa para transparencia
- **Reporting Pattern**: Generación de reportes gubernamentales

#### API Endpoints
```
GET  /api/v1/government/dashboard
POST /api/v1/government/mediation
GET  /api/v1/government/reports
GET  /api/v1/government/complaints
PUT  /api/v1/government/jurisdiction

# Gestión de Subvenciones Veterinarias
GET  /api/v1/government/veterinary-subsidies/pending
PUT  /api/v1/government/veterinary-subsidies/{id}/approve
PUT  /api/v1/government/veterinary-subsidies/{id}/reject
POST /api/v1/government/veterinary-subsidies/{id}/request-info
GET  /api/v1/government/veterinary-subsidies/reports
PUT  /api/v1/government/config/subsidy-response-time

GET  /health
```

### 9. Analytics Service (Microservicio de Analytics)

#### Responsabilidades del Dominio
- Algoritmos de machine learning para detección de anomalías
- Generación de reportes y análisis
- Métricas de impacto y KPIs
- Big data processing

#### Patrones Implementados
- **CQRS**: Optimizado para consultas analíticas complejas
- **Event Sourcing**: Procesamiento de eventos históricos
- **ML Pipeline Pattern**: Pipelines de machine learning
- **Data Lake Pattern**: Almacenamiento de big data

#### API Endpoints
```
GET  /api/v1/analytics/reports
POST /api/v1/analytics/ml/detect-anomalies
GET  /api/v1/analytics/metrics
GET  /api/v1/analytics/insights
POST /api/v1/analytics/custom-query
GET  /health
```

## Comunicación entre Microservicios

### Patrones de Comunicación Implementados

#### Comunicación Síncrona
- **gRPC**: Para comunicación interna entre microservicios
- **REST APIs**: Para comunicación externa desde frontend
- **API Gateway**: Kong/Istio como punto único de entrada

#### Comunicación Asíncrona
- **Message Broker**: Apache Kafka/RabbitMQ para eventos
- **Event-Driven Architecture**: Publicación/suscripción de eventos
- **WebSockets**: Para comunicación en tiempo real (chat)

#### Service Discovery
- **Kubernetes DNS**: Descubrimiento automático de servicios
- **Service Mesh**: Istio para comunicación segura y observabilidad
- **Load Balancing**: Distribución automática de carga

### Eventos del Sistema

```yaml
# Eventos publicados por cada microservicio
UserManagementService:
  - user.registered
  - user.role.assigned
  - organization.created

AnimalRescueService:
  - rescue.requested
  - rescue.completed
  - animal.rescued

FinancialService:
  - donation.received
  - payment.processed
  - kyc.required
  - veterinary.subsidy.requested
  - veterinary.subsidy.approved
  - veterinary.subsidy.rejected
  - veterinary.subsidy.expired
  - municipal.invoice.issued
  - rescuer.invoice.issued

NotificationService:
  - notification.sent
  - chat.message.delivered

ReputationService:
  - rating.created
  - reputation.updated
```

## Diseño de Reglas de Negocio y Estados de Workflow

### Implementación del Motor de Reglas de Negocio

#### Arquitectura del Business Rules Engine

```typescript
// Motor de reglas centralizado en Animal Rescue Service
class BusinessRulesEngine {
  
  // Validación de adoptabilidad (BR-050, BR-051)
  validateAdoptability(animal: Animal): AdoptabilityResult {
    const requirements = this.checkRequirements(animal);
    const restrictions = this.checkRestrictions(animal);
    
    return {
      isAdoptable: requirements.allMet && !restrictions.hasAny,
      requirements,
      restrictions,
      validatedAt: new Date()
    };
  }
  
  // Disparadores automáticos de subvención veterinaria (REQ-BR-060)
  checkVeterinarySubsidyTriggers(animal: Animal): boolean {
    return animal.conditions.callejero || 
           animal.conditions.herido || 
           animal.conditions.enfermo;
  }
  
  // Validación de autorización municipal para subvención (REQ-BR-070)
  validateMunicipalSubsidyAuthorization(
    solicitud: SolicitudSubvencionMunicipal,
    encargado: EncargadoBienestar
  ): ValidationResult {
    const errors: string[] = [];
    
    // REQ-BR-070: Solo si está en jurisdicción Y animal es callejero
    const enJurisdiccion = this.isWithinJurisdiction(
      solicitud.ubicacionAnimal, 
      encargado.jurisdiccion
    );
    
    const esCallejero = solicitud.animal.conditions.callejero === true;
    
    if (!enJurisdiccion) {
      errors.push('FUERA_DE_JURISDICCION');
    }
    
    if (!esCallejero) {
      errors.push('ANIMAL_NO_CALLEJERO');
    }
    
    return { 
      valid: errors.length === 0, 
      errors,
      canAuthorize: enJurisdiccion && esCallejero
    };
  }
  
  // Validación de integridad (BR-080, BR-081, BR-082)
  validateAnimalIntegrity(animal: Animal): ValidationResult {
    const errors: string[] = [];
    
    // BR-081: No puede comer por sí mismo si es lactante
    if (animal.requirements.comePorSiMismo && animal.restrictions.lactante) {
      errors.push('CONFLICT_EATING_LACTATING');
    }
    
    // BR-082: Recién nacido automáticamente es lactante
    if (animal.restrictions.recienNacido && !animal.restrictions.lactante) {
      animal.restrictions.lactante = true; // Auto-corrección
    }
    
    return { valid: errors.length === 0, errors };
  }
}
```

#### Máquina de Estados para Workflow

```typescript
// Estados y transiciones según reglas WF-001 a WF-042
class WorkflowStateMachine {
  
  // Estados de Solicitud de Auxilio
  private auxilio_transitions = {
    'CREADA': ['EN_REVISION', 'ASIGNADA', 'RECHAZADA'],
    'EN_REVISION': ['ASIGNADA', 'RECHAZADA'],
    'ASIGNADA': ['EN_PROGRESO', 'COMPLETADA'],
    'EN_PROGRESO': ['COMPLETADA'],
    'COMPLETADA': [], // Estado final
    'RECHAZADA': []   // Estado final
  };
  
  // Estados de Solicitud de Rescate
  private rescate_transitions = {
    'CREADA': ['PENDIENTE_SUBVENCION', 'AUTORIZADA', 'RECHAZADA'],
    'PENDIENTE_SUBVENCION': ['SUBVENCION_APROBADA', 'SUBVENCION_RECHAZADA', 'AUTORIZADA'],
    'SUBVENCION_APROBADA': ['ASIGNADA'],
    'SUBVENCION_RECHAZADA': ['ASIGNADA'], // Rescatista paga
    'AUTORIZADA': ['ASIGNADA'],
    'ASIGNADA': ['EN_PROGRESO'],
    'EN_PROGRESO': ['RESCATADO'],
    'RESCATADO': ['COMPLETADA'],
    'COMPLETADA': [], // Estado final
    'RECHAZADA': []   // Estado final
  };
  
  // Estados de Subvención Municipal (REQ-WF-050 a REQ-WF-054)
  private subvencion_transitions = {
    'CREADA': ['EN_REVISION'],
    'EN_REVISION': ['APROBADA', 'RECHAZADA', 'EXPIRADA'],
    'APROBADA': [], // Estado final
    'RECHAZADA': [], // Estado final
    'EXPIRADA': []   // Estado final
  };
  
  // Transiciones automáticas (WF-040 a WF-042)
  async handleAutomaticTransitions(event: WorkflowEvent): Promise<void> {
    switch (event.type) {
      case 'AUXILIO_COMPLETADO':
        // WF-040: Crear automáticamente solicitud de rescate
        await this.createRescueRequest(event.data);
        break;
        
      case 'ANIMAL_ATTRIBUTES_UPDATED':
        // WF-041: Evaluar adoptabilidad automáticamente
        const adoptability = this.rulesEngine.validateAdoptability(event.data.animal);
        if (adoptability.isAdoptable) {
          await this.transitionAnimalState(event.data.animal.id, 'ADOPTABLE');
        }
        break;
        
      case 'SOLICITUD_RESCATE_CREADA':
        // REQ-BR-060: Crear automáticamente solicitud de subvención veterinaria
        const animal = event.data.animal;
        if (animal.conditions.callejero || animal.conditions.herido || animal.conditions.enfermo) {
          await this.createVeterinarySubsidyRequest(event.data);
          await this.transitionRescueState(event.data.rescueId, 'PENDIENTE_SUBVENCION');
        }
        break;
        
      case 'SUBVENCION_APROBADA':
        // REQ-WF-052: Facturación municipal automática
        await this.financialService.emitirFacturaMunicipal(event.data.solicitudSubvencion);
        await this.transitionRescueState(event.data.rescueId, 'SUBVENCION_APROBADA');
        break;
        
      case 'SUBVENCION_RECHAZADA':
      case 'SUBVENCION_EXPIRADA':
        // REQ-WF-053, REQ-WF-054: Facturación a rescatista automática
        await this.financialService.emitirFacturaRescatista(event.data.solicitudSubvencion);
        await this.transitionRescueState(event.data.rescueId, 'SUBVENCION_RECHAZADA');
        break;
    }
  }
}
```

### Diseño de Geolocalización y Proximidad

#### Algoritmos de Búsqueda por Proximidad

```typescript
// Implementación de reglas GEO-001 a GEO-022
class ProximitySearchEngine {
  
  // Búsqueda escalonada de auxiliares (GEO-001 a GEO-004)
  async findAuxiliares(solicitud: SolicitudAuxilio): Promise<Auxiliar[]> {
    let radius = 10; // GEO-001: Radio inicial 10km
    let auxiliares: Auxiliar[] = [];
    
    // Búsqueda inicial
    auxiliares = await this.searchInRadius(solicitud.ubicacion, radius);
    
    if (auxiliares.length === 0) {
      // GEO-002: Expandir a 25km después de 30 minutos
      setTimeout(async () => {
        radius = 25;
        auxiliares = await this.searchInRadius(solicitud.ubicacion, radius);
        await this.notifyAuxiliares(auxiliares, solicitud);
      }, 30 * 60 * 1000);
      
      // GEO-003: Expandir a 50km después de 60 minutos y alertar supervisores
      setTimeout(async () => {
        radius = 50;
        auxiliares = await this.searchInRadius(solicitud.ubicacion, radius);
        await this.alertSupervisors(solicitud);
      }, 60 * 60 * 1000);
    }
    
    return auxiliares;
  }
  
  // Búsqueda de rescatistas (GEO-010 a GEO-012)
  async findRescatistas(solicitud: SolicitudRescate): Promise<RescatistaScore[]> {
    const radius = 15; // GEO-010: Radio inicial 15km
    const rescatistas = await this.searchInRadius(solicitud.ubicacion, radius);
    
    return rescatistas.map(rescatista => ({
      rescatista,
      score: this.calculateRescatistaScore(rescatista, solicitud)
    })).sort((a, b) => b.score - a.score);
  }
  
  // Algoritmo de priorización según Apéndice F
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
}
```

#### Validación de Jurisdicciones

```typescript
// Implementación de reglas JUR-001 a JUR-022
class JurisdictionValidator {
  
  // Validación de autorización veterinaria (BR-070, JUR-010, JUR-011)
  async validateVeterinaryAuthorization(
    solicitud: SolicitudRescate, 
    encargado: EncargadoBienestar
  ): Promise<AuthorizationResult> {
    
    // JUR-011: Determinar jurisdicción por ubicación exacta del animal
    const jurisdiccion = await this.getJurisdictionByLocation(solicitud.ubicacion);
    
    // JUR-010: Solo encargados de la jurisdicción correspondiente pueden autorizar
    const enJurisdiccion = encargado.jurisdicciones.includes(jurisdiccion.id);
    
    // BR-070: Verificar condición callejero
    const esCallejero = solicitud.animal.condiciones.callejero === true;
    
    // JUR-012: Casos fronterizos requieren autorización múltiple
    const esFronterizo = await this.isBorderCase(solicitud.ubicacion);
    if (esFronterizo) {
      const jurisdiccionesAfectadas = await this.getOverlappingJurisdictions(solicitud.ubicacion);
      return {
        authorized: false,
        requiresMultipleAuthorizations: true,
        jurisdictions: jurisdiccionesAfectadas
      };
    }
    
    return {
      authorized: enJurisdiccion && esCallejero,
      jurisdiction: jurisdiccion,
      encargado: encargado
    };
  }
  
  // Casos especiales de jurisdicción (JUR-020 a JUR-022)
  async handleSpecialCases(ubicacion: Coordenadas): Promise<JurisdictionResult> {
    // JUR-020: Carreteras nacionales
    if (await this.isOnNationalHighway(ubicacion)) {
      const cantonMasCercano = await this.findNearestCanton(ubicacion);
      return { jurisdiction: cantonMasCercano, type: 'CARRETERA_NACIONAL' };
    }
    
    // JUR-021: Zonas protegidas
    if (await this.isInProtectedArea(ubicacion)) {
      return {
        jurisdiction: await this.getJurisdictionByLocation(ubicacion),
        type: 'ZONA_PROTEGIDA',
        requiresEnvironmentalAuthorization: true, // SINAC en Costa Rica, SEMARNAT en México, etc.
        environmentalEntity: await this.getEnvironmentalEntity(ubicacion)
      };
    }
    
    return { jurisdiction: await this.getJurisdictionByLocation(ubicacion), type: 'NORMAL' };
  }
}
```

### Arquitectura Multi-Tenant para Gobiernos Locales

#### Segregación de Datos por Alcance

```typescript
// Arquitectura de datos: Centralizado vs Multi-Tenant
class DataArchitecture {
  
  // DATOS CENTRALIZADOS (compartidos entre todos los países/municipios)
  centralizedData = {
    // Core AltruPets data - NO segregado
    users: 'Usuarios de toda la plataforma',
    animals: 'Animales rescatados en toda LATAM',
    rescueRequests: 'Solicitudes de rescate globales',
    donations: 'Donaciones dentro de cada país (NO cross-border inicialmente)',
    veterinarians: 'Red de veterinarios regional',
    rescuerFosterHomes: 'Casas cuna de rescatistas de toda la región',
    
    // Configuración regional - NO segregado
    countries: 'Configuración de países',
    currencies: 'Monedas soportadas',
    regulatoryEntities: 'Entidades reguladoras por país',
    exchangeRates: 'Tasas de cambio globales'
  };
  
  // DATOS MULTI-TENANT (segregados por gobierno local)
  multiTenantData = {
    // Solo datos gubernamentales específicos
    governmentTenants: 'Configuración por municipio/provincia',
    jurisdictionalPolicies: 'Políticas específicas del gobierno local',
    localAuthorizations: 'Autorizaciones veterinarias por jurisdicción',
    municipalReports: 'Reportes específicos del gobierno local',
    localConflictResolution: 'Mediación de conflictos jurisdiccional'
  };
}
```

#### Implementación de Multi-Tenancy Gubernamental

```sql
-- Tabla de tenants gubernamentales (SOLO para gobiernos locales)
CREATE TABLE government_tenants (
  id UUID PRIMARY KEY,
  tenant_code VARCHAR(50) NOT NULL UNIQUE, -- 'SAN_JOSE_CR', 'CDMX_MEX', etc.
  tenant_name VARCHAR(200) NOT NULL,
  
  -- Ubicación administrativa
  country_code VARCHAR(3) NOT NULL REFERENCES countries(country_code),
  state_province VARCHAR(100),
  municipality VARCHAR(100),
  administrative_level administrative_level_enum, -- 'MUNICIPAL', 'PROVINCIAL', 'STATE'
  
  -- Configuración del tenant
  jurisdiction_polygon GEOMETRY(POLYGON, 4326) NOT NULL,
  parent_tenant_id UUID REFERENCES government_tenants(id), -- Para jerarquías
  
  -- Configuración específica del gobierno local
  local_policies JSONB, -- Políticas específicas del municipio
  contact_info JSONB,
  branding_config JSONB, -- Logo, colores para reportes
  
  -- Estado del tenant
  is_active BOOLEAN DEFAULT TRUE,
  subscription_tier VARCHAR(50) DEFAULT 'BASIC', -- BASIC, PREMIUM, ENTERPRISE
  created_at TIMESTAMP DEFAULT NOW(),
  
  INDEX idx_tenant_country (country_code),
  INDEX idx_tenant_polygon USING GIST (jurisdiction_polygon)
);

-- Enum para niveles administrativos
CREATE TYPE administrative_level_enum AS ENUM ('MUNICIPAL', 'PROVINCIAL', 'STATE', 'NATIONAL');

-- Tabla de autorizaciones veterinarias (MULTI-TENANT)
CREATE TABLE veterinary_authorizations (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES government_tenants(id), -- SEGREGACIÓN POR TENANT
  
  solicitud_rescate_id UUID REFERENCES solicitudes_rescate(id),
  encargado_bienestar_id UUID NOT NULL,
  animal_location GEOMETRY(POINT, 4326) NOT NULL,
  
  authorization_status authorization_status_enum DEFAULT 'PENDIENTE',
  justification TEXT,
  authorized_at TIMESTAMP,
  expires_at TIMESTAMP,
  
  -- Metadatos del tenant
  tenant_policies_applied JSONB, -- Políticas específicas aplicadas
  
  created_at TIMESTAMP DEFAULT NOW(),
  
  -- Índice compuesto para segregación por tenant
  INDEX idx_auth_tenant_status (tenant_id, authorization_status),
  INDEX idx_auth_tenant_date (tenant_id, created_at)
);

-- Tabla de reportes gubernamentales (MULTI-TENANT)
CREATE TABLE government_reports (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES government_tenants(id), -- SEGREGACIÓN POR TENANT
  
  report_type VARCHAR(50) NOT NULL, -- 'MONTHLY_RESCUES', 'FINANCIAL_TRANSPARENCY', etc.
  report_period_start DATE NOT NULL,
  report_period_end DATE NOT NULL,
  
  -- Datos del reporte (solo para este tenant)
  report_data JSONB NOT NULL,
  generated_by UUID NOT NULL, -- Usuario que generó el reporte
  
  created_at TIMESTAMP DEFAULT NOW(),
  
  INDEX idx_reports_tenant_type (tenant_id, report_type),
  INDEX idx_reports_tenant_period (tenant_id, report_period_start, report_period_end)
);

-- Función para obtener datos por tenant (ROW LEVEL SECURITY)
CREATE OR REPLACE FUNCTION get_current_tenant_id() RETURNS UUID AS $$
BEGIN
  -- Obtener tenant_id del contexto de la sesión
  RETURN current_setting('app.current_tenant_id', true)::UUID;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Row Level Security para autorizaciones veterinarias
ALTER TABLE veterinary_authorizations ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_policy ON veterinary_authorizations
  FOR ALL
  TO application_role
  USING (tenant_id = get_current_tenant_id());

-- Row Level Security para reportes gubernamentales  
ALTER TABLE government_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_reports_policy ON government_reports
  FOR ALL
  TO application_role
  USING (tenant_id = get_current_tenant_id());
```

#### Lógica de Aplicación Multi-Tenant

```typescript
// Servicio de contexto de tenant (solo para funciones gubernamentales)
class TenantContextService {
  
  // Establecer contexto de tenant para operaciones gubernamentales
  async setTenantContext(userId: string, operation: string): Promise<void> {
    
    // Solo aplicar multi-tenancy para operaciones gubernamentales
    const governmentalOperations = [
      'veterinary_authorization',
      'government_reports', 
      'conflict_mediation',
      'jurisdictional_oversight'
    ];
    
    if (!governmentalOperations.includes(operation)) {
      // Para operaciones normales de AltruPets, NO hay segregación
      return;
    }
    
    const user = await this.userService.findById(userId);
    
    if (user.role === 'GOVERNMENT_ADMIN') {
      const tenantId = await this.getTenantByUser(userId);
      await this.database.query('SET app.current_tenant_id = $1', [tenantId]);
    }
  }
  
  // Obtener configuración del tenant gubernamental
  async getTenantConfig(tenantId: string): Promise<TenantConfig> {
    const tenant = await this.tenantRepository.findById(tenantId);
    
    return {
      tenantId: tenant.id,
      tenantCode: tenant.tenantCode,
      jurisdiction: tenant.jurisdictionPolygon,
      localPolicies: tenant.localPolicies,
      brandingConfig: tenant.brandingConfig,
      subscriptionTier: tenant.subscriptionTier
    };
  }
}

// Servicio de autorización veterinaria (MULTI-TENANT)
class VeterinaryAuthorizationService {
  
  async createAuthorization(
    solicitudRescateId: string,
    encargadoId: string
  ): Promise<AuthorizationResult> {
    
    // 1. Determinar tenant basado en la ubicación del rescate
    const solicitud = await this.rescueService.findById(solicitudRescateId);
    const tenant = await this.getTenantByLocation(solicitud.location);
    
    // 2. Establecer contexto de tenant para esta operación
    await this.tenantContext.setTenantContext(encargadoId, 'veterinary_authorization');
    
    // 3. Validar que el encargado pertenece a este tenant
    const encargado = await this.userService.findById(encargadoId);
    if (encargado.tenantId !== tenant.id) {
      throw new Error('Encargado no autorizado para esta jurisdicción');
    }
    
    // 4. Crear autorización (automáticamente segregada por RLS)
    const authorization = await this.authorizationRepository.create({
      tenantId: tenant.id, // Segregación explícita
      solicitudRescateId,
      encargadoBienestarId: encargadoId,
      animalLocation: solicitud.location,
      tenantPoliciesApplied: tenant.localPolicies
    });
    
    return { success: true, authorizationId: authorization.id };
  }
}

// Servicio de reportes gubernamentales (MULTI-TENANT)
class GovernmentReportsService {
  
  async generateReport(
    tenantId: string,
    reportType: string,
    startDate: Date,
    endDate: Date
  ): Promise<GovernmentReport> {
    
    // Establecer contexto de tenant
    await this.tenantContext.setTenantContext(tenantId, 'government_reports');
    
    // Obtener datos SOLO de este tenant (gracias a RLS)
    const reportData = await this.generateReportData(reportType, startDate, endDate);
    
    // Los datos de rescates, donaciones, etc. son globales pero filtrados por jurisdicción
    const jurisdictionalData = await this.filterDataByJurisdiction(
      reportData,
      tenantId
    );
    
    return await this.reportRepository.create({
      tenantId, // Segregación por tenant
      reportType,
      reportPeriodStart: startDate,
      reportPeriodEnd: endDate,
      reportData: jurisdictionalData
    });
  }
}
```

### Diseño del Sistema Multi-Moneda

```typescript
// Servicio de gestión multi-moneda
class MultiCurrencyService {
  
  // Configuración de monedas por país
  async getCurrencyConfig(countryCode: string): Promise<CurrencyConfig> {
    const country = await this.countryRepository.findByCode(countryCode);
    const currencies = await this.currencyRepository.findByCountry(countryCode);
    
    return {
      defaultCurrency: country.defaultCurrencyCode,
      supportedCurrencies: currencies,
      paymentProviders: await this.getPaymentProviders(countryCode),
      kycThresholds: await this.getKycThresholds(countryCode)
    };
  }
  
  // Conversión de monedas con tasas actualizadas
  async convertCurrency(
    amount: number,
    fromCurrency: string,
    toCurrency: string,
    date?: Date
  ): Promise<ConversionResult> {
    
    if (fromCurrency === toCurrency) {
      return { convertedAmount: amount, rate: 1.0, date: new Date() };
    }
    
    const exchangeRate = await this.getExchangeRate(fromCurrency, toCurrency, date);
    const convertedAmount = amount * exchangeRate.rate;
    
    return {
      convertedAmount: Math.round(convertedAmount * 100) / 100, // 2 decimales
      rate: exchangeRate.rate,
      date: exchangeRate.date,
      source: exchangeRate.source
    };
  }
  
  // Validación KYC basada en país y monto
  async validateKycRequirement(
    donorCountry: string,
    amount: number,
    currency: string,
    period: 'daily' | 'monthly' | 'annual' = 'daily'
  ): Promise<KycValidationResult> {
    
    const threshold = await this.getKycThreshold(donorCountry, currency, period);
    const convertedAmount = await this.convertToLocalCurrency(amount, currency, donorCountry);
    
    const requiresKyc = convertedAmount >= threshold.amount;
    const regulatoryEntity = await this.getRegulatoryEntity(donorCountry, 'FINANCIAL');
    
    return {
      requiresKyc,
      threshold: threshold.amount,
      thresholdCurrency: threshold.currency,
      regulatoryEntity: regulatoryEntity.entityName,
      requiredDocuments: requiresKyc ? threshold.requiredDocuments : []
    };
  }
}

// Servicio de procesamiento de donaciones multi-país
class DonationProcessingService {
  
  async processDonation(donationRequest: DonationRequest): Promise<DonationResult> {
    
    // 1. Validar que donante y receptor estén en el mismo país (NO cross-border)
    if (donationRequest.donorCountry !== donationRequest.recipientCountry) {
      throw new Error('Donaciones cross-border no soportadas inicialmente');
    }
    
    // 2. Validar configuración del país
    const countryConfig = await this.multiCurrencyService.getCurrencyConfig(
      donationRequest.country
    );
    
    // 3. Determinar si requiere KYC
    const kycValidation = await this.multiCurrencyService.validateKycRequirement(
      donationRequest.country,
      donationRequest.amount,
      donationRequest.currency
    );
    
    if (kycValidation.requiresKyc && !donationRequest.kycCompleted) {
      return {
        success: false,
        requiresKyc: true,
        kycRequirements: kycValidation.requiredDocuments,
        regulatoryEntity: kycValidation.regulatoryEntity
      };
    }
    
    // 4. Seleccionar proveedor de pago del país
    const paymentProvider = await this.selectPaymentProvider(
      donationRequest.country,
      donationRequest.currency,
      donationRequest.amount
    );
    
    // 5. Convertir moneda solo si es USD → moneda local o viceversa
    let finalAmount = donationRequest.amount;
    let finalCurrency = donationRequest.currency;
    let exchangeRate = 1.0;
    
    if (donationRequest.currency !== countryConfig.defaultCurrency && 
        donationRequest.currency !== 'USD') {
      throw new Error('Solo se soporta moneda local y USD');
    }
    
    if (donationRequest.currency === 'USD' && countryConfig.defaultCurrency !== 'USD') {
      const conversion = await this.multiCurrencyService.convertCurrency(
        donationRequest.amount,
        'USD',
        countryConfig.defaultCurrency
      );
      finalAmount = conversion.convertedAmount;
      finalCurrency = countryConfig.defaultCurrency;
      exchangeRate = conversion.rate;
    }
    
    // 6. Procesar pago
    const paymentResult = await paymentProvider.processPayment({
      amount: donationRequest.amount,
      currency: donationRequest.currency,
      finalAmount,
      finalCurrency,
      donorId: donationRequest.donorId,
      recipientId: donationRequest.recipientId
    });
    
    // 7. Registrar transacción (mismo país)
    await this.recordTransaction({
      originalAmount: donationRequest.amount,
      originalCurrency: donationRequest.currency,
      finalAmount,
      finalCurrency,
      exchangeRate,
      countryCode: donationRequest.country,
      paymentProvider: paymentProvider.name,
      transactionId: paymentResult.transactionId
    });
    
    return {
      success: true,
      transactionId: paymentResult.transactionId,
      originalAmount: donationRequest.amount,
      originalCurrency: donationRequest.currency,
      finalAmount,
      finalCurrency,
      exchangeRate
    };
  }
  
  // Seleccionar proveedor de pago según país y moneda
  private async selectPaymentProvider(
    countryCode: string,
    currency: string,
    amount: number
  ): Promise<PaymentProvider> {
    
    const providers = await this.getPaymentProviders(countryCode, currency);
    
    // Lógica de selección basada en:
    // 1. Soporte de moneda
    // 2. Límites de monto
    // 3. Fees más bajos
    // 4. Confiabilidad del proveedor
    
    return providers.find(provider => 
      provider.supportsCurrency(currency) &&
      provider.supportsAmount(amount) &&
      provider.isAvailable()
    ) || providers[0]; // Fallback al primer proveedor disponible
  }
}

// Interfaces para el sistema multi-moneda
interface CurrencyConfig {
  defaultCurrency: string;
  supportedCurrencies: Currency[];
  paymentProviders: PaymentProvider[];
  kycThresholds: KycThreshold[];
}

interface ConversionResult {
  convertedAmount: number;
  rate: number;
  date: Date;
  source: string;
}

interface KycValidationResult {
  requiresKyc: boolean;
  threshold: number;
  thresholdCurrency: string;
  regulatoryEntity: string;
  requiredDocuments: string[];
}

interface DonationRequest {
  donorId: string;
  recipientId: string;
  amount: number;
  currency: string; // Solo moneda local o USD
  country: string; // Mismo país para donante y receptor
  kycCompleted?: boolean;
  purpose?: string;
  animalId?: string;
}
```

### Diseño de Asociaciones Rescatista-Casa Cuna

```typescript
// Implementación de reglas BR-001 a BR-003
class RescatistaCasaCunaManager {
  
  // BR-001: Un rescatista puede tener múltiples casas cuna
  async associateRescatistaWithCasaCuna(
    rescatistaId: string, 
    casaCunaId: string
  ): Promise<AssociationResult> {
    
    // BR-003: Requiere autorización explícita de ambas partes
    const rescatistaApproval = await this.requestRescatistaApproval(rescatistaId, casaCunaId);
    const casaCunaApproval = await this.requestCasaCunaApproval(casaCunaId, rescatistaId);
    
    if (rescatistaApproval && casaCunaApproval) {
      await this.createAssociation(rescatistaId, casaCunaId);
      return { success: true, associationId: generateId() };
    }
    
    return { success: false, reason: 'MISSING_APPROVALS' };
  }
  
  // BR-002: Una casa cuna puede estar asociada a múltiples rescatistas
  async getCasaCunaRescatistas(casaCunaId: string): Promise<Rescatista[]> {
    return await this.repository.findRescatistasByCasaCuna(casaCunaId);
  }
}
```

## Modelos de Datos por Microservicio

### Database per Service Pattern

Cada microservicio tiene su propia base de datos para garantizar desacoplamiento:

#### User Management Service - PostgreSQL
```sql
-- Tabla de usuarios con encriptación
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone_encrypted BYTEA,
  user_type user_type_enum,
  location POINT,
  created_at TIMESTAMP DEFAULT NOW(),
  is_verified BOOLEAN DEFAULT FALSE
);

-- Tabla de roles con RBAC
CREATE TABLE user_roles (
  user_id UUID REFERENCES users(id),
  role role_enum,
  organization_id UUID,
  granted_at TIMESTAMP DEFAULT NOW()
);
```

#### Animal Rescue Service - PostgreSQL
```sql
-- Enums para estados de workflow
CREATE TYPE solicitud_auxilio_state AS ENUM (
  'CREADA', 'EN_REVISION', 'ASIGNADA', 'EN_PROGRESO', 'COMPLETADA', 'RECHAZADA'
);

CREATE TYPE solicitud_rescate_state AS ENUM (
  'CREADA', 'PENDIENTE_AUTORIZACION', 'AUTORIZADA', 'ASIGNADA', 
  'EN_PROGRESO', 'RESCATADO', 'COMPLETADA', 'RECHAZADA'
);

CREATE TYPE animal_state AS ENUM (
  'REPORTADO', 'EVALUADO', 'EN_RESCATE', 'EN_CUIDADO', 'ADOPTABLE', 
  'ADOPTADO', 'NO_ADOPTABLE', 'FALLECIDO', 'INALCANZABLE', 'FALSA_ALARMA'
);

-- Tabla de solicitudes de auxilio (centinelas)
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

-- Tabla de solicitudes de rescate (auxiliares)
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

-- Tabla de animales con reglas de negocio implementadas
CREATE TABLE animals (
  id UUID PRIMARY KEY,
  name VARCHAR(255),
  species species_enum,
  breed VARCHAR(255),
  age_months INTEGER,
  sex sex_enum,
  
  -- Condiciones del animal (BR-060 disparadores)
  discapacitado BOOLEAN DEFAULT FALSE,
  paciente_cronico BOOLEAN DEFAULT FALSE,
  zeropositivo BOOLEAN DEFAULT FALSE,
  callejero BOOLEAN DEFAULT FALSE,
  
  -- Requisitos de adoptabilidad (BR-050 - TODOS deben ser TRUE)
  usa_arenero BOOLEAN DEFAULT FALSE,
  come_por_si_mismo BOOLEAN DEFAULT FALSE,
  
  -- Restricciones de adoptabilidad (BR-051 - CUALQUIERA impide adopción)
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
  current_caretaker_id UUID,
  casa_cuna_id UUID,
  rescue_date TIMESTAMP,
  adoptability_last_checked TIMESTAMP,
  is_adoptable BOOLEAN GENERATED ALWAYS AS (
    -- BR-050: Todos los requisitos deben ser TRUE
    usa_arenero = TRUE AND come_por_si_mismo = TRUE AND
    -- BR-051: Ninguna restricción debe ser TRUE
    arizco_con_humanos = FALSE AND arizco_con_animales = FALSE AND
    lactante = FALSE AND nodriza = FALSE AND enfermo = FALSE AND
    herido = FALSE AND recien_parida = FALSE AND recien_nacido = FALSE
  ) STORED,
  
  version INTEGER DEFAULT 1,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de asociaciones rescatista-casa cuna (BR-001, BR-002, BR-003)
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

-- Tabla de autorizaciones veterinarias gubernamentales
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

-- Tabla de solicitudes de subvención municipal veterinaria (REQ-FIN-VET-001 a REQ-FIN-VET-014)
CREATE TABLE solicitudes_subvencion_municipal (
  id UUID PRIMARY KEY,
  veterinario_id UUID NOT NULL,
  rescatista_id UUID NOT NULL,
  animal_id UUID REFERENCES animals(id),
  solicitud_rescate_id UUID REFERENCES solicitudes_rescate(id),
  
  -- Segregación multi-tenant (REQ-MT-002)
  tenant_municipal_id UUID NOT NULL REFERENCES government_tenants(id),
  
  -- Detalles del procedimiento
  monto_tentativo DECIMAL(10,2) NOT NULL,
  desgloce_servicios JSONB NOT NULL,
  fecha_procedimiento TIMESTAMP NOT NULL,
  ubicacion_animal POINT NOT NULL,
  
  -- Estados del workflow (REQ-WF-050 a REQ-WF-054)
  estado subvencion_estado_enum DEFAULT 'CREADA',
  
  -- Configuración temporal
  tiempo_maximo_respuesta_horas INTEGER NOT NULL DEFAULT 72, -- Configurable por municipalidad
  fecha_creacion TIMESTAMP DEFAULT NOW(),
  fecha_expiracion TIMESTAMP GENERATED ALWAYS AS (
    fecha_creacion + (tiempo_maximo_respuesta_horas || ' hours')::INTERVAL
  ) STORED,
  
  -- Resolución
  aprobado_por UUID,
  fecha_aprobacion TIMESTAMP,
  fecha_rechazo TIMESTAMP,
  fecha_expiracion_real TIMESTAMP,
  motivo_rechazo TEXT,
  
  -- Facturación
  factura_municipal_id UUID,
  factura_rescatista_id UUID,
  
  -- Auditoría (REQ-FIN-VET-013)
  auditoria JSONB DEFAULT '{}',
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  -- Índices para performance y segregación
  INDEX idx_subvencion_tenant_estado (tenant_municipal_id, estado),
  INDEX idx_subvencion_veterinario (veterinario_id),
  INDEX idx_subvencion_rescatista (rescatista_id),
  INDEX idx_subvencion_expiracion (fecha_expiracion) WHERE estado = 'EN_REVISION'
);

-- Enum para estados de subvención
CREATE TYPE subvencion_estado_enum AS ENUM (
  'CREADA', 'EN_REVISION', 'APROBADA', 'RECHAZADA', 'EXPIRADA'
);

-- Row Level Security para segregación multi-tenant (REQ-MT-005)
ALTER TABLE solicitudes_subvencion_municipal ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_subvencion_policy ON solicitudes_subvencion_municipal
  FOR ALL
  TO application_role
  USING (tenant_municipal_id = get_current_tenant_id());

-- Tabla de facturas veterinarias
CREATE TABLE facturas_veterinarias (
  id UUID PRIMARY KEY,
  solicitud_subvencion_id UUID REFERENCES solicitudes_subvencion_municipal(id),
  
  -- Sujeto obligado de pago
  facturado_a_tipo facturado_tipo_enum, -- 'MUNICIPALIDAD' | 'RESCATISTA'
  facturado_a_id UUID NOT NULL, -- ID de municipalidad o rescatista
  
  -- Detalles de facturación
  monto_total DECIMAL(10,2) NOT NULL,
  moneda VARCHAR(3) DEFAULT 'CRC',
  desgloce_servicios JSONB NOT NULL,
  
  -- Proveedor
  veterinario_id UUID NOT NULL,
  clinica_id UUID,
  
  -- Estado de pago
  estado_pago pago_estado_enum DEFAULT 'PENDIENTE',
  fecha_pago TIMESTAMP,
  metodo_pago VARCHAR(50),
  referencia_pago VARCHAR(255),
  
  -- Metadatos
  fecha_emision TIMESTAMP DEFAULT NOW(),
  fecha_vencimiento TIMESTAMP DEFAULT (NOW() + INTERVAL '30 days'),
  
  created_at TIMESTAMP DEFAULT NOW()
);

-- Enums adicionales
CREATE TYPE facturado_tipo_enum AS ENUM ('MUNICIPALIDAD', 'RESCATISTA');
CREATE TYPE pago_estado_enum AS ENUM ('PENDIENTE', 'PAGADO', 'VENCIDO', 'CANCELADO');

-- Triggers para reglas de negocio automáticas
CREATE OR REPLACE FUNCTION validate_animal_integrity()
RETURNS TRIGGER AS $$
BEGIN
  -- BR-082: Recién nacido automáticamente es lactante
  IF NEW.recien_nacido = TRUE THEN
    NEW.lactante = TRUE;
  END IF;
  
  -- BR-081: No puede comer por sí mismo si es lactante
  IF NEW.come_por_si_mismo = TRUE AND NEW.lactante = TRUE THEN
    RAISE EXCEPTION 'Un animal lactante no puede comer por sí mismo (BR-081)';
  END IF;
  
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER animal_integrity_trigger
  BEFORE INSERT OR UPDATE ON animals
  FOR EACH ROW EXECUTE FUNCTION validate_animal_integrity();

-- Trigger para autorización veterinaria automática (BR-060)
CREATE OR REPLACE FUNCTION check_veterinary_authorization_trigger()
RETURNS TRIGGER AS $$
DECLARE
  animal_record RECORD;
BEGIN
  -- Obtener datos del animal de la solicitud de auxilio referenciada
  SELECT a.* INTO animal_record
  FROM animals a
  JOIN solicitudes_auxilio sa ON sa.id = NEW.solicitud_auxilio_id
  WHERE a.id = sa.animal_id;
  
  -- BR-060: Verificar disparadores de autorización veterinaria
  IF animal_record.callejero = TRUE OR 
     animal_record.herido = TRUE OR 
     animal_record.enfermo = TRUE THEN
    
    NEW.requires_veterinary_auth = TRUE;
    NEW.veterinary_auth_requested_at = NOW();
    
    -- Crear solicitud de autorización automáticamente
    INSERT INTO veterinary_authorizations (
      solicitud_rescate_id,
      animal_location,
      jurisdiction_id
    ) VALUES (
      NEW.id,
      NEW.location,
      (SELECT get_jurisdiction_by_location(NEW.location))
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER veterinary_authorization_trigger
  BEFORE INSERT ON solicitudes_rescate
  FOR EACH ROW EXECUTE FUNCTION check_veterinary_authorization_trigger();
```

#### Financial Service - PostgreSQL (Encriptada)
```sql
-- Tabla de transacciones con Event Sourcing y soporte multi-moneda
CREATE TABLE financial_transactions (
  id UUID PRIMARY KEY,
  event_type VARCHAR(50),
  aggregate_id UUID,
  
  -- Montos en moneda original y USD para auditoría
  original_amount DECIMAL(15,2) NOT NULL,
  original_currency VARCHAR(3) NOT NULL,
  usd_amount DECIMAL(15,2) NOT NULL, -- Siempre convertir a USD para reportes
  exchange_rate DECIMAL(18,8),
  exchange_rate_date DATE,
  
  -- Información del país y proveedor
  country_code VARCHAR(3) NOT NULL,
  payment_provider VARCHAR(50),
  provider_transaction_id VARCHAR(255),
  
  event_data JSONB,
  encrypted_pii BYTEA,
  timestamp TIMESTAMP DEFAULT NOW(),
  version INTEGER,
  
  -- Índices para consultas por moneda y país
  INDEX idx_transactions_currency (original_currency),
  INDEX idx_transactions_country (country_code),
  INDEX idx_transactions_date (timestamp)
);

-- Tabla de tokens de pago (PCI DSS compliant) por país
CREATE TABLE payment_tokens (
  id UUID PRIMARY KEY,
  user_id UUID,
  country_code VARCHAR(3) NOT NULL,
  currency_code VARCHAR(3) NOT NULL,
  token_reference VARCHAR(255), -- Solo token, nunca datos de tarjeta
  provider VARCHAR(50),
  provider_config JSONB, -- Configuración específica del proveedor por país
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP,
  
  INDEX idx_tokens_user_country (user_id, country_code)
);

-- Tabla de donaciones con soporte multi-moneda
CREATE TABLE donations (
  id UUID PRIMARY KEY,
  donor_id UUID NOT NULL,
  recipient_id UUID NOT NULL, -- rescatista o casa cuna
  
  -- Montos multi-moneda
  requested_amount DECIMAL(15,2) NOT NULL,
  requested_currency VARCHAR(3) NOT NULL,
  final_amount DECIMAL(15,2) NOT NULL, -- Después de fees y conversiones
  final_currency VARCHAR(3) NOT NULL,
  
  -- Información geográfica (mismo país inicialmente)
  country_code VARCHAR(3) NOT NULL, -- Donante y receptor en el mismo país
  requires_kyc BOOLEAN DEFAULT FALSE,
  kyc_completed BOOLEAN DEFAULT FALSE,
  
  -- Metadatos de la donación
  donation_type donation_type_enum DEFAULT 'ONE_TIME', -- 'ONE_TIME', 'RECURRING', 'EMERGENCY'
  purpose TEXT,
  animal_id UUID, -- Si es para un animal específico
  
  status donation_status_enum DEFAULT 'PENDING',
  payment_method VARCHAR(50),
  transaction_id UUID REFERENCES financial_transactions(id),
  
  created_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP,
  
  INDEX idx_donations_donor (donor_id),
  INDEX idx_donations_recipient (recipient_id),
  INDEX idx_donations_currency (requested_currency),
  INDEX idx_donations_country (country_code)
);

-- Enums para donaciones
CREATE TYPE donation_type_enum AS ENUM ('ONE_TIME', 'RECURRING', 'EMERGENCY');
CREATE TYPE donation_status_enum AS ENUM ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'REFUNDED');

-- Tabla de configuración KYC por país
CREATE TABLE kyc_thresholds (
  id UUID PRIMARY KEY,
  country_code VARCHAR(3) NOT NULL,
  currency_code VARCHAR(3) NOT NULL,
  daily_threshold DECIMAL(15,2) DEFAULT 1000.00,
  monthly_threshold DECIMAL(15,2) DEFAULT 5000.00,
  annual_threshold DECIMAL(15,2) DEFAULT 50000.00,
  requires_identity_verification BOOLEAN DEFAULT TRUE,
  requires_address_verification BOOLEAN DEFAULT TRUE,
  requires_source_of_funds BOOLEAN DEFAULT FALSE,
  regulatory_entity_code VARCHAR(20), -- SUGEF, CNBV, etc.
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  UNIQUE(country_code, currency_code)
);

-- Función para determinar si se requiere KYC
CREATE OR REPLACE FUNCTION requires_kyc_validation(
  donor_country VARCHAR(3),
  amount DECIMAL(15,2),
  currency VARCHAR(3),
  period_type VARCHAR(10) DEFAULT 'daily' -- 'daily', 'monthly', 'annual'
) RETURNS BOOLEAN AS $$
DECLARE
  threshold_amount DECIMAL(15,2);
  converted_amount DECIMAL(15,2);
BEGIN
  -- Obtener el threshold según el período
  SELECT 
    CASE 
      WHEN period_type = 'daily' THEN daily_threshold
      WHEN period_type = 'monthly' THEN monthly_threshold  
      WHEN period_type = 'annual' THEN annual_threshold
      ELSE daily_threshold
    END
  INTO threshold_amount
  FROM kyc_thresholds
  WHERE country_code = donor_country AND currency_code = currency;
  
  -- Si no hay configuración específica, usar USD como fallback
  IF threshold_amount IS NULL THEN
    SELECT daily_threshold INTO threshold_amount
    FROM kyc_thresholds
    WHERE country_code = donor_country AND currency_code = 'USD';
  END IF;
  
  -- Convertir monto a la moneda del threshold para comparación
  converted_amount := convert_currency(amount, currency, 
    (SELECT currency_code FROM kyc_thresholds WHERE country_code = donor_country LIMIT 1));
  
  RETURN converted_amount >= COALESCE(threshold_amount, 1000.00);
END;
$$ LANGUAGE plpgsql;

-- Función para obtener configuración de pago por país
CREATE OR REPLACE FUNCTION get_payment_config_by_country(
  country_code_param VARCHAR(3),
  currency_code_param VARCHAR(3)
) RETURNS TABLE (
  provider VARCHAR,
  config JSONB,
  min_amount DECIMAL,
  max_amount DECIMAL,
  kyc_threshold DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    cpc.payment_provider,
    cpc.provider_config,
    cpc.min_donation_amount,
    cpc.max_donation_amount,
    cpc.kyc_threshold_amount
  FROM country_payment_config cpc
  JOIN countries c ON c.id = cpc.country_id
  JOIN currencies cur ON cur.id = cpc.currency_id
  WHERE c.country_code = country_code_param
    AND cur.currency_code = currency_code_param
    AND cpc.is_active = TRUE
    AND c.is_active = TRUE
    AND cur.is_active = TRUE;
END;
$$ LANGUAGE plpgsql;
```

#### Geolocation Service - PostGIS
```sql
-- Extensión geoespacial
CREATE EXTENSION IF NOT EXISTS postgis;

-- Tabla de ubicaciones con índices espaciales
CREATE TABLE locations (
  id UUID PRIMARY KEY,
  user_id UUID,
  coordinates GEOMETRY(POINT, 4326),
  address TEXT,
  precision_meters DECIMAL(5,2),
  location_type location_type_enum DEFAULT 'NORMAL',
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de jurisdicciones gubernamentales (JUR-001, JUR-002)
CREATE TABLE government_jurisdictions (
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  government_entity_id UUID NOT NULL,
  jurisdiction_polygon GEOMETRY(POLYGON, 4326) NOT NULL,
  jurisdiction_type jurisdiction_type_enum DEFAULT 'MUNICIPAL',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de zonas especiales (JUR-020, JUR-021)
CREATE TABLE special_zones (
  id UUID PRIMARY KEY,
  zone_type special_zone_type_enum NOT NULL, -- 'CARRETERA_NACIONAL', 'ZONA_PROTEGIDA'
  zone_polygon GEOMETRY(POLYGON, 4326) NOT NULL,
  zone_name VARCHAR(255),
  requires_environmental_auth BOOLEAN DEFAULT FALSE, -- Para zonas protegidas
  environmental_entity VARCHAR(255), -- SINAC (Costa Rica), SEMARNAT (México), etc.
  metadata JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de búsquedas de proximidad con caché
CREATE TABLE proximity_searches (
  id UUID PRIMARY KEY,
  search_type proximity_search_type_enum, -- 'AUXILIARES', 'RESCATISTAS', 'VETERINARIOS'
  center_point GEOMETRY(POINT, 4326),
  radius_km INTEGER,
  search_criteria JSONB,
  results JSONB,
  cached_until TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Índices espaciales optimizados
CREATE INDEX idx_locations_geom ON locations USING GIST (coordinates);
CREATE INDEX idx_jurisdictions_polygon ON government_jurisdictions USING GIST (jurisdiction_polygon);
CREATE INDEX idx_special_zones_polygon ON special_zones USING GIST (zone_polygon);
CREATE INDEX idx_proximity_searches_point ON proximity_searches USING GIST (center_point);

-- Función para búsqueda escalonada de auxiliares (GEO-001 a GEO-004)
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
  max_radius INTEGER := 100; -- GEO-004: Máximo 100km
BEGIN
  -- GEO-001: Radio inicial 10km
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
  
  -- Si no hay resultados, la expansión se maneja en el servicio con timers
END;
$$ LANGUAGE plpgsql;

-- Función para búsqueda de rescatistas (GEO-010 a GEO-012)
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
    AND get_casa_cuna_available_capacity(l.user_id) > 0 -- GEO-011: Priorizar disponibilidad
  ORDER BY priority_score DESC, distance_km ASC;
END;
$$ LANGUAGE plpgsql;

-- Función para determinar jurisdicción (JUR-011)
CREATE OR REPLACE FUNCTION get_jurisdiction_by_location(
  location_point GEOMETRY(POINT, 4326)
) RETURNS UUID AS $$
DECLARE
  jurisdiction_id UUID;
BEGIN
  -- Buscar jurisdicción que contenga el punto
  SELECT gj.id INTO jurisdiction_id
  FROM government_jurisdictions gj
  WHERE ST_Contains(gj.jurisdiction_polygon, location_point)
    AND gj.is_active = TRUE
  ORDER BY ST_Area(gj.jurisdiction_polygon) ASC -- Priorizar jurisdicción más pequeña
  LIMIT 1;
  
  RETURN jurisdiction_id;
END;
$$ LANGUAGE plpgsql;

-- Función para casos fronterizos (JUR-002, JUR-012)
CREATE OR REPLACE FUNCTION get_overlapping_jurisdictions(
  location_point GEOMETRY(POINT, 4326),
  buffer_meters INTEGER DEFAULT 100
) RETURNS TABLE (jurisdiction_id UUID, jurisdiction_name VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT gj.id, gj.name
  FROM government_jurisdictions gj
  WHERE ST_Intersects(gj.jurisdiction_polygon, ST_Buffer(location_point, buffer_meters))
    AND gj.is_active = TRUE;
END;
$$ LANGUAGE plpgsql;

-- Tabla de países y sus configuraciones regulatorias
CREATE TABLE countries (
  id UUID PRIMARY KEY,
  country_code VARCHAR(3) NOT NULL UNIQUE, -- ISO 3166-1 alpha-3 (CRI, MEX, COL, ARG)
  country_name VARCHAR(100) NOT NULL,
  default_currency_code VARCHAR(3) NOT NULL, -- CRC, MXN, COP, ARS
  date_format VARCHAR(20) DEFAULT 'DD/MM/YYYY',
  language_code VARCHAR(5) DEFAULT 'es',
  timezone VARCHAR(50),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de entidades reguladoras por país
CREATE TABLE regulatory_entities (
  id UUID PRIMARY KEY,
  country_id UUID REFERENCES countries(id),
  entity_type regulatory_entity_type_enum NOT NULL, -- 'ENVIRONMENTAL', 'FINANCIAL', 'ANIMAL_WELFARE'
  entity_name VARCHAR(100) NOT NULL, -- SINAC, SEMARNAT, SUGEF, CNBV, etc.
  entity_code VARCHAR(20) NOT NULL,
  entity_description TEXT,
  contact_info JSONB, -- emails, phones, websites
  authorization_required BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(country_id, entity_type, entity_code)
);

-- Enum para tipos de entidades reguladoras
CREATE TYPE regulatory_entity_type_enum AS ENUM (
  'ENVIRONMENTAL',    -- Entidades ambientales (SINAC, SEMARNAT, ANLA, COFEMA)
  'FINANCIAL',        -- Reguladores financieros (SUGEF, CNBV, Superfinanciera, BCRA)
  'ANIMAL_WELFARE',   -- Entidades de bienestar animal específicas
  'HEALTH',          -- Ministerios de salud para regulación veterinaria
  'TAXES'            -- Haciendas públicas/Ministerios de Hacienda para donaciones
);

-- Tabla de monedas soportadas
CREATE TABLE currencies (
  id UUID PRIMARY KEY,
  currency_code VARCHAR(3) NOT NULL UNIQUE, -- CRC, MXN, COP, ARS, USD
  currency_name VARCHAR(50) NOT NULL,
  currency_symbol VARCHAR(5) NOT NULL, -- ₡, $, $, $, $
  decimal_places INTEGER DEFAULT 2,
  is_crypto BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de tasas de cambio (para conversiones)
CREATE TABLE exchange_rates (
  id UUID PRIMARY KEY,
  from_currency_code VARCHAR(3) REFERENCES currencies(currency_code),
  to_currency_code VARCHAR(3) REFERENCES currencies(currency_code),
  rate DECIMAL(18,8) NOT NULL,
  rate_date DATE NOT NULL,
  source VARCHAR(50), -- API source (fixer.io, exchangerate-api, etc.)
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(from_currency_code, to_currency_code, rate_date)
);

-- Tabla de configuración de pagos por país
CREATE TABLE country_payment_config (
  id UUID PRIMARY KEY,
  country_id UUID REFERENCES countries(id),
  currency_id UUID REFERENCES currencies(id),
  payment_provider VARCHAR(50) NOT NULL, -- ONVOPay, Stripe, MercadoPago, etc.
  provider_config JSONB NOT NULL, -- API keys, endpoints, etc.
  kyc_threshold_amount DECIMAL(15,2) DEFAULT 1000.00,
  kyc_threshold_currency VARCHAR(3) DEFAULT 'USD',
  max_donation_amount DECIMAL(15,2),
  min_donation_amount DECIMAL(15,2) DEFAULT 1.00,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Insertar datos iniciales para países latinoamericanos
INSERT INTO countries (id, country_code, country_name, default_currency_code, timezone) VALUES
  (gen_random_uuid(), 'CRI', 'Costa Rica', 'CRC', 'America/Costa_Rica'),
  (gen_random_uuid(), 'MEX', 'México', 'MXN', 'America/Mexico_City'),
  (gen_random_uuid(), 'COL', 'Colombia', 'COP', 'America/Bogota'),
  (gen_random_uuid(), 'ARG', 'Argentina', 'ARS', 'America/Argentina/Buenos_Aires');

-- Insertar monedas latinoamericanas
INSERT INTO currencies (id, currency_code, currency_name, currency_symbol) VALUES
  (gen_random_uuid(), 'CRC', 'Colón Costarricense', '₡'),
  (gen_random_uuid(), 'MXN', 'Peso Mexicano', '$'),
  (gen_random_uuid(), 'COP', 'Peso Colombiano', '$'),
  (gen_random_uuid(), 'ARS', 'Peso Argentino', '$'),
  (gen_random_uuid(), 'USD', 'Dólar Estadounidense', '$');

-- Insertar entidades reguladoras por país
INSERT INTO regulatory_entities (id, country_id, entity_type, entity_name, entity_code, entity_description) VALUES
  -- Costa Rica
  (gen_random_uuid(), (SELECT id FROM countries WHERE country_code = 'CRI'), 'ENVIRONMENTAL', 'Sistema Nacional de Áreas de Conservación', 'SINAC', 'Entidad encargada de zonas protegidas en Costa Rica'),
  (gen_random_uuid(), (SELECT id FROM countries WHERE country_code = 'CRI'), 'FINANCIAL', 'Superintendencia General de Entidades Financieras', 'SUGEF', 'Regulador financiero de Costa Rica'),
  
  -- México
  (gen_random_uuid(), (SELECT id FROM countries WHERE country_code = 'MEX'), 'ENVIRONMENTAL', 'Secretaría de Medio Ambiente y Recursos Naturales', 'SEMARNAT', 'Secretaría de medio ambiente de México'),
  (gen_random_uuid(), (SELECT id FROM countries WHERE country_code = 'MEX'), 'FINANCIAL', 'Comisión Nacional Bancaria y de Valores', 'CNBV', 'Regulador financiero de México'),
  
  -- Colombia
  (gen_random_uuid(), (SELECT id FROM countries WHERE country_code = 'COL'), 'ENVIRONMENTAL', 'Autoridad Nacional de Licencias Ambientales', 'ANLA', 'Autoridad ambiental de Colombia'),
  (gen_random_uuid(), (SELECT id FROM countries WHERE country_code = 'COL'), 'FINANCIAL', 'Superintendencia Financiera de Colombia', 'SUPERFINANCIERA', 'Regulador financiero de Colombia'),
  
  -- Argentina
  (gen_random_uuid(), (SELECT id FROM countries WHERE country_code = 'ARG'), 'ENVIRONMENTAL', 'Consejo Federal de Medio Ambiente', 'COFEMA', 'Consejo ambiental de Argentina'),
  (gen_random_uuid(), (SELECT id FROM countries WHERE country_code = 'ARG'), 'FINANCIAL', 'Banco Central de la República Argentina', 'BCRA', 'Banco central y regulador financiero de Argentina'),
  
  -- Entidades de Hacienda Pública (para regulación fiscal de donaciones)
  (gen_random_uuid(), (SELECT id FROM countries WHERE country_code = 'CRI'), 'TAXES', 'Ministerio de Hacienda de Costa Rica', 'HACIENDA_CR', 'Regulación fiscal y tributaria de donaciones'),
  (gen_random_uuid(), (SELECT id FROM countries WHERE country_code = 'MEX'), 'TAXES', 'Secretaría de Hacienda y Crédito Público', 'SHCP', 'Regulación fiscal de México'),
  (gen_random_uuid(), (SELECT id FROM countries WHERE country_code = 'COL'), 'TAXES', 'Ministerio de Hacienda y Crédito Público', 'MINHACIENDA', 'Regulación fiscal de Colombia'),
  (gen_random_uuid(), (SELECT id FROM countries WHERE country_code = 'ARG'), 'TAXES', 'Ministerio de Economía - AFIP', 'AFIP', 'Administración Federal de Ingresos Públicos de Argentina');

-- Función para obtener entidad reguladora por país y tipo
CREATE OR REPLACE FUNCTION get_regulatory_entity_by_country(
  country_code_param VARCHAR(3),
  entity_type_param regulatory_entity_type_enum
) RETURNS TABLE (
  entity_id UUID,
  entity_name VARCHAR,
  entity_code VARCHAR,
  authorization_required BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    re.id,
    re.entity_name,
    re.entity_code,
    re.authorization_required
  FROM regulatory_entities re
  JOIN countries c ON c.id = re.country_id
  WHERE c.country_code = country_code_param
    AND re.entity_type = entity_type_param
    AND re.is_active = TRUE
    AND c.is_active = TRUE;
END;
$$ LANGUAGE plpgsql;

-- Función para conversión de monedas
CREATE OR REPLACE FUNCTION convert_currency(
  amount DECIMAL(15,2),
  from_currency VARCHAR(3),
  to_currency VARCHAR(3),
  conversion_date DATE DEFAULT CURRENT_DATE
) RETURNS DECIMAL(15,2) AS $$
DECLARE
  exchange_rate DECIMAL(18,8);
  converted_amount DECIMAL(15,2);
BEGIN
  -- Si las monedas son iguales, no hay conversión
  IF from_currency = to_currency THEN
    RETURN amount;
  END IF;
  
  -- Buscar tasa de cambio más reciente
  SELECT rate INTO exchange_rate
  FROM exchange_rates
  WHERE from_currency_code = from_currency
    AND to_currency_code = to_currency
    AND rate_date <= conversion_date
  ORDER BY rate_date DESC
  LIMIT 1;
  
  -- Si no hay tasa directa, intentar conversión vía USD
  IF exchange_rate IS NULL THEN
    -- Convertir a USD primero, luego a moneda destino
    SELECT 
      (SELECT rate FROM exchange_rates 
       WHERE from_currency_code = from_currency AND to_currency_code = 'USD' 
       AND rate_date <= conversion_date ORDER BY rate_date DESC LIMIT 1) *
      (SELECT rate FROM exchange_rates 
       WHERE from_currency_code = 'USD' AND to_currency_code = to_currency 
       AND rate_date <= conversion_date ORDER BY rate_date DESC LIMIT 1)
    INTO exchange_rate;
  END IF;
  
  -- Si aún no hay tasa, usar 1:1 (fallback)
  IF exchange_rate IS NULL THEN
    exchange_rate := 1.0;
  END IF;
  
  converted_amount := amount * exchange_rate;
  RETURN ROUND(converted_amount, 2);
END;
$$ LANGUAGE plpgsql;

-- Función para validar casos especiales con entidades por país
-- NOTA: No se incluye validación de propiedades privadas porque según las leyes de maltrato animal
-- de países latinoamericanos, los auxiliares y rescatistas tienen derecho legal a actuar en 
-- propiedades privadas para rescatar animales maltratados, con escolta policial si es necesario
CREATE OR REPLACE FUNCTION check_special_zone_requirements(
  location_point GEOMETRY(POINT, 4326),
  country_code_param VARCHAR(3)
) RETURNS TABLE (
  zone_type special_zone_type_enum,
  requires_owner_auth BOOLEAN,
  requires_environmental_auth BOOLEAN,
  environmental_entity_name VARCHAR,
  environmental_entity_code VARCHAR,
  owner_id UUID
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    sz.zone_type,
    FALSE, -- No se requiere autorización de propietario (omitido por ley de maltrato animal)
    sz.requires_environmental_auth,
    re.entity_name,
    re.entity_code,
    NULL -- owner_id removido
  FROM special_zones sz
  LEFT JOIN countries c ON c.country_code = country_code_param
  LEFT JOIN regulatory_entities re ON re.country_id = c.id 
    AND re.entity_type = 'ENVIRONMENTAL' 
    AND re.is_active = TRUE
  WHERE ST_Contains(sz.zone_polygon, location_point)
  ORDER BY 
    CASE sz.zone_type 
      WHEN 'ZONA_PROTEGIDA' THEN 1
      WHEN 'CARRETERA_NACIONAL' THEN 2
      ELSE 3
    END;
END;
$$ LANGUAGE plpgsql;
```

#### Notification Service - MongoDB
```javascript
// Colección de mensajes de chat
{
  _id: ObjectId,
  conversationId: UUID,
  senderId: UUID,
  message: String,
  messageType: "text" | "image" | "location",
  timestamp: Date,
  deliveryStatus: "sent" | "delivered" | "read"
}

// Colección de notificaciones
{
  _id: ObjectId,
  userId: UUID,
  type: String,
  title: String,
  body: String,
  data: Object,
  sent: Boolean,
  timestamp: Date
}
```

#### Analytics Service - ClickHouse
```sql
-- Tabla optimizada para analytics
CREATE TABLE events (
  timestamp DateTime,
  event_type String,
  user_id String,
  service_name String,
  event_data String,
  metadata Map(String, String)
) ENGINE = MergeTree()
ORDER BY (timestamp, event_type);
```

## Patrones de Resiliencia y Manejo de Errores

### Patrones de Resiliencia Implementados

#### Circuit Breaker Pattern
```yaml
# Configuración por microservicio
services:
  financial-service:
    circuit-breaker:
      failure-threshold: 5
      timeout: 30s
      recovery-timeout: 60s
  
  geolocation-service:
    circuit-breaker:
      failure-threshold: 3
      timeout: 10s
      recovery-timeout: 30s
```

#### Retry Pattern con Backoff Exponencial
- **Errores de Red**: Retry automático con backoff exponencial
- **Errores de Pago**: Máximo 3 reintentos con escalación manual
- **Errores de Geolocalización**: Fallback a selección manual

#### Saga Pattern para Transacciones Distribuidas
```yaml
# Ejemplo: Proceso de donación
donation-saga:
  steps:
    1. validate-user (User Management Service)
    2. process-payment (Financial Service)
    3. update-casa-cuna (Animal Rescue Service)
    4. send-notification (Notification Service)
  
  compensations:
    4. cancel-notification
    3. revert-casa-cuna-update
    2. refund-payment
    1. log-validation-failure
```

### Observabilidad y Monitoreo

#### Structured Logging (12-Factor App)
```yaml
# Configuración de logging por microservicio
logging:
  level: INFO
  format: json
  output: stdout  # Para agregación por Kubernetes
  
  fields:
    service: ${SERVICE_NAME}
    version: ${SERVICE_VERSION}
    trace_id: ${TRACE_ID}
    span_id: ${SPAN_ID}
```

#### Métricas (Prometheus)
- **Application Metrics**: Latencia, throughput, tasas de error
- **Business Metrics**: Rescates completados, donaciones procesadas
- **Infrastructure Metrics**: CPU, memoria, red por pod

#### Trazas Distribuidas (Jaeger)
- **Request Tracing**: Seguimiento de requests a través de microservicios
- **Performance Analysis**: Identificación de cuellos de botella
- **Error Correlation**: Correlación de errores entre servicios

#### Health Checks
```yaml
# Health check estándar por microservicio
/health:
  liveness: /health/live    # Para Kubernetes liveness probe
  readiness: /health/ready  # Para Kubernetes readiness probe
  
  checks:
    - database-connection
    - external-service-connectivity
    - memory-usage
    - disk-space
```

## Estrategia de Testing para Microservicios

### Testing por Capas

#### Frontend (Flutter)
- **Unit Tests**: Lógica de negocio y validaciones básicas
- **Widget Tests**: Componentes de UI individuales
- **Integration Tests**: Flujos completos de usuario
- **Golden Tests**: Consistencia visual de interfaces

#### Microservicios (Backend)

##### Service Component Tests
```yaml
# Testing de cada microservicio de forma aislada
user-management-service:
  tests:
    - unit: domain logic, RBAC validation
    - integration: PostgreSQL, JWT generation
    - contract: API schema validation
    
financial-service:
  tests:
    - unit: payment processing, KYC validation
    - integration: ONVOPay adapter, Event Sourcing
    - security: PCI DSS compliance, encryption
```

##### Service Integration Contract Tests
```yaml
# Validación de contratos entre servicios
contracts:
  user-management -> animal-rescue:
    - user authentication tokens
    - role validation responses
    
  financial -> notification:
    - payment completion events
    - donation confirmation data
```

##### End-to-End Tests
- **Cross-Service Workflows**: Flujos completos de rescate
- **Saga Testing**: Validación de transacciones distribuidas
- **Event Flow Testing**: Propagación correcta de eventos

### Testing de Infraestructura

#### Kubernetes Testing
- **Helm Chart Testing**: Validación de manifiestos
- **Pod Startup Testing**: Health checks y readiness probes
- **Service Discovery Testing**: Comunicación entre pods

#### Performance Testing
- **Load Testing**: Capacidad bajo carga con K6/JMeter
- **Stress Testing**: Límites de cada microservicio
- **Chaos Engineering**: Resiliencia con Chaos Monkey

### Testing de Reglas de Negocio

#### Testing de Reglas de Adoptabilidad
```typescript
// Tests para reglas BR-050 y BR-051
describe('Animal Adoptability Rules', () => {
  
  test('BR-050: Animal debe cumplir TODOS los requisitos', () => {
    const animal = createAnimal({
      requirements: { usaArenero: true, comePorSiMismo: true },
      restrictions: { /* todos false */ }
    });
    
    expect(businessRulesEngine.validateAdoptability(animal).isAdoptable).toBe(true);
  });
  
  test('BR-051: CUALQUIER restricción impide adopción', () => {
    const animal = createAnimal({
      requirements: { usaArenero: true, comePorSiMismo: true },
      restrictions: { lactante: true } // Una sola restricción
    });
    
    expect(businessRulesEngine.validateAdoptability(animal).isAdoptable).toBe(false);
  });
  
  test('BR-081: Conflicto entre comer solo y ser lactante', () => {
    expect(() => {
      createAnimal({
        requirements: { comePorSiMismo: true },
        restrictions: { lactante: true }
      });
    }).toThrow('CONFLICT_EATING_LACTATING');
  });
  
  test('BR-082: Recién nacido automáticamente es lactante', () => {
    const animal = createAnimal({
      restrictions: { recienNacido: true, lactante: false }
    });
    
    expect(animal.restrictions.lactante).toBe(true);
  });
});
```

#### Testing de Estados de Workflow
```typescript
// Tests para reglas WF-001 a WF-042
describe('Workflow State Machine', () => {
  
  test('WF-040: Auxilio completado crea automáticamente solicitud de rescate', async () => {
    const auxilio = await createSolicitudAuxilio();
    await workflowStateMachine.transition(auxilio.id, 'COMPLETADA');
    
    const rescateCreado = await findSolicitudRescateByAuxilio(auxilio.id);
    expect(rescateCreado).toBeDefined();
    expect(rescateCreado.status).toBe('CREADA');
  });
  
  test('WF-041: Actualización de atributos evalúa adoptabilidad automáticamente', async () => {
    const animal = await createAnimal({ state: 'EN_CUIDADO' });
    
    await updateAnimalAttributes(animal.id, {
      requirements: { usaArenero: true, comePorSiMismo: true },
      restrictions: { /* todos false */ }
    });
    
    const updatedAnimal = await getAnimal(animal.id);
    expect(updatedAnimal.state).toBe('ADOPTABLE');
  });
});
```

#### Testing de Geolocalización
```typescript
// Tests para reglas GEO-001 a GEO-022
describe('Geolocation Rules', () => {
  
  test('GEO-001: Búsqueda inicial de auxiliares en radio de 10km', async () => {
    const solicitud = createSolicitudAuxilio({ ubicacion: CENTRO_SAN_JOSE });
    const auxiliares = await proximitySearchEngine.findAuxiliares(solicitud);
    
    auxiliares.forEach(auxiliar => {
      const distance = calculateDistance(auxiliar.ubicacion, CENTRO_SAN_JOSE);
      expect(distance).toBeLessThanOrEqual(10000); // 10km en metros
    });
  });
  
  test('GEO-002: Expansión automática a 25km después de 30 minutos', async () => {
    const solicitud = createSolicitudAuxilio({ ubicacion: ZONA_RURAL });
    
    // Simular que no hay auxiliares en 10km
    jest.spyOn(proximitySearchEngine, 'searchInRadius')
      .mockResolvedValueOnce([]) // Primera búsqueda vacía
      .mockResolvedValueOnce([mockAuxiliar]); // Segunda búsqueda con resultado
    
    await proximitySearchEngine.findAuxiliares(solicitud);
    
    // Avanzar tiempo 30 minutos
    jest.advanceTimersByTime(30 * 60 * 1000);
    
    expect(proximitySearchEngine.searchInRadius).toHaveBeenCalledWith(
      ZONA_RURAL, 25 // Radio expandido a 25km
    );
  });
});
```

#### Testing de Jurisdicciones
```typescript
// Tests para reglas JUR-001 a JUR-022
describe('Jurisdiction Validation', () => {
  
  test('JUR-010: Solo encargados de jurisdicción pueden autorizar', async () => {
    const solicitud = createSolicitudRescate({ ubicacion: SAN_JOSE_CENTRO });
    const encargadoSanJose = createEncargado({ jurisdiccion: 'SAN_JOSE' });
    const encargadoCartago = createEncargado({ jurisdiccion: 'CARTAGO' });
    
    const resultSanJose = await jurisdictionValidator.validateVeterinaryAuthorization(
      solicitud, encargadoSanJose
    );
    const resultCartago = await jurisdictionValidator.validateVeterinaryAuthorization(
      solicitud, encargadoCartago
    );
    
    expect(resultSanJose.authorized).toBe(true);
    expect(resultCartago.authorized).toBe(false);
  });
  
  test('JUR-012: Zona fronteriza requiere autorización múltiple', async () => {
    const solicitud = createSolicitudRescate({ ubicacion: FRONTERA_SAN_JOSE_CARTAGO });
    
    const result = await jurisdictionValidator.validateVeterinaryAuthorization(
      solicitud, mockEncargado
    );
    
    expect(result.requiresMultipleAuthorizations).toBe(true);
    expect(result.jurisdictions).toHaveLength(2);
  });
});
```

### Testing de Cumplimiento y Seguridad

#### PCI DSS Testing
- **Quarterly Scans**: Escaneos de vulnerabilidades automatizados
- **Penetration Testing**: Testing anual de penetración
- **Token Validation**: Verificación de tokenización correcta

#### KYC/AML Testing
- **Regulatory Compliance**: Validación de procesos KYC
- **ML Model Testing**: Precisión de detección de anomalías
- **Audit Trail Testing**: Trazabilidad completa de transacciones

## Seguridad Cloud-Native

### Seguridad por Capas (Defense in Depth)

#### Seguridad de Infraestructura (Kubernetes)
```yaml
# Network Policies para aislamiento de microservicios
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: financial-service-policy
spec:
  podSelector:
    matchLabels:
      app: financial-service
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: api-gateway
    ports:
    - protocol: TCP
      port: 8080
```

#### Secrets Management
```yaml
# Kubernetes Secrets para datos sensibles
apiVersion: v1
kind: Secret
metadata:
  name: financial-service-secrets
type: Opaque
data:
  database-password: <base64-encoded>
  onvopay-api-key: <base64-encoded>
  jwt-secret: <base64-encoded>
```

#### Service Mesh Security (Istio)
- **mTLS**: Comunicación encriptada automática entre servicios
- **Authorization Policies**: Control de acceso granular
- **Security Policies**: Validación de certificados y tokens

### Seguridad de Datos

#### Encriptación Multi-Nivel
- **En Tránsito**: TLS 1.3 para todas las comunicaciones
- **En Reposo**: AES-256 para bases de datos
- **En Memoria**: Encriptación de datos sensibles en caché
- **Punto a Punto**: Para datos PII y financieros

#### Data Classification
```yaml
# Clasificación de datos por sensibilidad
data-classification:
  public:
    - animal photos
    - rescue statistics
  
  internal:
    - user profiles
    - rescue requests
  
  confidential:
    - financial transactions
    - medical records
  
  restricted:
    - payment tokens
    - kyc documents
```

### Autenticación y Autorización Distribuida

#### OAuth 2.0 / OpenID Connect
```yaml
# Configuración de autenticación
auth:
  provider: keycloak  # Identity Provider
  flows:
    - authorization_code  # Para frontend
    - client_credentials  # Para service-to-service
  
  token-validation:
    - signature-verification
    - expiration-check
    - scope-validation
```

#### RBAC Distribuido
- **JWT Claims**: Roles y permisos en tokens
- **Service-Level Authorization**: Cada microservicio valida permisos
- **Fine-Grained Permissions**: Permisos específicos por recurso

### Cumplimiento PCI DSS en Microservicios

#### Scope Reduction
```yaml
# Solo Financial Service en scope PCI DSS
pci-scope:
  in-scope:
    - financial-service
    - api-gateway (payment endpoints)
  
  out-of-scope:
    - user-management-service
    - animal-rescue-service
    - notification-service
```

#### Tokenization Strategy
- **Payment Tokens**: Almacenamiento seguro de referencias
- **Vault Integration**: HashiCorp Vault para secrets
- **Token Rotation**: Rotación automática de tokens

## Integraciones Externas y Backing Services

### Patrón Adapter para Integraciones

#### Financial Service Integrations
```yaml
# Adapter pattern para múltiples pasarelas
payment-adapters:
  onvopay:
    adapter: ONVOPayAdapter
    config: ${ONVOPAY_CONFIG}
    fallback: stripe
  
  stripe:
    adapter: StripeAdapter
    config: ${STRIPE_CONFIG}
    fallback: manual-transfer
  
  sinpe:
    adapter: SINPEAdapter
    config: ${SINPE_CONFIG}
    region: costa-rica
```

#### Geolocation Service Integrations
```yaml
# Multiple map providers con fallback
map-providers:
  primary: google-maps
  fallback: openstreetmap
  
  google-maps:
    api-key: ${GOOGLE_MAPS_API_KEY}
    rate-limit: 1000/day
  
  openstreetmap:
    endpoint: ${OSM_ENDPOINT}
    rate-limit: unlimited
```

### Backing Services (12-Factor App)

#### Message Brokers
```yaml
# Apache Kafka para eventos
kafka:
  brokers: ${KAFKA_BROKERS}
  topics:
    - user-events
    - rescue-events
    - financial-events
    - notification-events
  
  consumer-groups:
    - notification-service-group
    - analytics-service-group
```

#### External APIs
```yaml
# Servicios externos como recursos adjuntos
external-services:
  firebase-messaging:
    url: ${FCM_URL}
    credentials: ${FCM_CREDENTIALS}
  
  kyc-provider:
    url: ${KYC_API_URL}
    api-key: ${KYC_API_KEY}
  
  sanctions-list:
    url: ${SANCTIONS_API_URL}
    refresh-interval: 24h
```

### Service Discovery y Load Balancing

#### Kubernetes Service Discovery
```yaml
# Servicios internos descubiertos automáticamente
apiVersion: v1
kind: Service
metadata:
  name: user-management-service
spec:
  selector:
    app: user-management
  ports:
  - port: 8080
    targetPort: 8080
  type: ClusterIP
```

#### External Service Configuration
```yaml
# ConfigMaps para configuración externa
apiVersion: v1
kind: ConfigMap
metadata:
  name: external-services-config
data:
  google-maps-url: "https://maps.googleapis.com/maps/api"
  firebase-url: "https://fcm.googleapis.com/fcm"
  onvopay-url: "https://api.onvopay.com"
```

## Performance y Escalabilidad Cloud-Native

### Escalabilidad Horizontal (Kubernetes)

#### Horizontal Pod Autoscaler (HPA)
```yaml
# Auto-escalado basado en métricas
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: financial-service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: financial-service
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

#### Vertical Pod Autoscaler (VPA)
```yaml
# Optimización automática de recursos
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: user-management-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: user-management-service
  updatePolicy:
    updateMode: "Auto"
```

### Optimizaciones por Microservicio

#### Caching Distribuido (Redis)
```yaml
# Configuración de caché por servicio
caching-strategy:
  user-management:
    - user-sessions: TTL 30m
    - role-permissions: TTL 1h
  
  geolocation:
    - proximity-queries: TTL 5m
    - route-calculations: TTL 15m
  
  reputation:
    - user-scores: TTL 10m
    - rating-aggregates: TTL 1h
```

#### Database Optimization
```sql
-- Índices optimizados por microservicio
-- User Management Service
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
CREATE INDEX CONCURRENTLY idx_user_roles_user_id ON user_roles(user_id);

-- Geolocation Service
CREATE INDEX CONCURRENTLY idx_locations_geom ON locations USING GIST (coordinates);
CREATE INDEX CONCURRENTLY idx_locations_user_updated ON locations(user_id, updated_at);

-- Financial Service (particionado por fecha)
CREATE TABLE financial_transactions_2024 PARTITION OF financial_transactions
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
```

### Performance Monitoring

#### Application Performance Monitoring (APM)
```yaml
# Métricas de performance por servicio
metrics:
  latency:
    - p50, p95, p99 response times
    - database query times
    - external API call times
  
  throughput:
    - requests per second
    - transactions per minute
    - events processed per hour
  
  errors:
    - error rates by endpoint
    - failed transaction rates
    - circuit breaker activations
```

#### Resource Optimization
```yaml
# Límites de recursos por microservicio
resources:
  user-management:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 512Mi
  
  financial-service:
    requests:
      cpu: 200m
      memory: 256Mi
    limits:
      cpu: 1000m
      memory: 1Gi
```

## Alineación con AWS Well-Architected Framework

### Pilar de Optimización de Costos

#### Estrategia de Right-Sizing y Auto-Scaling
```yaml
# Configuración optimizada por microservicio según patrones de uso
cost-optimization:
  
  # Servicios de alta demanda con auto-scaling agresivo
  high-demand-services:
    - animal-rescue-service:
        min-replicas: 2
        max-replicas: 20
        target-cpu: 60%
        scale-down-delay: 300s
        instance-type: "t3.medium"
    
    - notification-service:
        min-replicas: 3
        max-replicas: 50
        target-cpu: 70%
        scale-down-delay: 180s
        instance-type: "t3.small"
  
  # Servicios de demanda moderada
  moderate-demand-services:
    - user-management-service:
        min-replicas: 2
        max-replicas: 10
        target-cpu: 70%
        scale-down-delay: 600s
        instance-type: "t3.small"
    
    - geolocation-service:
        min-replicas: 2
        max-replicas: 15
        target-cpu: 65%
        scale-down-delay: 300s
        instance-type: "t3.medium" # Requiere más CPU para cálculos geoespaciales
  
  # Servicios de baja demanda con Spot Instances
  low-demand-services:
    - analytics-service:
        min-replicas: 1
        max-replicas: 5
        target-cpu: 80%
        scale-down-delay: 900s
        instance-type: "t3.large"
        use-spot-instances: true
        spot-max-price: "0.05"
    
    - reputation-service:
        min-replicas: 1
        max-replicas: 3
        target-cpu: 75%
        scale-down-delay: 600s
        instance-type: "t3.small"
        use-spot-instances: true
```

#### Estrategia de Almacenamiento por Niveles
```yaml
# Optimización de costos de almacenamiento
storage-optimization:
  
  # Datos transaccionales críticos (SSD de alta performance)
  tier-1-hot:
    services: [financial-service, user-management-service]
    storage-class: "gp3"
    iops: 3000
    retention: "7-years" # Cumplimiento regulatorio
    backup-frequency: "6-hours"
  
  # Datos operacionales frecuentes (SSD estándar)
  tier-2-warm:
    services: [animal-rescue-service, geolocation-service, notification-service]
    storage-class: "gp3"
    iops: 1000
    retention: "2-years"
    backup-frequency: "12-hours"
  
  # Datos analíticos y reportes (almacenamiento optimizado)
  tier-3-cold:
    services: [analytics-service, reputation-service]
    storage-class: "st1" # Throughput optimized HDD
    retention: "5-years"
    backup-frequency: "24-hours"
    
  # Archivos multimedia con lifecycle policies
  media-storage:
    type: "S3"
    classes:
      - frequent-access: "S3 Standard" # Primeros 30 días
      - infrequent-access: "S3 IA" # 30-90 días
      - archive: "S3 Glacier" # 90+ días
      - deep-archive: "S3 Glacier Deep Archive" # 1+ año
```

#### Optimización de Bases de Datos
```yaml
# Estrategia de bases de datos por costo-beneficio
database-optimization:
  
  # Bases de datos críticas con Multi-AZ
  production-critical:
    - financial-service-db:
        engine: "PostgreSQL"
        instance-class: "db.r6g.large"
        multi-az: true
        read-replicas: 2
        backup-retention: 35 # Máximo para cumplimiento
        
    - user-management-db:
        engine: "PostgreSQL" 
        instance-class: "db.t4g.medium"
        multi-az: true
        read-replicas: 1
        backup-retention: 7
  
  # Bases de datos operacionales con Single-AZ
  production-standard:
    - animal-rescue-db:
        engine: "PostgreSQL"
        instance-class: "db.t4g.medium"
        multi-az: false
        read-replicas: 1
        backup-retention: 7
        
    - geolocation-db:
        engine: "PostgreSQL + PostGIS"
        instance-class: "db.r6g.medium" # Optimizado para consultas geoespaciales
        multi-az: false
        read-replicas: 2 # Muchas consultas de lectura
        backup-retention: 7
  
  # Bases de datos analíticas con Reserved Instances
  analytics-optimized:
    - analytics-db:
        engine: "ClickHouse on EC2"
        instance-class: "r6i.xlarge"
        reserved-instance: "3-year-all-upfront"
        storage-type: "gp3"
        backup-retention: 30
```

#### Estrategia de Reserved Instances y Savings Plans
```yaml
# Planificación de costos a largo plazo
cost-planning:
  
  # Reserved Instances para cargas predecibles
  reserved-instances:
    - compute:
        percentage: 60% # 60% de la capacidad base
        term: "1-year-partial-upfront"
        instance-families: ["t3", "r6g", "m6i"]
    
    - databases:
        percentage: 80% # Bases de datos más predecibles
        term: "3-year-all-upfront" # Máximo descuento
        engines: ["PostgreSQL", "Redis"]
  
  # Savings Plans para flexibilidad
  savings-plans:
    - compute-savings-plan:
        commitment: "$500/month"
        term: "1-year"
        payment: "partial-upfront"
        
  # Spot Instances para cargas tolerantes a interrupciones
  spot-instances:
    - analytics-workloads: 70% # Procesamiento de datos no crítico
    - batch-processing: 90% # Jobs de procesamiento nocturno
    - development-environments: 100% # Entornos de desarrollo
```

#### Monitoreo y Alertas de Costos
```yaml
# Governance de costos automatizada
cost-monitoring:
  
  # Budgets por servicio
  service-budgets:
    - financial-service: "$2000/month"
    - animal-rescue-service: "$1500/month"
    - notification-service: "$800/month"
    - user-management-service: "$600/month"
    - geolocation-service: "$700/month"
    - analytics-service: "$400/month"
    - reputation-service: "$200/month"
    - government-service: "$300/month"
    - veterinary-service: "$400/month"
  
  # Alertas de anomalías
  cost-anomaly-detection:
    - threshold: 20% # Alerta si el costo aumenta >20%
    - notification: "slack-channel-ops"
    - auto-actions:
        - scale-down-non-critical-services
        - pause-development-environments
  
  # Reportes automáticos
  cost-reports:
    - frequency: "weekly"
    - breakdown: ["service", "environment", "resource-type"]
    - recipients: ["tech-lead", "product-owner", "finance"]
```

### Pilar de Excelencia Operacional

#### Automatización de Operaciones
```yaml
# Reducción de costos operacionales mediante automatización
operational-automation:
  
  # Auto-remediation para reducir intervención manual
  auto-remediation:
    - failed-health-checks:
        action: "restart-pod"
        max-attempts: 3
        escalation: "alert-on-call"
    
    - high-memory-usage:
        threshold: 85%
        action: "scale-up"
        cooldown: "5-minutes"
    
    - database-connection-pool-exhaustion:
        action: "restart-service"
        notification: "immediate"
  
  # Scheduled operations para optimizar recursos
  scheduled-operations:
    - development-environment-shutdown:
        schedule: "0 19 * * 1-5" # Apagar a las 7 PM días laborales
        action: "scale-to-zero"
        
    - analytics-batch-processing:
        schedule: "0 2 * * *" # Ejecutar a las 2 AM
        resources: "spot-instances"
        
    - database-maintenance:
        schedule: "0 3 * * 0" # Domingos a las 3 AM
        action: "automated-maintenance"
```

### Pilar de Confiabilidad con Optimización de Costos

#### Multi-Region Strategy Costo-Efectiva
```yaml
# Estrategia de múltiples regiones optimizada por costos
multi-region-strategy:
  
  # Región primaria (full deployment)
  primary-region:
    region: "us-east-1" # Costos más bajos
    services: "all"
    redundancy: "multi-az"
    
  # Región secundaria (disaster recovery)
  secondary-region:
    region: "us-west-2"
    services: ["financial-service", "user-management-service"] # Solo críticos
    deployment-type: "warm-standby"
    rto: "15-minutes"
    rpo: "5-minutes"
    
  # Cross-region replication optimizada
  replication-strategy:
    - financial-data: "synchronous" # Crítico
    - user-data: "asynchronous-5min" # Importante
    - analytics-data: "daily-batch" # No crítico
```

#### Backup Strategy Optimizada
```yaml
# Estrategia de backups costo-efectiva
backup-optimization:
  
  # Backups por criticidad de datos
  backup-tiers:
    - critical-data:
        services: ["financial-service", "user-management-service"]
        frequency: "continuous"
        retention: "35-days-hot + 7-years-cold"
        storage-class: "S3 IA -> Glacier"
        
    - important-data:
        services: ["animal-rescue-service", "geolocation-service"]
        frequency: "6-hours"
        retention: "7-days-hot + 2-years-cold"
        storage-class: "S3 Standard -> S3 IA"
        
    - operational-data:
        services: ["notification-service", "reputation-service"]
        frequency: "daily"
        retention: "3-days-hot + 90-days-cold"
        storage-class: "S3 IA"
```

### CDN y Edge Computing Optimizado

#### Content Delivery Network Costo-Efectiva
```yaml
# Distribución de contenido optimizada por costos
cdn-strategy:
  
  # Contenido estático con CloudFront
  static-content:
    - animal-photos:
        cdn: "CloudFront"
        origin: "S3"
        cache-ttl: "30-days"
        compression: "gzip + brotli"
        
    - app-assets:
        cdn: "CloudFront"
        origin: "S3"
        cache-ttl: "1-year"
        versioning: "enabled"
  
  # API caching inteligente
  api-caching:
    - public-endpoints:
        cache-ttl: "5-minutes"
        cache-key: "url + query-params"
        
    - user-specific-endpoints:
        cache-ttl: "30-seconds"
        cache-key: "url + user-id"
        
    - geolocation-queries:
        cache-ttl: "2-minutes"
        cache-key: "coordinates + radius"
  
  # Edge computing para reducir latencia y costos
  edge-computing:
    - image-resizing: "Lambda@Edge"
    - geolocation-calculations: "CloudFront Functions"
    - user-authentication: "Lambda@Edge"
```

#### Optimización de Transferencia de Datos
```yaml
# Reducción de costos de transferencia de datos
data-transfer-optimization:
  
  # Compresión y optimización
  compression:
    - api-responses: "gzip"
    - images: "webp + progressive-jpeg"
    - videos: "h264 + adaptive-bitrate"
  
  # Estrategia de regiones
  region-strategy:
    - primary-traffic: "same-region-routing"
    - cross-region-traffic: "minimize"
    - cdn-offloading: "80%" # Reducir tráfico al origen
  
  # Batch processing para reducir API calls
  batch-optimization:
    - notification-delivery: "batch-size-100"
    - analytics-events: "batch-size-1000"
    - geolocation-updates: "batch-size-50"

### Pilar de Seguridad con Optimización de Costos

#### Seguridad Automatizada y Costo-Efectiva
```yaml
# Seguridad que reduce costos operacionales
security-automation:
  
  # WAF con reglas inteligentes
  web-application-firewall:
    - managed-rules: "AWS-AWSManagedRulesCommonRuleSet"
    - rate-limiting: "1000-requests-per-5min-per-ip"
    - geo-blocking: "block-non-latam" # Reducir tráfico malicioso
    - cost-optimization: "pay-per-request" # Solo pagar por uso real
  
  # Secrets management centralizado
  secrets-management:
    - service: "AWS Secrets Manager"
    - rotation: "automatic-90-days"
    - cross-service-sharing: "enabled" # Reducir duplicación
    - cost-optimization: "pay-per-secret-per-month"
  
  # Security scanning automatizado
  automated-security:
    - vulnerability-scanning: "AWS Inspector"
    - code-analysis: "CodeGuru Security"
    - compliance-monitoring: "AWS Config"
    - cost-benefit: "prevent-security-incidents"
```

### Pilar de Performance con Optimización de Costos

#### Performance Monitoring Costo-Efectivo
```yaml
# Monitoreo de performance optimizado
performance-monitoring:
  
  # Métricas esenciales vs nice-to-have
  essential-metrics:
    - application-latency: "p50, p95, p99"
    - error-rates: "4xx, 5xx by service"
    - throughput: "requests-per-second"
    - business-metrics: "rescues-completed, donations-processed"
    
  # Sampling para reducir costos de observabilidad
  sampling-strategy:
    - traces: "1% sampling for normal traffic, 100% for errors"
    - logs: "ERROR and WARN always, INFO sampled at 10%"
    - metrics: "1-minute resolution for dashboards, 5-minute for alerts"
  
  # Retention policies optimizadas
  retention-optimization:
    - hot-data: "7-days" # Dashboards y alertas
    - warm-data: "30-days" # Análisis y debugging
    - cold-data: "1-year" # Compliance y análisis histórico
```

### Pilar de Sostenibilidad

#### Optimización de Huella de Carbono y Costos
```yaml
# Sostenibilidad que reduce costos
sustainability-optimization:
  
  # Regiones con energía renovable
  green-regions:
    - primary: "us-west-2" # 95% energía renovable
    - secondary: "eu-west-1" # 89% energía renovable
    - avoid: "ap-southeast-2" # Mayor huella de carbono
  
  # Optimización de instancias
  efficient-instances:
    - graviton-processors: "40% mejor performance por watt"
    - right-sizing: "automated-recommendations"
    - spot-instances: "utilizar capacidad ociosa"
  
  # Lifecycle management
  resource-lifecycle:
    - auto-shutdown: "development-environments-after-hours"
    - resource-tagging: "environment, owner, auto-delete-date"
    - unused-resource-detection: "weekly-cleanup-jobs"
```

### Arquitectura de Costos por Microservicio

#### Estimación de Costos Mensuales (USD)
```yaml
# Proyección de costos por servicio en producción
monthly-cost-projection:
  
  # Servicios de alto costo (críticos)
  high-cost-services:
    - financial-service: 
        compute: "$800"
        database: "$600" 
        storage: "$200"
        networking: "$100"
        total: "$1,700"
        
    - animal-rescue-service:
        compute: "$600"
        database: "$400"
        storage: "$150"
        networking: "$80"
        total: "$1,230"
  
  # Servicios de costo medio
  medium-cost-services:
    - notification-service:
        compute: "$400"
        database: "$200" # MongoDB Atlas
        storage: "$50"
        networking: "$60"
        external-apis: "$100" # Firebase
        total: "$810"
        
    - geolocation-service:
        compute: "$350"
        database: "$300" # PostGIS requiere más recursos
        storage: "$80"
        networking: "$50"
        external-apis: "$80" # Google Maps
        total: "$860"
  
  # Servicios de bajo costo
  low-cost-services:
    - user-management-service: "$450"
    - veterinary-service: "$320"
    - reputation-service: "$180"
    - government-service: "$250"
    - analytics-service: "$380" # Spot instances
  
  # Costos compartidos
  shared-infrastructure:
    - api-gateway: "$200"
    - load-balancers: "$150"
    - monitoring: "$300"
    - security: "$180"
    - backups: "$250"
    - cdn: "$120"
    - total-shared: "$1,200"
  
  # Total estimado mensual
  total-monthly-cost: "$8,560"
  
  # Estrategias de reducción de costos
  cost-reduction-strategies:
    - reserved-instances: "-25% ($2,140 savings)"
    - spot-instances: "-15% ($1,284 savings)"
    - right-sizing: "-10% ($856 savings)"
    - storage-optimization: "-20% on storage ($96 savings)"
    - optimized-total: "$6,184/month"
```

### ROI y Justificación de Costos

#### Análisis Costo-Beneficio
```yaml
# Justificación económica del sistema
cost-benefit-analysis:
  
  # Costos anuales proyectados
  annual-costs:
    - infrastructure: "$74,208" # $6,184 * 12
    - development: "$240,000" # 3 desarrolladores full-time
    - operations: "$120,000" # 1 DevOps + 1 SRE
    - compliance: "$50,000" # PCI DSS, auditorías
    - total-annual: "$484,208"
  
  # Beneficios cuantificables
  annual-benefits:
    - donation-processing-efficiency: "$200,000"
    - reduced-manual-coordination: "$150,000"
    - improved-rescue-response-time: "$300,000"
    - transparency-compliance-savings: "$100,000"
    - total-annual-benefits: "$750,000"
  
  # ROI calculation
  roi-metrics:
    - net-benefit: "$265,792" # Benefits - Costs
    - roi-percentage: "55%" # (Benefits - Costs) / Costs
    - payback-period: "18-months"
    - break-even-point: "Month 8"
```
```
---


## Anexo: Flujo Break-Glass, RBAC y Controles

### 1. Flujo de Secuencia Break-Glass (resumen)

1) Solicitud (SRE/Auditor): identidad, caso, motivo, alcance, TTL.
2) Aprobación independiente (doble control): según tipo de datos.
3) Emisión de credenciales temporales (scope mínimo, TTL, no renovables).
4) Acceso controlado: solo lectura/enmascarado, límites de volumen, detección de anomalías.
5) Auto-revocación al expirar TTL o cierre manual.
6) Informe de auditoría: eventos, consultas, exportaciones, hashes, sellos de tiempo.

### 2. RBAC y Scopes

- Roles: SRE (solo lectura global agregada), Auditor Gubernamental/Ambiental (jurisdicción), Administrador Gubernamental (tenant), Data Owner, Compliance/DPO, PCI Officer.
- Scopes: `platform:metrics:read`, `central:pii:masked:read`, `finance:tokenized:read`, `tenant:{id}:gov:read`, `env:{authority}:read`.
- Elevación break-glass añade scopes temporales aprobados.

### 3. Enmascarado/Tokenización de PII

- Vistas enmascaradas por defecto (p. ej., mascar correos, tokens en vez de PAN).
- Políticas de columna por rol/scope (column-level security).
- Materializadas para auditorías de rendimiento cuando aplique.

### 4. Auditoría y Evidencias

- Registrar: solicitante, aprobadores, motivo, alcance, TTL, acciones, SQL/queries, exportaciones.
- Hash de integridad (p. ej., SHA-256) por lote y encadenado (hash chain).
- Almacenamiento WORM/append-only, retención ≥ 7 años; acceso con RLS.

### 5. Controles de Exportación

- Marca de agua por destinatario, límites de volumen, redacción de PII.
- Registros de descarga con checksums y prueba de entrega.
- Bloqueo automático ante anomalías (picos, scraping).

### 6. Matriz de Aprobadores por Tipo de Datos

- Plataforma: Seguridad/Compliance + Manager SRE; TTL ≤ 2h.
- PII Central: DPO/Compliance + Data Owner; TTL ≤ 1h.
- Financiero/PCI: PCI Officer + Compliance; TTL ≤ 1h; solo tokens.
- Gubernamental: Admin Gubernamental + Compliance; TTL ≤ 1h; por jurisdicción.
- Ambiental: Autoridad Ambiental (SINAC) + Compliance; TTL ≤ 1h; por jurisdicción.