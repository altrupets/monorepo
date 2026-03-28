# Propuesta: Agent AI Sidecar con agentic-core

**Change**: `agent-ai-sidecar`
**Proyecto Linear**: Agent AI (Planned)
**Fecha**: 2026-03-28
**Servicios afectados**: Backend (NestJS), Infraestructura K8s, FalkorDB, Redis, PostgreSQL

---

## Que

Desplegar la libreria open-source `agentic-core` (Python 3.12+) como contenedor sidecar de Kubernetes junto al backend NestJS existente, para proporcionar matching inteligente de rescatistas basado en IA.

El sidecar expone un servidor gRPC en `localhost:50051` dentro del mismo pod, al cual el backend NestJS se conecta para solicitar recomendaciones de matching. El flujo de matching utiliza LangGraph StateGraph para orquestar la evaluacion de rescatistas por proximidad, capacidad, reputacion y especializacion.

---

## Por que

### Problema actual

Los specs existentes en `specs/backend-agent/` (11 pasos) proponen construir un servicio NestJS independiente que reimplementa desde cero: LangGraph (via TypeScript), memoria grafica (Zep + FalkorDB), y observabilidad (Langfuse). Esto implica:

1. **Duplicacion de esfuerzo**: Reimplementar en TypeScript patrones que ya existen production-ready en Python
2. **Complejidad operacional**: Un microservicio adicional con su propio deployment, scaling y networking
3. **Falta de ecosistema**: El ecosistema de AI/ML en Python es significativamente mas maduro que en TypeScript para LangGraph, embeddings y graph databases

### Solucion propuesta

`agentic-core` ya implementa todos los componentes necesarios:

- **Transporte gRPC**: Adaptador primario listo para comunicacion backend-to-sidecar
- **LangGraph**: Integracion nativa via `GraphOrchestrationPort` con templates (ReAct, Plan-and-Execute, etc.)
- **FalkorDB**: Adaptador secundario via `GraphStorePort` para memoria grafica de relaciones rescatista-animal-ubicacion
- **Langfuse**: Adaptador secundario via `CostTrackingPort` para observabilidad de costos LLM
- **OpenTelemetry**: Trazabilidad correlacionada con `trace_id` compartido entre backend y sidecar
- **Arquitectura Hexagonal**: Ports & Adapters con DDD + CQRS, facilita extension sin modificar el core

### Ventajas del patron sidecar

- **Latencia minima**: Comunicacion via `localhost` (shared network namespace), sin DNS resolution ni network hops
- **Lifecycle acoplado**: El sidecar escala junto al backend (mismo ReplicaSet)
- **Simplicidad operacional**: Un solo Deployment con dos contenedores, no un microservicio separado
- **Aislamiento de recursos**: Limites de CPU/memoria independientes para el contenedor Python

---

## Alcance

### Incluido

- Dockerfile para agentic-core con dependencias de matching
- Definiciones `.proto` para el servicio gRPC de matching
- Grafo LangGraph personalizado (`RescuerMatchingGraph`) para el workflow de matching
- Configuracion de FalkorDB con esquema de grafo para relaciones rescatista-animal-ubicacion
- Manifiestos K8s: pod multi-contenedor (backend + sidecar), ConfigMap, Secret, health probes
- Integracion de Langfuse para trazabilidad de decisiones de matching
- Pipeline de observabilidad con OpenTelemetry compartido
- Tests de integracion backend <-> sidecar

### Excluido

- Migracion de funcionalidades existentes del backend NestJS
- WebSocket directo desde Flutter al sidecar (fase futura)
- Meta-orquestacion (GSD Sequencer, Superpowers Flow) -- no aplica para matching
- MCP Bridge -- no se requieren herramientas externas para matching
- Multimodal RAG -- el matching no requiere embeddings de imagenes/video

---

## Impacto

### Funcional

Habilita matching inteligente de rescatistas a solicitudes de rescate considerando:

| Factor | Descripcion | Fuente de datos |
|--------|-------------|-----------------|
| **Proximidad** | Distancia geografica al animal reportado | Geolocation Service |
| **Capacidad** | Disponibilidad de espacio en casa cuna | Backend (perfil rescatista) |
| **Reputacion** | Score historico de rescates exitosos | Backend (sistema de calificaciones) |
| **Especializacion** | Tipo de animal, condiciones medicas | FalkorDB (grafo de competencias) |

### Tecnico

- El backend NestJS gana capacidad de IA sin cambiar su stack (sigue siendo TypeScript/NestJS)
- Reutiliza infraestructura existente: mismo PostgreSQL, mismo Redis, mismo namespace K8s
- Observabilidad unificada: traces del backend y del sidecar correlacionados en Grafana

### Negocio

- Reduce tiempo de respuesta de rescatistas al optimizar el matching automatico
- Mejora tasa de exito de rescates al asignar el rescatista mas adecuado
- Diferenciacion competitiva: matching basado en grafos de conocimiento, no solo proximidad
