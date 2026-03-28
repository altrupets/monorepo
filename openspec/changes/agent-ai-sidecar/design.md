# Diseno Tecnico: Agent AI Sidecar con agentic-core

**Change**: `agent-ai-sidecar`
**Fecha**: 2026-03-28

---

## 1. Arquitectura General

### Patron Sidecar en Kubernetes

El contenedor `agentic-core` se despliega como sidecar dentro del mismo pod que el backend NestJS. Ambos contenedores comparten el network namespace (`localhost`) y pueden montar volumenes compartidos.

```mermaid
graph TD
    subgraph Pod["Pod: backend (namespace altrupets-dev)"]
        subgraph NestJS["NestJS Backend"]
            HTTP[":3001 (HTTP)"]
            GQL[":3001/graphql"]
        end
        subgraph Sidecar["agentic-core (Python sidecar)"]
            GRPC[":50051 (gRPC)"]
            Metrics[":9090 /metrics"]
            Health[":8080 /healthz"]
        end
        NestJS <-->|"gRPC localhost:50051"| Sidecar
        Shared["Shared: network namespace, ConfigMap envs, Secrets"]
    end

    Pod --> PostgreSQL["PostgreSQL (existente)"]
    Pod --> FalkorDB["FalkorDB (:6379)"]
    Pod --> Redis["Redis (existente)"]
```

### Flujo de Comunicacion

1. Flutter envia solicitud de rescate al backend NestJS via GraphQL
2. Backend procesa la solicitud y llama al sidecar via gRPC (`MatchingService.FindBestRescuers`)
3. Sidecar ejecuta el grafo LangGraph de matching
4. LangGraph consulta FalkorDB para relaciones del grafo de conocimiento
5. LangGraph evalua candidatos con LLM (scoring multi-factor)
6. Sidecar retorna lista rankeada de rescatistas al backend
7. Backend notifica a los rescatistas seleccionados

---

## 2. Definicion del Servicio gRPC

### Proto: `matching.proto`

```protobuf
syntax = "proto3";

package altrupets.agent.matching;

service MatchingService {
  // Encuentra los mejores rescatistas para una solicitud de rescate
  rpc FindBestRescuers (MatchingRequest) returns (MatchingResponse);

  // Actualiza el grafo de conocimiento con resultado de un rescate
  rpc RecordRescueOutcome (RescueOutcomeRequest) returns (RescueOutcomeResponse);

  // Health check del sidecar
  rpc HealthCheck (HealthCheckRequest) returns (HealthCheckResponse);
}

message MatchingRequest {
  string rescue_request_id = 1;
  AnimalInfo animal = 2;
  Location location = 3;
  UrgencyLevel urgency = 4;
  int32 max_candidates = 5; // default: 5
}

message AnimalInfo {
  string species = 1;          // perro, gato, ave, etc.
  string condition = 2;        // herido, desnutrido, abandonado, etc.
  string size = 3;             // pequeno, mediano, grande
  repeated string medical_needs = 4;
}

message Location {
  double latitude = 1;
  double longitude = 2;
  string municipality = 3;
  string province = 4;
}

enum UrgencyLevel {
  URGENCY_UNSPECIFIED = 0;
  LOW = 1;         // animal estable, sin riesgo inmediato
  MEDIUM = 2;      // requiere atencion pronto
  HIGH = 3;        // requiere atencion inmediata
  CRITICAL = 4;    // riesgo de vida, emergencia
}

message MatchingResponse {
  string rescue_request_id = 1;
  repeated RescuerCandidate candidates = 2;
  MatchingMetadata metadata = 3;
}

message RescuerCandidate {
  string rescuer_id = 1;
  double overall_score = 2;      // 0.0 - 1.0
  double proximity_score = 3;
  double capacity_score = 4;
  double reputation_score = 5;
  double specialization_score = 6;
  string reasoning = 7;          // explicacion del LLM
  double distance_km = 8;
  int32 available_slots = 9;
}

message MatchingMetadata {
  int32 total_candidates_evaluated = 1;
  int32 candidates_returned = 2;
  double latency_ms = 3;
  string trace_id = 4;           // correlacion con OpenTelemetry
  string langfuse_trace_url = 5;
}

message RescueOutcomeRequest {
  string rescue_request_id = 1;
  string rescuer_id = 2;
  RescueOutcome outcome = 3;
  string feedback = 4;
}

enum RescueOutcome {
  OUTCOME_UNSPECIFIED = 0;
  SUCCESSFUL = 1;
  PARTIAL = 2;
  FAILED = 3;
  DECLINED = 4;
}

message RescueOutcomeResponse {
  bool graph_updated = 1;
}

message HealthCheckRequest {}

message HealthCheckResponse {
  bool healthy = 1;
  string version = 2;
  map<string, bool> dependencies = 3; // falkordb, redis, postgres, langfuse
}
```

