# Changelog - Gateway API Infrastructure

Todos los cambios notables en la infraestructura de Gateway API serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/spec/v2.0.0.html).

## [Unreleased]

### Added - 2025-02-16

#### Arquitectura Híbrida: NGINX Gateway + Istio Service Mesh + OpenTelemetry
- **Soporte dual para controladores**:
  - **NGINX Gateway Fabric**: Routing HTTP/HTTPS externo (Gateway API)
  - **Istio Service Mesh**: Sidecar injection + mTLS entre servicios
- **Observabilidad Moderna (OpenTelemetry)**:
  - **OpenTelemetry Collector**: Receptor unificado de telemetría
  - **OTLP Protocol**: Logs, métricas y traces en un solo formato
  - **Vendor-neutral**: Compatible con Grafana, Jaeger, Datadog, etc.
  - **Auto-instrumentación**: Sidecars Envoy envían OTel automáticamente
- **Separación de responsabilidades**:
  - NGINX: Optimizado para ingress/L7 routing
  - Istio: Seguridad service-to-service y observabilidad
  - OpenTelemetry: Telemetría unificada (logs + métricas + traces)
- **Variables de control independientes**:
  - `enable_nginx_gateway` (bool)
  - `enable_istio_service_mesh` (bool)
  - `enable_opentelemetry` (bool)

#### Terraform Module: gateway-api
- **Módulo completo** en `infrastructure/terraform/modules/kubernetes/gateway-api/`
- **Despliegue de Istio via Helm**:
  - `istio-base`: CRDs de Istio
  - `istiod`: Control plane con sidecar injection
  - **Configuración OpenTelemetry**: Integración con OTel Collector
- **Despliegue de NGINX Gateway Fabric via Helm**
- **OpenTelemetry Stack (Opcional)**:
  - OpenTelemetry Collector (DaemonSet + Deployment)
  - Grafana para visualización
  - Tempo para traces (backend OTLP)
  - Loki para logs (backend OTLP)
  - Prometheus para métricas (vía OTel Collector)
- Soporte para **4 métodos de despliegue**:
  - `terraform-only`: Solo CRDs via Terraform
  - `helm`: CRDs + Helm charts
  - `kustomize`: CRDs + Kustomize overlays
  - `helm-kustomize`: CRDs + Helm + Kustomize (recomendado para producción)
- Variables configurables por ambiente (dev, qa, staging, prod)
- Outputs informativos con comandos de verificación
- Documentación completa en README.md

#### Scripts de Despliegue
- **`infrastructure/scripts/lib/common.sh`**: Librería de funciones compartidas (logging, validaciones, helpers de k8s, terraform)
- **`infrastructure/scripts/lib/env-config.sh`**: Configuración específica por ambiente
- **`deploy-gateway-api.sh`**: Script de deploy de Gateway API para QA/Staging
- **`deploy-postgres.sh`**: Script de deploy de PostgreSQL para QA/Staging
- **`verify-deployment.sh`**: Verificación post-deploy de todo el stack

#### Makefile Completo
- **Makefile** en raíz del proyecto con comandos:
  - `make setup`: Setup de desarrollo local
  - `make dev`: Deploy completo a DEV (minikube)
  - `make qa`: Deploy a QA (OVHCloud)
  - `make stage`: Deploy a Staging
  - `make prod`: Deploy a PROD (requiere PR + aprobación)
  - Comandos específicos por componente (`dev-gateway`, `qa-postgres`, etc.)
  - Comandos de CI/CD (`ci-build`, `ci-push`, `ci-deploy`)
  - Utilidades (`verify`, `logs`, `port-forward`, `clean`)

#### GitHub Actions Workflows
- **`.github/workflows/ci-build-push.yml`**: Build y push de imágenes a GHCR
  - Tags: semver + SHA de commit
  - Arquitectura: amd64 (para OVHCloud)
  - Imágenes: `ghcr.io/altrupets/backend` y `ghcr.io/altrupets/frontend`

- **`.github/workflows/deploy-qa.yml`**: Auto-deploy a QA
  - Trigger: Push a `main`
  - Ambiente: OVHCloud Kubernetes (efímero)
  - PostgreSQL: Self-managed en cluster
  - Opción de destrucción automática post-tests

- **`.github/workflows/deploy-staging.yml`**: Deploy manual a Staging
  - Trigger: Manual (`workflow_dispatch`)
  - Versión configurable
  - Skip tests opcional
  - Similar a PROD pero sin usuarios públicos

- **`.github/workflows/deploy-prod.yml`**: Deploy a Producción
  - Trigger: Merge de PR a rama `production`
  - Requiere: 2 aprobaciones mínimo
  - Protección: GitHub Environment `production` (aproveedores manuales)
  - Rollback automático en fallo
  - PostgreSQL: OVH Managed PostgreSQL

#### Configuración Multi-Ambiente OVHCloud
- **DEV**: Minikube local
- **QA**: OVHCloud Kubernetes (efímero, auto-deploy)
- **STAGING**: OVHCloud Kubernetes (persistente, prod-like)
- **PROD**: OVHCloud Kubernetes + Managed PostgreSQL

