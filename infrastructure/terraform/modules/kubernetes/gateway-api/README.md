# Kubernetes Gateway API - Terraform + Helm + Kustomize

This directory contains a comprehensive Gateway API deployment solution using Terraform, Helm, and Kustomize for multi-environment support.

## Architecture

### Arquitectura Híbrida: NGINX Gateway + Istio Service Mesh + OpenTelemetry

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                           Terraform Module                                    │
│                 (infrastructure/terraform/modules)                            │
├──────────────────────────────────────────────────────────────────────────────┤
│  Step 1: Install Gateway API CRDs                                             │
│  Step 2: Deploy NGINX Gateway Fabric (ingress)                                │
│  Step 3: Deploy Istio Service Mesh (optional, sidecars)                       │
│  Step 4: Deploy OpenTelemetry Stack (optional, observability)                 │
│  Step 5: Deploy Helm Charts (optional)                                        │
│  Step 6: Apply Kustomize Overlays (optional)                                  │
│  Step 7: Create GatewayClass(es)                                              │
│  Step 8: Enable Istio Injection on Namespaces                                 │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                              Traffic Flow                                     │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│   Internet ──────► NGINX Gateway ──────► Services with Istio Sidecars        │
│   (HTTP/HTTPS)        (L7 Routing)          (mTLS, Observability)            │
│                                                      │                        │
│                                                      ▼                        │
│                                               [OpenTelemetry                  │
│                                                Collector]                    │
│                                                      │                        │
│                       ┌──────────────────────────────┼──────────────────┐    │
│                       ▼                              ▼                  ▼    │
│                   [Grafana]                    [Tempo/Logs]       [Prometheus]│
│                   (Visualización)              (Traces)            (Métricas)│
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Componentes

| Componente | Función | Alternativas |
|------------|---------|--------------|
| **NGINX Gateway Fabric** | Controlador Gateway API para routing HTTP/HTTPS externo | Istio Gateway, Traefik, Ambassador |
| **Istio Service Mesh** | Sidecar injection, mTLS entre servicios, observabilidad | Linkerd, Consul Connect |
| **OpenTelemetry** | Telemetría unificada (logs, métricas, traces) vendor-neutral | Jaeger nativo, Prometheus directo |
| **Gateway API CRDs** | Recursos Kubernetes (Gateway, HTTPRoute, etc.) | Core de Kubernetes |

### ¿Por qué usar ambos?

**NGINX Gateway Fabric** (Entrypoint):
- ✅ Optimizado para routing externo (L4/L7)
- ✅ Simple de configurar y operar
- ✅ Mejor rendimiento para ingress
- ❌ NO hace sidecar injection

**Istio Service Mesh** (Service-to-Service):
- ✅ Sidecar injection automática
- ✅ mTLS entre todos los pods
- ✅ Observabilidad avanzada (tracing, métricas)
- ❌ Más complejo, más overhead

**La combinación**: Mejor de ambos mundos
- NGINX maneja el tráfico externo eficientemente
- Istio se encarga de la seguridad y observabilidad interna

## Deployment Methods

### Method 1: Terraform-Only (Default)
Only installs CRDs via Terraform. Ideal para empezar o cuando ya tienes controladores instalados.

```hcl
module "gateway_api" {
  source = "../../modules/kubernetes/gateway-api"

  deployment_method = "terraform-only"
  environment       = "dev"
  channel           = "standard"

  # Desactivar instalación de controladores
  enable_nginx_gateway      = false
  enable_istio_service_mesh = false
}
```

### Method 2: NGINX Gateway Only
Solo NGINX Gateway Fabric para routing externo. Sin service mesh.

```hcl
module "gateway_api" {
  source = "../../modules/kubernetes/gateway-api"

  deployment_method        = "terraform-only"
  environment              = "dev"

  # Solo NGINX
  enable_nginx_gateway     = true
  nginx_gateway_version    = "1.2.0"
  enable_istio_service_mesh = false
}
```

### Method 3: NGINX + Istio (Arquitectura Híbrida Recomendada)
NGINX Gateway para routing externo + Istio para service mesh con sidecars.