---

## 3. Pipeline de Matching con LangGraph

### StateGraph: RescuerMatchingGraph

El grafo de matching se implementa como un `StateGraph` de LangGraph dentro del monorepo de AltruPets (no dentro de agentic-core, que no contiene logica de dominio).

```mermaid
graph TD
    START["START (input)"]
    START --> fetch["fetch_candidates<br/>- Query PostgreSQL<br/>- Filtro por radio<br/>- Filtro por estado"]
    fetch --> enrich["enrich_from_graph<br/>- Query FalkorDB<br/>- Historial rescates<br/>- Especializaciones<br/>- Relaciones sociales"]
    enrich --> score["score_candidates<br/>- LLM multi-factor<br/>- Pesos por urgencia<br/>- Structured output"]
    score --> rank["rank_and_explain<br/>- Sort por score<br/>- Genera reasoning<br/>- Top-N candidates"]
    rank --> END["END (output)"]
```

### Estado del Grafo

```python
from typing import TypedDict

class MatchingState(TypedDict):
    rescue_request_id: str
    animal_info: dict
    location: dict
    urgency: str
    max_candidates: int
    # Se van llenando por cada nodo
    raw_candidates: list[dict]       # fetch_candidates
    enriched_candidates: list[dict]  # enrich_from_graph
    scored_candidates: list[dict]    # score_candidates
    final_candidates: list[dict]     # rank_and_explain
    metadata: dict
```

### Nodos del Grafo

**fetch_candidates**: Consulta PostgreSQL para obtener rescatistas activos dentro de un radio configurable (default 25 km para LOW, 50 km para HIGH/CRITICAL). Filtra por estado `ACTIVE` y capacidad disponible > 0.

**enrich_from_graph**: Consulta FalkorDB con Cypher para enriquecer cada candidato con:
- Numero de rescates exitosos por especie
- Especializaciones (ej: "gatos neonatos", "perros grandes heridos")
- Relaciones con veterinarios cercanos
- Score de comunidad (endorsements de otros rescatistas)

**score_candidates**: Invoca al LLM con structured output (JSON schema) para evaluar cada candidato. Los pesos varian por urgencia:

| Factor | LOW | MEDIUM | HIGH | CRITICAL |
|--------|-----|--------|------|----------|
| Proximidad | 0.20 | 0.25 | 0.35 | 0.45 |
| Capacidad | 0.30 | 0.25 | 0.20 | 0.15 |
| Reputacion | 0.25 | 0.25 | 0.25 | 0.25 |
| Especializacion | 0.25 | 0.25 | 0.20 | 0.15 |

**rank_and_explain**: Ordena por score final, genera explicacion legible para cada candidato, y retorna los top-N.

---

## 4. Esquema de Grafo en FalkorDB

### Nodos

```cypher
// Rescatista
CREATE (:Rescuer {
  id: string,
  name: string,
  latitude: float,
  longitude: float,
  capacity_total: int,
  capacity_used: int,
  active: boolean,
  municipality: string
})

// Animal rescatado
CREATE (:Animal {
  id: string,
  species: string,
  condition: string,
  size: string,
  rescue_date: datetime
})

// Especializacion
CREATE (:Specialization {
  name: string,        // ej: "gatos_neonatos", "perros_grandes_heridos"
  category: string     // species, medical, size
})

// Veterinario
CREATE (:Vet {
  id: string,
  name: string,
  latitude: float,
  longitude: float
})
```

### Relaciones

```cypher
// Rescatista rescato animal (con resultado)
(:Rescuer)-[:RESCUED {outcome: string, date: datetime}]->(:Animal)

// Rescatista tiene especializacion (con score)
(:Rescuer)-[:SPECIALIZES_IN {score: float, rescue_count: int}]->(:Specialization)

// Rescatista trabaja con veterinario
(:Rescuer)-[:WORKS_WITH {success_rate: float, cases: int}]->(:Vet)

// Rescatista endosa a otro rescatista
(:Rescuer)-[:ENDORSES {date: datetime}]->(:Rescuer)

// Veterinario especializado en
(:Vet)-[:EXPERT_IN]->(:Specialization)
```

