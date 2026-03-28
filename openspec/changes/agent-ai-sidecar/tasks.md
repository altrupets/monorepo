# Tareas: Agent AI Sidecar con agentic-core

**Change**: `agent-ai-sidecar`
**Proyecto Linear**: Agent AI (Planned)
**Fecha**: 2026-03-28

---

## Fase 1: Infraestructura Base

- [ ] **Crear Dockerfile para agentic-core sidecar**
  - Imagen base: `python:3.12-slim`
  - Instalar `agentic-core` como dependencia via pip
  - Copiar grafos y configuracion del monorepo (`apps/agent-sidecar/`)
  - Multi-stage build: builder (compilacion de dependencias) + runtime (imagen minima)
  - Exponer puertos: 50051 (gRPC), 9090 (metricas), 8080 (health)
  - Healthcheck integrado en Dockerfile
  - Archivo: `apps/agent-sidecar/Dockerfile`

- [ ] **Crear estructura del proyecto agent-sidecar en el monorepo**
  - Inicializar `apps/agent-sidecar/` con `pyproject.toml`
  - Dependencia principal: `agentic-core`
  - Dependencias adicionales: `grpcio`, `grpcio-tools`, `grpcio-health-checking`
  - Estructura de directorios: `graphs/`, `grpc/`, `config/`, `agents/`, `tests/`
  - Archivo: `apps/agent-sidecar/pyproject.toml`

- [ ] **Definir archivo proto para el servicio de matching**
  - Crear `proto/matching.proto` con `MatchingService`, `FindBestRescuers`, `RecordRescueOutcome`, `HealthCheck`
  - Generar stubs Python: `matching_pb2.py`, `matching_pb2_grpc.py`
  - Generar stubs TypeScript para el backend NestJS
  - Script de generacion: `scripts/gen-proto.sh`
  - Archivo: `proto/matching.proto`

---

## Fase 2: Grafo de Matching (LangGraph)

- [ ] **Implementar el estado del grafo de matching**
  - Definir `MatchingState` como `TypedDict` con todos los campos del pipeline
  - Validacion con Pydantic para inputs (animal_info, location, urgency)
  - Archivo: `apps/agent-sidecar/graphs/state.py`

- [ ] **Implementar nodo `fetch_candidates`**
  - Query a PostgreSQL para rescatistas activos dentro del radio configurable
  - Filtro por capacidad disponible > 0
  - Radio variable por urgencia: 25 km (LOW/MEDIUM), 50 km (HIGH/CRITICAL)
  - Retorna lista de candidatos raw con datos basicos
  - Archivo: `apps/agent-sidecar/graphs/nodes/fetch_candidates.py`

- [ ] **Implementar nodo `enrich_from_graph`**
  - Queries Cypher a FalkorDB para enriquecer cada candidato
  - Obtener: historial de rescates por especie, especializaciones, red de veterinarios, endorsements
  - Manejo de candidatos sin historial en el grafo (score default)
  - Archivo: `apps/agent-sidecar/graphs/nodes/enrich_from_graph.py`

- [ ] **Implementar nodo `score_candidates`**
  - Llamada al LLM con structured output (JSON schema)
  - Pesos dinamicos por nivel de urgencia (proximidad, capacidad, reputacion, especializacion)
  - Prompt engineering para evaluacion multi-factor
  - Fallback: scoring heuristico sin LLM si la API esta caida
  - Archivo: `apps/agent-sidecar/graphs/nodes/score_candidates.py`

- [ ] **Implementar nodo `rank_and_explain`**
  - Ordenar candidatos por score final descendente
  - Generar explicacion legible para cada candidato (para UI y auditoria)
  - Recortar a top-N (configurable, default 5)
  - Archivo: `apps/agent-sidecar/graphs/nodes/rank_and_explain.py`

- [ ] **Ensamblar el `RescuerMatchingGraph` como StateGraph de LangGraph**
  - Conectar los 4 nodos en secuencia: fetch -> enrich -> score -> rank
  - Registrar como persona YAML (`agents/rescuer-matching.yaml`)
  - Compilar y validar el grafo al iniciar el runtime
  - Archivo: `apps/agent-sidecar/graphs/rescuer_matching_graph.py`

---

## Fase 3: FalkorDB y Grafo de Conocimiento