```hcl
module "gateway_api" {
  source = "../../modules/kubernetes/gateway-api"

  deployment_method         = "terraform-only"
  environment               = "dev"

  # NGINX para Gateway API (ingress)
  enable_nginx_gateway      = true
  nginx_gateway_version     = "1.2.0"

  # Istio para Service Mesh (sidecars + mTLS)
  enable_istio_service_mesh = true
  istio_version             = "1.20.0"
}
```

### Method 4: Helm + Kustomize (Avanzado)
Combina Helm para templates + Kustomize para overrides por ambiente.

```hcl
module "gateway_api" {
  source = "../../modules/kubernetes/gateway-api"

  deployment_method         = "helm-kustomize"
  environment               = "prod"

  # NGINX + Istio en producción
  enable_nginx_gateway      = true
  enable_istio_service_mesh = true

  helm_values = {
    "gateway.replicas" = "3"
    "resources.requests.cpu" = "500m"
  }
}
```

## Directory Structure

```
infrastructure/
├── terraform/
│   └── modules/
│       └── kubernetes/
│           └── gateway-api/
│               ├── main.tf
│               ├── variables.tf
│               ├── outputs.tf
│               └── versions.tf
│
├── helm-charts/
│   └── gateway-api/
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── values-dev.yaml
│       ├── values-qa.yaml
│       ├── values-staging.yaml
│       ├── values-prod.yaml
│       └── templates/
│           ├── _helpers.tpl
│           ├── gateway.yaml
│           ├── httproute.yaml
│           ├── tcproute.yaml
│           ├── tlsroute.yaml
│           └── referencegrant.yaml
│
└── k8s/
    └── gateway-api/
        ├── base/
        │   ├── kustomization.yaml
        │   ├── gateway.yaml
        │   └── httproutes.yaml
        └── overlays/
            ├── dev/
            │   ├── kustomization.yaml
            │   └── patches/
            │       └── gateway-patch.yaml
            ├── qa/
            │   ├── kustomization.yaml
            │   └── patches/
            │       └── gateway-patch.yaml
            ├── staging/
            │   ├── kustomization.yaml
            │   └── patches/
            │       └── gateway-patch.yaml
            └── prod/
                ├── kustomization.yaml
                └── patches/
                    └── gateway-patch.yaml
```

## Usage

### Opción 1: Solo NGINX Gateway (Sin Service Mesh)
Para proyectos simples donde solo necesitas routing externo.

```hcl
module "gateway_api" {
  source = "../../modules/kubernetes/gateway-api"
  
  environment = "dev"
  namespace   = "default"
  
  # Solo NGINX Gateway
  enable_nginx_gateway     = true
  enable_istio_service_mesh = false
}
```

### Opción 2: NGINX Gateway + Istio Service Mesh (Recomendado)
Para microservicios con mTLS entre servicios.

```hcl
module "gateway_api" {
  source = "../../modules/kubernetes/gateway-api"
  
  environment = "dev"
  namespace   = "default"
  
  # NGINX para routing externo
  enable_nginx_gateway     = true
  nginx_gateway_version    = "1.2.0"
  
  # Istio para service mesh (sidecars + mTLS)
  enable_istio_service_mesh = true
  istio_version            = "1.20.0"
}
```

**Después de aplicar, los pods tendrán sidecars automáticamente**:

```bash
# Verificar sidecars
kubectl get pods -n default
# NAME                          READY   STATUS
# my-app-xxx                    2/2     Running  (1 app + 1 sidecar istio-proxy)

# Verificar mTLS
istioctl authn tls-check my-app.default.svc.cluster.local
```

### Opción 3: Solo Istio (sin NGINX)
Si prefieres usar Istio para todo (gateway + service mesh).

```hcl
module "gateway_api" {
  source = "../../modules/kubernetes/gateway-api"
  
  environment = "dev"
  namespace   = "default"
  
  # Desactivar NGINX
  enable_nginx_gateway = false
  
  # Solo Istio (gateway + service mesh)
  enable_istio_service_mesh = true
}
```

### Manual Helm Deployment

```bash
# Deploy with Helm manually
cd infrastructure/helm-charts/gateway-api

# Dev environment
helm install gateway-api-dev . -f values-dev.yaml --namespace dev --create-namespace

# Production environment  
helm install gateway-api-prod . -f values-prod.yaml --namespace production --create-namespace
```