### Queries de Enriquecimiento

```cypher
// Obtener score de especializacion de un rescatista para una especie
MATCH (r:Rescuer {id: $rescuer_id})-[s:SPECIALIZES_IN]->(sp:Specialization)
WHERE sp.category = 'species' AND sp.name = $species
RETURN s.score, s.rescue_count

// Obtener red de veterinarios cercanos a un rescatista
MATCH (r:Rescuer {id: $rescuer_id})-[w:WORKS_WITH]->(v:Vet)
RETURN v.id, v.name, w.success_rate, w.cases
ORDER BY w.success_rate DESC

// Obtener endorsements (red social de confianza)
MATCH (r:Rescuer {id: $rescuer_id})<-[:ENDORSES]-(endorser:Rescuer)
RETURN count(endorser) AS endorsement_count
```

---

## 5. Integracion con el Backend NestJS

### Modulo gRPC en NestJS

El backend se conecta al sidecar via gRPC client. La conexion es a `localhost:50051` (mismo pod).

```
// Ubicacion en el monorepo
apps/backend/src/matching/
  matching.module.ts       -- NestJS module
  matching.service.ts      -- gRPC client wrapper
  matching.resolver.ts     -- GraphQL resolver
  proto/matching.proto     -- Proto compartido (symlink)
```

### Flujo de Integracion

1. **RescueRequestResolver** recibe mutation `createRescueRequest`
2. Persiste la solicitud en PostgreSQL
3. Llama a `MatchingService.findBestRescuers(request)`
4. `MatchingService` invoca gRPC al sidecar
5. Recibe candidatos rankeados
6. Envia notificaciones push a los rescatistas seleccionados
7. Retorna la solicitud con candidatos asignados al cliente Flutter

---

## 6. Manifiestos de Kubernetes

### Deployment Multi-Contenedor

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: altrupets-dev
  labels:
    app: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9090"
        prometheus.io/path: "/metrics"
    spec:
      containers:
        # Contenedor principal: NestJS Backend
        - name: backend
          image: localhost/altrupets-backend:dev
          ports:
            - name: http
              containerPort: 3001
          envFrom:
            - configMapRef:
                name: backend-config
            - secretRef:
                name: backend-secret
          env:
            - name: AGENT_GRPC_URL
              value: "localhost:50051"
          readinessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 10
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 20
          resources:
            requests:
              cpu: 200m
              memory: 512Mi
            limits:
              cpu: 1000m
              memory: 1Gi

        # Contenedor sidecar: agentic-core (Agent AI)
        - name: agent-sidecar
          image: localhost/altrupets-agent-sidecar:dev
          ports:
            - name: grpc
              containerPort: 50051
            - name: metrics
              containerPort: 9090
            - name: health
              containerPort: 8080
          envFrom:
            - configMapRef:
                name: agent-sidecar-config
            - secretRef:
                name: agent-sidecar-secret
          env:
            - name: AGENTIC_MODE
              value: "sidecar"
            - name: GRPC_HOST
              value: "127.0.0.1"
            - name: GRPC_PORT
              value: "50051"
          readinessProbe:
            grpc:
              port: 50051
            initialDelaySeconds: 15
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /healthz
              port: health
            initialDelaySeconds: 30
            periodSeconds: 20
          resources:
            requests:
              cpu: 200m
              memory: 512Mi
            limits:
              cpu: 1000m
              memory: 1Gi
      # El backend debe esperar al sidecar
      initContainers: []
```

### ConfigMap del Sidecar

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: agent-sidecar-config
  namespace: altrupets-dev
data:
  AGENTIC_MODE: "sidecar"
  REDIS_URL: "redis://redis-service.altrupets-dev.svc.cluster.local:6379"
  POSTGRES_DSN: "postgresql://agent:$(POSTGRES_PASSWORD)@postgres-service.altrupets-dev.svc.cluster.local:5432/altrupets"
  FALKORDB_URL: "redis://falkordb-service.altrupets-dev.svc.cluster.local:6379"
  LANGFUSE_HOST: "https://langfuse.altrupets.dev"
  OTEL_EXPORTER_OTLP_ENDPOINT: "http://otel-collector.altrupets-dev.svc.cluster.local:4317"
  OTEL_SERVICE_NAME: "agent-sidecar"
  LOG_LEVEL: "INFO"
  MATCHING_DEFAULT_RADIUS_KM: "25"
  MATCHING_CRITICAL_RADIUS_KM: "50"
  MATCHING_MAX_CANDIDATES: "5"
```