- [ ] **Configurar FalkorDB con esquema de grafo para matching**
  - Crear nodos: `Rescuer`, `Animal`, `Specialization`, `Vet`
  - Crear relaciones: `RESCUED`, `SPECIALIZES_IN`, `WORKS_WITH`, `ENDORSES`, `EXPERT_IN`
  - Indices para consultas frecuentes: `Rescuer.id`, `Rescuer.municipality`, `Specialization.name`
  - Script de inicializacion: `apps/agent-sidecar/scripts/init_graph.cypher`

- [ ] **Implementar seed de datos para desarrollo**
  - Datos de ejemplo: 20 rescatistas, 50 animales, 10 veterinarios, 15 especializaciones
  - Relaciones de ejemplo con scores y conteos realistas
  - Script ejecutable en Minikube: `apps/agent-sidecar/scripts/seed_graph.py`

- [ ] **Implementar `RecordRescueOutcome` para actualizar el grafo**
  - Al completar un rescate, actualizar relaciones `RESCUED` y `SPECIALIZES_IN`
  - Recalcular scores de especializacion del rescatista
  - Crear/actualizar relaciones `WORKS_WITH` si participo un veterinario
  - Archivo: `apps/agent-sidecar/grpc/handlers/record_outcome.py`

---

## Fase 4: Servidor gRPC y Configuracion

- [ ] **Implementar servidor gRPC del sidecar**
  - Servicer para `MatchingService` con los 3 RPCs
  - Interceptor para propagacion de `trace_id` desde metadata gRPC
  - Graceful shutdown con signal handling
  - Archivo: `apps/agent-sidecar/grpc/server.py`

- [ ] **Configurar settings del sidecar con agentic-core**
  - Extender `AgenticSettings` con configuracion especifica de matching
  - Variables de entorno: radios, max_candidates, pesos por urgencia
  - Validacion con Pydantic al arrancar
  - Archivo: `apps/agent-sidecar/config/settings.py`

- [ ] **Crear entrypoint del sidecar**
  - Script principal que inicializa `AgentRuntime` en modo sidecar
  - Registra el grafo de matching como persona
  - Arranca servidor gRPC en `127.0.0.1:50051`
  - Archivo: `apps/agent-sidecar/main.py`

---

## Fase 5: Integracion con Backend NestJS

- [ ] **Crear modulo de matching en el backend NestJS**
  - `MatchingModule` con gRPC client conectado a `localhost:50051`
  - `MatchingService` como wrapper del client gRPC
  - DTOs de request/response mapeados desde proto
  - Archivos: `apps/backend/src/matching/matching.module.ts`, `matching.service.ts`

- [ ] **Crear resolver GraphQL para matching**
  - Mutation `requestRescuerMatching(input: MatchingInput!): MatchingResult!`
  - Query `matchingResult(rescueRequestId: ID!): MatchingResult`
  - Tipos GraphQL: `MatchingResult`, `RescuerCandidate`, `MatchingMetadata`
  - Archivo: `apps/backend/src/matching/matching.resolver.ts`

- [ ] **Integrar matching en el flujo de solicitud de rescate**
  - Al crear `RescueRequest`, invocar matching automaticamente
  - Asignar candidatos a la solicitud
  - Disparar notificaciones push a rescatistas seleccionados
  - Archivo: `apps/backend/src/rescue-request/rescue-request.service.ts` (modificacion)

---

## Fase 6: Manifiestos Kubernetes

- [ ] **Actualizar Deployment del backend para incluir sidecar**
  - Agregar contenedor `agent-sidecar` al pod spec del backend
  - Configurar health probes: gRPC readiness (50051), HTTP liveness (8080/healthz)
  - Configurar recursos: requests 200m CPU / 512Mi RAM, limits 1000m / 1Gi
  - Agregar variable `AGENT_GRPC_URL=localhost:50051` al contenedor backend
  - Archivo: `k8s/base/backend/deployment.yaml`

- [ ] **Crear ConfigMap y Secret para el sidecar**
  - ConfigMap: URLs de Redis, PostgreSQL, FalkorDB, Langfuse, OTEL; configuracion de matching
  - Secret: API keys de LLM, Langfuse, passwords de bases de datos
  - Archivos: `k8s/base/backend/configmap-sidecar.yaml`, `secret-sidecar.yaml`

