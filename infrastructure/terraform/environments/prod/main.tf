# ============================================
# OVHCloud Kubernetes Cluster - Production Environment
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

# Create node pool (production - larger nodes)
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
# OVH Managed PostgreSQL (Production)
# ============================================

resource "ovh_cloud_project_database_postgresql" "postgres" {
  count = var.database_type == "ovh-managed" ? 1 : 0

  service_name = var.ovh_service_name
  description  = var.ovh_db_description
  plan         = var.ovh_db_plan
  version      = var.ovh_db_version

  nodes {
    region = var.cluster_region
  }

  node {
    flavor = var.ovh_db_flavor
    region = var.cluster_region
  }
}

# Get PostgreSQL credentials
data "ovh_cloud_project_database_postgresql_credentials" "credentials" {
  count = var.database_type == "ovh-managed" ? 1 : 0

  service_name = var.ovh_service_name
  id           = ovh_cloud_project_database_postgresql.postgres[0].id
}

# Get PostgreSQL endpoint
data "ovh_cloud_project_database_postgresql_endpoint" "endpoint" {
  count = var.database_type == "ovh-managed" ? 1 : 0

  service_name = var.ovh_service_name
  id           = ovh_cloud_project_database_postgresql.postgres[0].id
}

# Store credentials in Kubernetes secret
resource "kubernetes_secret" "postgres_credentials" {
  count = var.database_type == "ovh-managed" ? 1 : 0

  metadata {
    name      = "ovh-postgres-credentials"
    namespace = var.namespace
  }

  data = {
    host     = data.ovh_cloud_project_database_postgresql_endpoint.endpoint[0].host
    port     = tostring(data.ovh_cloud_project_database_postgresql_endpoint.endpoint[0].port)
    username = data.ovh_cloud_project_database_postgresql_credentials.credentials[0].username
    password = data.ovh_cloud_project_database_postgresql_credentials[0].password
    database = "defaultdb"
  }

  type = "Opaque"
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

output "postgres_endpoint" {
  description = "OVH Managed PostgreSQL endpoint"
  value       = var.database_type == "ovh-managed" ? data.ovh_cloud_project_database_postgresql_endpoint.endpoint[0].host : ""
}

output "postgres_port" {
  description = "OVH Managed PostgreSQL port"
  value       = var.database_type == "ovh-managed" ? data.ovh_cloud_project_database_postgresql_endpoint.endpoint[0].port : ""
}

output "postgres_credentials_secret" {
  description = "Kubernetes secret name for PostgreSQL credentials"
  value       = var.database_type == "ovh-managed" ? kubernetes_secret.postgres_credentials[0].metadata[0].name : ""
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