### Manual Kustomize Deployment

```bash
# Apply Kustomize overlays

# Dev
cd infrastructure/k8s/gateway-api
kubectl apply -k overlays/dev

# Production
kubectl apply -k overlays/prod
```

## Environment Configurations

### Dev
- Single replica
- No TLS
- Debug logging
- HTTP only

### QA
- 2 replicas
- Self-signed TLS
- Info logging
- Basic monitoring

### Staging
- 2 replicas
- Staging TLS certificates
- Info logging
- Full monitoring

### Production
- 3 replicas (HA)
- Production TLS (cert-manager/letsencrypt)
- Warning logging
- Full monitoring + alerting
- PodDisruptionBudget

## Observabilidad con OpenTelemetry

### ¿Por qué OpenTelemetry?

**Ventajas sobre soluciones "legacy":**
- ✅ **Vendor-neutral**: No te encierra en una solución propietaria
- ✅ **Unificación**: Logs, métricas y traces en un solo protocolo (OTLP)
- ✅ **Estandar**: Cloud Native Computing Foundation (CNCF) project
- ✅ **Futuro-proof**: Compatible con Grafana, Datadog, New Relic, etc.
- ✅ **Auto-instrumentación**: Istio sidecars envían OTel automáticamente

### Arquitectura OpenTelemetry

```
┌─────────────────────────────────────────────────────────────────┐
│                    OpenTelemetry Stack                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [Applications] ────► [OTel Collector] ────► [Backends]        │
│         │                    │                    │            │
│         │                    ▼                    ▼            │
│         │            ┌───────────────┐    ┌──────────────┐     │
│         │            │  Receivers    │    │   Grafana    │     │
│         │            │  - OTLP       │───►│   (Visual)   │     │
│         │            │  - Prometheus │    └──────────────┘     │
│         │            │  - Jaeger     │                         │
│         │            └───────────────┘    ┌──────────────┐     │
│         │                    │            │    Tempo     │     │
│         │                    ▼            │   (Traces)   │     │
│         │            ┌───────────────┐    └──────────────┘     │
│         │            │  Processors   │                         │
│         └───────────►│  - Batch      │    ┌──────────────┐     │
│                      │  - Filter     │───►│    Loki      │     │
│                      └───────────────┘    │   (Logs)     │     │
│                              │            └──────────────┘     │
│                              ▼                                  │
│                      ┌───────────────┐                          │
│                      │   Exporters   │                          │
│                      │  - OTLP       │                          │
│                      │  - Prometheus │                          │
│                      │  - Loki       │                          │
│                      └───────────────┘                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Componentes del Stack

| Componente | Función | Puerto |
|------------|---------|--------|
| **OTel Collector** | Recibe, procesa y exporta telemetría | 4317 (gRPC), 4318 (HTTP) |
| **Grafana** | Visualización de métricas, logs y traces | 3000 |
| **Tempo** | Backend de traces (reemplaza Jaeger) | 3200 |
| **Loki** | Backend de logs (reemplaza ELK) | 3100 |
| **Prometheus** | Backend de métricas (vía OTel) | 9090 |

### Istio + OpenTelemetry

Istio está pre-configurado para enviar telemetría a OpenTelemetry:

```yaml
# Istio MeshConfig con OTel
meshConfig:
  enableTracing: true
  extensionProviders:
    - name: otel-collector
      opentelemetry:
        service: otel-collector.monitoring.svc.cluster.local
        port: 4317
```

**Sin código**: Los sidecars Envoy envían automáticamente:
- ✅ HTTP request/response metadata
- ✅ Latencias (p50, p95, p99)
- ✅ Status codes
- ✅ Distributed tracing
- ✅ Custom headers

### Verificar OpenTelemetry

```bash
# Verificar OTel Collector
kubectl get pods -n monitoring
# NAME                              READY   STATUS
# otel-collector-xxx                1/1     Running

# Verificar que Istio envía traces
kubectl logs -n istio-system deployment/istiod | grep opentelemetry

# Verificar Grafana
kubectl get svc -n monitoring grafana
# NAME      TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)
# grafana   NodePort   10.96.123.45    <none>        3000:30300/TCP