- [ ] **Crear script de build y carga de imagen en Minikube**
  - Build con Podman: `podman build -t altrupets-agent-sidecar:dev apps/agent-sidecar/`
  - Carga en Minikube: `minikube image load altrupets-agent-sidecar:dev`
  - Integrar en Makefile existente: `make dev-agent-sidecar-build`, `make dev-agent-sidecar-deploy`
  - Archivo: `Makefile` (modificacion)

---

## Fase 7: Observabilidad

- [ ] **Configurar Langfuse tracing para el pipeline de matching**
  - Trace por cada invocacion de `FindBestRescuers`
  - Spans por cada nodo del grafo: `fetch_candidates`, `enrich_from_graph`, `score_candidates`, `rank_and_explain`
  - Registrar generaciones LLM con input/output/tokens/costo
  - Scores de calidad de matching para analisis longitudinal
  - Archivo: `apps/agent-sidecar/graphs/nodes/` (decoradores en cada nodo)

- [ ] **Configurar metricas Prometheus del sidecar**
  - `agent_matching_duration_seconds` (histograma por urgencia)
  - `agent_matching_candidates_evaluated_total` (counter)
  - `agent_matching_candidates_returned_total` (counter)
  - `agent_matching_score_avg` (gauge por factor)
  - `agent_sidecar_errors_total` (counter por tipo)
  - Endpoint `/metrics` en puerto 9090
  - Archivo: `apps/agent-sidecar/config/metrics.py`

- [ ] **Configurar propagacion de trace_id entre backend y sidecar**
  - Interceptor gRPC en el sidecar que extrae `trace_id` de metadata
  - Middleware NestJS que inyecta `trace_id` en llamadas gRPC al sidecar
  - Verificar correlacion end-to-end en Grafana: Flutter -> Backend -> Sidecar
  - Archivos: `apps/agent-sidecar/grpc/interceptors.py`, `apps/backend/src/matching/matching.interceptor.ts`

---

## Fase 8: Testing

- [ ] **Tests unitarios del grafo de matching**
  - Test de cada nodo individual con mocks de PostgreSQL, FalkorDB y LLM
  - Test del grafo completo con datos de ejemplo
  - Validar que los pesos por urgencia producen rankings correctos
  - Cobertura minima: 80%
  - Archivo: `apps/agent-sidecar/tests/test_matching_graph.py`

- [ ] **Tests unitarios del servidor gRPC**
  - Test de `FindBestRescuers` con request valido e invalido
  - Test de `RecordRescueOutcome` con actualizacion del grafo
  - Test de `HealthCheck` con dependencias healthy y degradadas
  - Archivo: `apps/agent-sidecar/tests/test_grpc_server.py`

- [ ] **Tests de integracion backend <-> sidecar**
  - Levantar ambos contenedores en Docker Compose
  - Test end-to-end: GraphQL mutation -> gRPC -> matching -> response
  - Verificar que el `trace_id` se propaga correctamente
  - Verificar que Langfuse recibe los traces
  - Archivo: `apps/agent-sidecar/tests/integration/test_e2e_matching.py`

- [ ] **Test de carga del endpoint de matching**
  - Script k6 para simular 50 solicitudes concurrentes de matching
  - Verificar latencia P99 < 5 segundos
  - Verificar que el sidecar no afecta la estabilidad del backend
  - Archivo: `apps/agent-sidecar/tests/load/k6_matching.js`

---

## Resumen de Dependencias entre Fases

```
Fase 1 (Infra)
  └── Fase 2 (Grafo LangGraph)
       └── Fase 4 (Servidor gRPC)
            └── Fase 5 (Integracion NestJS)
  └── Fase 3 (FalkorDB)
       └── Fase 2 (nodo enrich_from_graph)
  └── Fase 6 (K8s Manifests)
       └── Fase 8 (Tests integracion)
  └── Fase 7 (Observabilidad)
       └── Fase 8 (Tests trazabilidad)
```

Fases 1, 3 y 7 pueden ejecutarse en paralelo. Fase 2 depende de Fase 1 y parcialmente de Fase 3. Fase 5 depende de Fase 4. Fase 8 depende de todas las anteriores.
