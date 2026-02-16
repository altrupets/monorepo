terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  # O usar minikube específico:
  # config_context = "minikube"
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

output "postgres_service_endpoint" {
  description = "PostgreSQL service endpoint for backend connection"
  value       = module.postgres.service_endpoint
}

output "postgres_nodeport_url" {
  description = "PostgreSQL NodePort URL for external access"
  value       = module.postgres.nodeport_url
}
