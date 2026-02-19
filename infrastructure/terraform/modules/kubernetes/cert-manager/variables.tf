# Cert-Manager Module Variables

variable "environment" {
  description = "Environment name (dev, qa, staging, prod)"
  type        = string
  default     = "dev"
}

variable "namespace" {
  description = "Namespace for the certificate"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name (e.g., altrupets.app)"
  type        = string
}

variable "include_apex_domain" {
  description = "Include apex domain in certificate (e.g., altrupets.app in addition to *.altrupets.app)"
  type        = bool
  default     = true
}

variable "acme_email" {
  description = "Email address for Let's Encrypt notifications"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token with DNS edit permissions"
  type        = string
  sensitive   = true
}

variable "cert_manager_version" {
  description = "Cert-Manager Helm chart version"
  type        = string
  default     = "v1.14.0"
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for the domain"
  type        = string
  default     = ""
}
