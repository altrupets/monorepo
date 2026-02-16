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

variable "postgres_username" {
  description = "PostgreSQL username"
  type        = string
  default     = "postgres"
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "postgres_database" {
  description = "PostgreSQL database name"
  type        = string
  default     = "altrupets_user_management"
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
