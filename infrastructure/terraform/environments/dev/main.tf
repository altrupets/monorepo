terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  # O usar minikube específico:
  # config_context = "minikube"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    # config_context = "minikube"
  }
}

module "postgres" {
  source = "../../modules/database/postgres-minikube"
  
  name                = "postgres-dev"
  namespace           = "default"
  postgres_version    = "15-alpine"
  postgres_username   = var.postgres_username
  postgres_password   = var.postgres_password
  postgres_database   = var.postgres_database
  storage_class_name  = "standard"  # Minikube default
  storage_size        = "10Gi"
  enable_nodeport     = true         # Para acceso externo con DBeaver
  nodeport_port       = 30432
}

module "gateway_api" {
  source = "../../modules/kubernetes/gateway-api"

  # Core Configuration
  environment     = "dev"
  namespace       = "default"
  gateway_version = "v1.4.1"
  channel         = "standard"

  # Deployment Method: terraform-only, helm, kustomize, or helm-kustomize
  deployment_method = "terraform-only"

  # NGINX Gateway Fabric - for external routing (Gateway API)
  enable_nginx_gateway     = true
  nginx_gateway_version    = "1.2.0"
  nginx_gateway_namespace  = "nginx-gateway"
  nginx_gateway_class_name = "nginx"

  # Istio Service Mesh - for sidecar injection and mTLS (optional)
  # Set to true if you need:
  # - mTLS between services
  # - Service mesh observability
  # - Advanced traffic management (canary, circuit breaking)
  enable_istio_service_mesh = false
  istio_version             = "1.20.0"
  istio_gateway_class_name  = "istio"

  # OpenTelemetry - for unified observability (logs, metrics, traces)
  # Requires: Istio enabled (enable_istio_service_mesh = true)
  # Provides: Vendor-neutral observability with Grafana, Tempo, Loki
  enable_opentelemetry      = false
  otel_collector_version    = "0.91.0"
  otel_namespace            = "monitoring"
  enable_grafana            = true
  enable_tempo              = true
  enable_loki               = true

  # Gateway Configuration
  deploy_gateway        = true
  gateway_name          = "dev-gateway"
  deploy_example_routes = false

  # Helm Configuration (used if deployment_method is "helm" or "helm-kustomize")
  helm_release_name = "gateway-api-dev"
  helm_values       = {}
}

output "postgres_service_endpoint" {
  description = "PostgreSQL service endpoint for backend connection"
  value       = module.postgres.service_endpoint
}

output "postgres_nodeport_url" {
  description = "PostgreSQL NodePort URL for external access"
  value       = module.postgres.nodeport_url
}

# Gateway API Outputs
output "gateway_api_version" {
  description = "Installed Gateway API version"
  value       = module.gateway_api.gateway_api_version
}

output "gateway_api_channel" {
  description = "Installed Gateway API channel"
  value       = module.gateway_api.gateway_api_channel
}

output "gateway_api_crds" {
  description = "List of installed Gateway API CRDs"
  value       = module.gateway_api.gateway_api_crds
}

output "deployment_method" {
  description = "Deployment method used for Gateway API"
  value       = module.gateway_api.deployment_method
}

output "gateway_name" {
  description = "Name of the deployed Gateway"
  value       = module.gateway_api.gateway_name
}

output "gateway_namespace" {
  description = "Namespace of the deployed Gateway"
  value       = module.gateway_api.gateway_namespace
}

output "verification_commands" {
  description = "Commands to verify the Gateway API installation"
  value       = module.gateway_api.verification_commands
}
