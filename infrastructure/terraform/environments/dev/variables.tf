# Variables for dev environment
# PostgreSQL credentials are managed by Infisical

# ============================================
# Cert-Manager / Cloudflare Variables
# ============================================
# IMPORTANT: Do NOT set the default value here.
# Pass via:
#   - Environment variable: TF_VAR_cloudflare_api_token
#   - terraform.tfvars (gitignored)
#   - Infisical CLI: infisical run --env=dev -- terraform apply

variable "cloudflare_api_token" {
  description = "Cloudflare API token for DNS-01 challenge (from Infisical)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "enable_cert_manager" {
  description = "Enable cert-manager module for TLS certificates"
  type        = bool
  default     = false
}