#### Helm Charts: gateway-api
- **Chart base** en `infrastructure/helm-charts/gateway-api/`
- Templates para:
  - Gateway resources
  - HTTPRoutes (con matching avanzado: path, headers, query params, methods)
  - TCPRoutes
  - TLSRoutes  
  - ReferenceGrants (cross-namespace routing)
- Helpers template (`_helpers.tpl`) para etiquetas y anotaciones consistentes
- Values por defecto configurables

#### Kustomize Configuration
- **Estructura base** en `infrastructure/k8s/gateway-api/base/`
- **Overlays por ambiente**:
  - `dev/`: Sin TLS, logging debug, 1 réplica
  - `qa/`: TLS con certificados self-signed, 2 réplicas
  - `staging/`: TLS con certificados staging, 2 réplicas
  - `prod/`: TLS con cert-manager/LetsEncrypt, 3 réplicas, PDB
- Patches específicos por ambiente para configuración de listeners

#### Dev Environment Configuration
- Actualizado `infrastructure/terraform/environments/dev/main.tf`
- Integración completa con el nuevo módulo gateway-api
- Providers actualizados: kubernetes, helm, null, time

### Changed

#### NGINX Gateway Fabric -取代 ingress-nginx (2026-02-16)
- **NGINX Gateway Fabric v2.4.1** ahora es el controlador principal
- **Istio Service Mesh** deshabilitado por defecto (requiere más recursos: 4 CPUs, 8GB RAM)
- CRDs ahora se instalan desde el repo oficial de NGF:
  - `https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v${version}`
- Helm chart instalado desde OCI registry: `oci://ghcr.io/nginx/charts/nginx-gateway-fabric`
- Entorno DEV configurado con:
  - `enable_istio_service_mesh = false`
  - `enable_nginx_gateway = true`
  - `nginx_gateway_version = "2.4.1"`

#### Terraform Module Updates
- Actualizado repo del chart de Helm: `https://helm.nginx.com/nginx-gateway-fabric` → `oci://ghcr.io/nginx/charts`
- Actualizada versión por defecto: `1.2.0` → `2.4.1`
- Corregido script de instalación de CRDs para usar kustomize

#### Documentación
- **Nuevo README.md** en `infrastructure/terraform/modules/kubernetes/gateway-api/README.md`:
  - Arquitectura completa con diagrama
  - Explicación de los 4 métodos de despliegue
  - Estructura de directorios
  - Uso básico y avanzado
  - Verificación post-despliegue
  - Referencias

### Pending - Environments Expansion

#### Crear estructuras Terraform para QA, STAGE, PROD (Pendiente)
- Crear directorios:
  - `infrastructure/terraform/environments/qa/`
  - `infrastructure/terraform/environments/staging/`
  - `infrastructure/terraform/environments/prod/`
- Cada entorno debe incluir:
  - `main.tf` con referencias al módulo gateway-api
  - `variables.tf` con variables específicas del entorno
- Considerar:
  - QA: Istio deshabilitado (recursos limitados)
  - STAGING: Istio opcional (pruebas de service mesh)
  - PROD: Istio habilitado (mTLS completo)

### Technical Details

#### Providers Terraform
```hcl
kubernetes = "~> 2.23"
helm       = "~> 2.11"
null       = "~> 3.2"
time       = "~> 0.9"
```

#### Versiones Gateway API
- CRDs: v1.4.1
- Canales: standard (default) | experimental

#### Estructura de Archivos Creados
```
infrastructure/
├── terraform/modules/kubernetes/gateway-api/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   └── README.md
├── helm-charts/gateway-api/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── _helpers.tpl
│       ├── gateway.yaml
│       ├── httproute.yaml
│       ├── tcproute.yaml
│       ├── tlsroute.yaml
│       └── referencegrant.yaml
└── k8s/gateway-api/
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

## [1.0.0] - 2025-02-16

### Added
- Configuración inicial de Gateway API
- Módulo Terraform básico para instalación de CRDs
- Integración con entorno dev existente

---

## Notas de Uso

### Verificar instalación
```bash
# CRDs
kubectl get crd | grep gateway.networking.k8s.io

# GatewayClasses
kubectl get gatewayclass

# Gateways
kubectl get gateway -A

# HTTPRoutes
kubectl get httproute -A
```

### Desplegar manualmente con Helm
```bash
cd infrastructure/helm-charts/gateway-api
helm install gateway-api-dev . --namespace dev --create-namespace
```

### Desplegar manualmente con Kustomize
```bash
cd infrastructure/k8s/gateway-api
kubectl apply -k overlays/dev
```

### Cambiar método de despliegue en Terraform
```hcl
module "gateway_api" {
  source = "../../modules/kubernetes/gateway-api"
  
  deployment_method = "helm-kustomize"  # Opciones: terraform-only, helm, kustomize, helm-kustomize
  environment       = "dev"
  # ... otras configuraciones
}
```