# Port-forward para acceder a Grafana
kubectl port-forward -n monitoring svc/grafana 3000:3000
# Acceder: http://localhost:3000 (admin/admin)
```

### Dashboards incluidos

Grafana viene con dashboards pre-configurados:

1. **Istio Mesh Dashboard**: Estado general del mesh
2. **Istio Service Dashboard**: Métricas por servicio
3. **Distributed Tracing**: Viaje completo de requests
4. **Logs Explorer**: Logs centralizados con Loki

## Verification

### Verificar Gateway API

```bash
# Check CRDs
kubectl get crd | grep gateway.networking.k8s.io

# Check GatewayClass
kubectl get gatewayclass

# Check Gateways
kubectl get gateway -A

# Check HTTPRoutes
kubectl get httproute -A

# Describe Gateway
kubectl describe gateway <gateway-name> -n <namespace>
```

### Verificar Istio Service Mesh (si está habilitado)

```bash
# Verificar instalación de Istio
kubectl get pods -n istio-system
# NAME                      READY   STATUS
# istiod-xxx                1/1     Running

# Verificar sidecars inyectados
kubectl get pods -n <namespace>
# NAME              READY   STATUS
# my-app-xxx        2/2     Running  # ← 2/2 = app + sidecar

# Verificar mTLS entre servicios
istioctl authn tls-check <service>.<namespace>.svc.cluster.local

# Verificar configuración de sidecar
istioctl proxy-config cluster <pod> -n <namespace>

# Ver logs del sidecar
kubectl logs <pod> -c istio-proxy -n <namespace>
```

### Verificar NGINX Gateway Fabric

```bash
# Pods de NGINX Gateway
kubectl get pods -n nginx-gateway

# Logs del gateway
kubectl logs -n nginx-gateway -l app.kubernetes.io/name=nginx-gateway-fabric

# Configuración del gateway
kubectl get gateway <name> -o yaml
```

## Ejemplo de Arquitectura Completa

```yaml
# Ejemplo: Cliente -> NGINX Gateway -> Service A (sidecar) -> Service B (sidecar)

# 1. HTTPRoute que apunta a Service A
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: api-route
  namespace: default
spec:
  parentRefs:
    - name: dev-gateway
      namespace: default
  hostnames:
    - api.example.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /users
      backendRefs:
        - name: user-service
          port: 8080

# 2. Service A (con sidecar Istio automático)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
        istio-injection: enabled  # ← Sidecar automático
    spec:
      containers:
        - name: user-service
          image: myapp/user-service:v1
          ports:
            - containerPort: 8080

# 3. Service B (llamado por Service A)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-service
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: payment-service
  template:
    metadata:
      labels:
        app: payment-service
        istio-injection: enabled  # ← Sidecar automático
    spec:
      containers:
        - name: payment-service
          image: myapp/payment-service:v1
          ports:
            - containerPort: 8080
```

**Flujo de tráfico seguro**:
1. Cliente HTTP → `api.example.com/users`
2. NGINX Gateway (Gateway API) → Rutea al user-service
3. user-service (app + envoy sidecar) → Llama a payment-service
4. **mTLS automático** entre sidecars (envoy proxies)
5. payment-service responde con mTLS
6. Respuesta vuelve al cliente

## Next Steps

### 1. Instalar Gateway Controllers (ya incluido en el módulo)
Si usaste `enable_nginx_gateway = true` e `enable_istio_service_mesh = true`, ya están instalados.

### 2. Verificar instalación
```bash
# NGINX Gateway
kubectl get pods -n nginx-gateway

# Istio
kubectl get pods -n istio-system
kubectl get namespaces -L istio-injection
```

### 3. Crear HTTPRoutes para tus aplicaciones
```bash
kubectl apply -f my-httproute.yaml
```

### 4. Configurar TLS certificates (recomendado: cert-manager)
```bash
# Instalar cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Crear ClusterIssuer para Let's Encrypt
kubectl apply -f cluster-issuer.yaml
```

## References

- [Gateway API Documentation](https://gateway-api.sigs.k8s.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kustomize Documentation](https://kustomize.io/)
