# ============================================
# OVHCloud Kubernetes Cluster - QA Environment
# ============================================

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
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

# Create OVHCloud Managed Kubernetes cluster
resource "ovh_cloud_project_kube" "cluster" {
  service_name = var.ovh_service_name
  name         = var.cluster_name
  region       = var.cluster_region
  version      = var.cluster_version

  timeouts {
    create = "15m"
    delete = "15m"
  }
}

# Create node pool
resource "ovh_cloud_project_kube_nodepool" "nodepool" {
  service_name  = var.ovh_service_name
  kube_id       = ovh_cloud_project_kube.cluster.id
  name          = var.node_pool_name
  flavor_name   = var.node_pool_flavor
  desired_nodes = var.node_pool_desired_nodes
  min_nodes     = var.node_pool_min_nodes
  max_nodes     = var.node_pool_max_nodes
  autoscale     = var.node_pool_autoscale

  timeouts {
    update = "10m"
  }
}

# Get kubeconfig from OVH API
data "ovh_cloud_project_kube_kubeconfig" "kubeconfig" {
  service_name = var.ovh_service_name
  kube_id      = ovh_cloud_project_kube.cluster.id
}

# Local file for kubeconfig (for local access and provider config)
resource "local_file" "kubeconfig" {
  content  = data.ovh_cloud_project_kube_kubeconfig.kubeconfig
  filename = "${path.module}/kubeconfig"
}

# ============================================
# Provider Configuration (using generated kubeconfig)
# ============================================

provider "kubernetes" {
  config_path = local_file.kubeconfig.filename
}

provider "kubectl" {
  config_path = local_file.kubeconfig.filename
}

# Helm provider - uses kubernetes provider config implicitly
# Note: terraform will use the kubernetes provider config for helm

# ============================================
# Provider Configuration
# ============================================
# Note: Modules handle their own provider configuration
# This file focuses on creating OVHCloud resources

# ============================================
# Namespace
# ============================================

resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
    labels = {
      environment = var.environment
      managed-by = "terraform"
    }
  }
}

# ============================================
# PostgreSQL (Self-managed for QA)
# ============================================

module "postgres" {
  source = "../../modules/database/postgres-minikube"

  count = var.database_type == "self-managed" ? 1 : 0

  name                = "postgres-${var.environment}"
  namespace           = kubernetes_namespace.app.metadata[0].name
  postgres_version    = var.postgres_version
  secret_name         = "backend-secret"
  storage_class_name  = "csi-cinder-classic"
  storage_size        = var.postgres_storage_size
  enable_nodeport     = false
}

# ============================================
# Gateway API
# ============================================

module "gateway_api" {
  source = "../../modules/kubernetes/gateway-api"

  environment     = var.environment
  namespace       = kubernetes_namespace.app.metadata[0].name
  gateway_version = var.gateway_version
  channel         = "standard"

  deployment_method = "helm"

  enable_nginx_gateway     = true
  nginx_gateway_version    = var.nginx_gateway_version
  nginx_gateway_namespace  = "nginx-gateway"
  nginx_gateway_class_name = "nginx"

  enable_https                  = var.enable_https
  tls_certificate_secret_name   = "altrupets-app-tls"
  tls_certificate_namespace     = kubernetes_namespace.app.metadata[0].name

  deploy_gateway        = true
  gateway_name          = "${var.environment}-gateway"
  deploy_example_routes = false
}

# ============================================
# Cert-Manager (for TLS)
# ============================================

module "cert_manager" {
  source = "../../modules/kubernetes/cert-manager"

  count = var.enable_https ? 1 : 0

  environment           = var.environment
  namespace             = kubernetes_namespace.app.metadata[0].name
  domain_name           = var.domain_name
  include_apex_domain   = true
  acme_email            = var.acme_email
  cloudflare_api_token  = var.cloudflare_api_token
  cert_manager_version  = "v1.14.0"
}

# ============================================
# Outputs
# ============================================

output "cluster_id" {
  description = "OVHCloud Kubernetes cluster ID"
  value       = ovh_cloud_project_kube.cluster.id
}

output "cluster_region" {
  description = "Cluster region"
  value       = ovh_cloud_project_kube.cluster.region
}

output "cluster_status" {
  description = "Cluster status"
  value       = ovh_cloud_project_kube.cluster.status
}

output "kubeconfig_path" {
  description = "Path to kubeconfig file"
  value       = local_file.kubeconfig.filename
}

output "namespace" {
  description = "Application namespace"
  value       = kubernetes_namespace.app.metadata[0].name
}

output "postgres_service_endpoint" {
  description = "PostgreSQL service endpoint"
  value       = var.database_type == "self-managed" ? module.postgres[0].service_endpoint : "ovh-managed"
}

output "gateway_api_version" {
  description = "Gateway API version"
  value       = module.gateway_api.gateway_api_version
}

output "gateway_name" {
  description = "Gateway name"
  value       = module.gateway_api.gateway_name
}

output "domain" {
  description = "Environment domain"
  value       = var.domain_name
}
