variable "name" {
  description = "Name of the PostgreSQL instance"
  type        = string
  default     = "postgres"
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "default"
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15-alpine"
}

variable "secret_name" {
  description = "Name of the existing Kubernetes secret (managed by Infisical)"
  type        = string
  default     = "backend-secret"
}

variable "storage_class_name" {
  description = "Storage class name (use 'standard' for Minikube or 'hostpath')"
  type        = string
  default     = "standard"
}

variable "storage_size" {
  description = "Storage size (e.g., '10Gi')"
  type        = string
  default     = "10Gi"
}

variable "enable_nodeport" {
  description = "Enable NodePort service for external access"
  type        = bool
  default     = false
}

variable "nodeport_port" {
  description = "NodePort port number (30000-32767)"
  type        = number
  default     = 30432
}
