# ============================================
# OVHCloud Credentials (from Infisical)
# ============================================

variable "ovh_endpoint" {
  description = "OVHCloud API endpoint (e.g., ovh-eu)"
  type        = string
  default     = "ovh-eu"
}

variable "ovh_application_key" {
  description = "OVHCloud application key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ovh_application_secret" {
  description = "OVHCloud application secret"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ovh_consumer_key" {
  description = "OVHCloud consumer key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ovh_service_name" {
  description = "OVHCloud project ID (serviceName)"
  type        = string
  default     = ""
}

# ============================================
# Cluster Configuration
# ============================================

variable "cluster_name" {
  description = "Name of the OVHCloud Kubernetes cluster"
  type        = string
  default     = "altrupets-prod"
}

variable "cluster_region" {
  description = "OVHCloud region for the cluster"
  type        = string
  default     = "GRA7"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

# ============================================
# Node Pool Configuration
# ============================================

variable "node_pool_name" {
  description = "Name of the node pool"
  type        = string
  default     = "default-pool"
}

variable "node_pool_flavor" {
  description = "OVHCloud flavor for nodes (e.g., c2-7 for production)"
  type        = string
  default     = "c2-7"
}

variable "node_pool_desired_nodes" {
  description = "Desired number of nodes"
  type        = number
  default     = 3
}

variable "node_pool_min_nodes" {
  description = "Minimum number of nodes for autoscaling"
  type        = number
  default     = 3
}

variable "node_pool_max_nodes" {
  description = "Maximum number of nodes for autoscaling"
  type        = number
  default     = 10
}

variable "node_pool_autoscale" {
  description = "Enable autoscaling for the node pool"
  type        = bool
  default     = true
}

# ============================================
# Namespace Configuration
# ============================================

variable "namespace" {
  description = "Kubernetes namespace for the application"
  type        = string
  default     = "altrupets-prod"
}

variable "environment" {
  description = "Environment name (qa, staging, prod)"
  type        = string
  default     = "prod"
}

# ============================================
# Database Configuration
# ============================================

variable "database_type" {
  description = "Type of database: self-managed or ovh-managed"
  type        = string
  default     = "ovh-managed"
}

# OVH Managed PostgreSQL configuration
variable "ovh_db_description" {
  description = "Description for OVH Managed PostgreSQL"
  type        = string
  default     = "AltruPets Production Database"
}

variable "ovh_db_plan" {
  description = "OVH Managed DB plan (essential, business, performance)"
  type        = string
  default     = "business"
}

variable "ovh_db_version" {
  description = "OVH Managed PostgreSQL version"
  type        = string
  default     = "15"
}

variable "ovh_db_flavor" {
  description = "OVH Managed DB flavor (e.g., db1-7)"
  type        = string
  default     = "db1-7"
}

# ============================================
# Domain & TLS Configuration
# ============================================

variable "domain_name" {
  description = "Domain name for the environment"
  type        = string
  default     = "altrupets.app"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token for DNS-01 challenge"
  type        = string
  sensitive   = true
  default     = ""
}

variable "acme_email" {
  description = "Email for Let's Encrypt ACME"
  type        = string
  default     = "altrupets.workspace@gmail.com"
}

# ============================================
# Gateway Configuration
# ============================================

variable "enable_https" {
  description = "Enable HTTPS with cert-manager"
  type        = bool
  default     = true
}

variable "gateway_version" {
  description = "Gateway API version"
  type        = string
  default     = "v1.4.1"
}

variable "nginx_gateway_version" {
  description = "NGINX Gateway Fabric version"
  type        = string
  default     = "2.4.1"
}

# ============================================
# Monitoring Configuration
# ============================================

variable "enable_monitoring" {
  description = "Enable enhanced monitoring and alerting for production"
  type        = bool
  default     = true
}