### Secret del Sidecar

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: agent-sidecar-secret
  namespace: altrupets-dev
type: Opaque
stringData:
  LANGFUSE_PUBLIC_KEY: "<from-vault>"
  LANGFUSE_SECRET_KEY: "<from-vault>"
  LLM_API_KEY: "<from-vault>"
  POSTGRES_PASSWORD: "<from-vault>"
  FALKORDB_PASSWORD: "<from-vault>"
```

---

## 7. Observabilidad

### Langfuse

Cada invocacion de `FindBestRescuers` genera un trace en Langfuse con:

- **Trace**: `matching:{rescue_request_id}`
- **Spans**: `fetch_candidates`, `enrich_from_graph`, `score_candidates`, `rank_and_explain`
- **Generaciones**: Cada llamada al LLM en `score_candidates` registra input/output/tokens/costo
- **Scores**: Score final del matching para evaluar calidad a lo largo del tiempo

### OpenTelemetry

El `trace_id` se propaga desde el backend NestJS al sidecar via metadata de gRPC, permitiendo:

- Trace completo: `Flutter -> Backend -> Sidecar -> FalkorDB/LLM`
- Metricas de latencia por nodo del grafo
- Dashboard en Grafana con P50/P95/P99 de latencia de matching

### Metricas Prometheus

```
# Latencia total de matching
agent_matching_duration_seconds{urgency="HIGH"}

# Candidatos evaluados vs retornados
agent_matching_candidates_evaluated_total
agent_matching_candidates_returned_total

# Score promedio de matching
agent_matching_score_avg{factor="proximity|capacity|reputation|specialization"}

# Errores del sidecar
agent_sidecar_errors_total{type="grpc|falkordb|llm"}
```

---

## 8. Estructura de Archivos en el Monorepo

```
altrupets-monorepo/
  apps/
    backend/
      src/
        matching/
          matching.module.ts
          matching.service.ts          # gRPC client
          matching.resolver.ts         # GraphQL mutations/queries
          dto/
            matching-request.dto.ts
            matching-response.dto.ts
    agent-sidecar/
      Dockerfile
      pyproject.toml
      agents/
        rescuer-matching.yaml          # Persona YAML
      graphs/
        rescuer_matching_graph.py      # LangGraph StateGraph
        nodes/
          fetch_candidates.py
          enrich_from_graph.py
          score_candidates.py
          rank_and_explain.py
        state.py                       # MatchingState TypedDict
      grpc/
        matching_pb2.py                # Generado
        matching_pb2_grpc.py           # Generado
        server.py                      # gRPC server setup
      config/
        settings.py                    # Configuracion del sidecar
      tests/
        test_matching_graph.py
        test_grpc_server.py
        conftest.py
  proto/
    matching.proto                     # Fuente de verdad
  k8s/
    base/backend/
      deployment.yaml                  # Actualizado con sidecar
      configmap-sidecar.yaml
      secret-sidecar.yaml
```

---

## 9. Decisiones de Diseno

| Decision | Eleccion | Alternativa descartada | Razon |
|----------|----------|----------------------|-------|
| Comunicacion backend-sidecar | gRPC | REST, WebSocket | Tipado fuerte con proto, streaming nativo, baja latencia |
| Patron de deployment | Sidecar | Microservicio independiente | Latencia localhost, lifecycle acoplado, simplicidad |
| Libreria de orquestacion | agentic-core | Implementacion custom NestJS | Production-ready, arquitectura hexagonal, mantenida como OSS |
| Grafo de conocimiento | FalkorDB | Neo4j, ArangoDB | Ya en la infraestructura, compatible con agentic-core, licencia permisiva |
| Template de grafo LangGraph | Custom StateGraph | ReAct template | El matching no requiere tool-calling iterativo, es un pipeline lineal |
| Observabilidad LLM | Langfuse | LangSmith | Self-hosteable, integracion nativa con agentic-core, costo predecible |
