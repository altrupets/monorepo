# ============================================
# Core Configuration
# ============================================

variable "environment" {
  description = "Environment name (dev, qa, staging, prod)"
  type        = string
  default     = "dev"
}

variable "namespace" {
  description = "Namespace for Gateway resources"
  type        = string
  default     = "default"
}

variable "gateway_version" {
  description = "Gateway API version to install"
  type        = string
  default     = "v1.4.1"
}

variable "channel" {
  description = "Gateway API release channel (standard or experimental)"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "experimental"], var.channel)
    error_message = "Channel must be either 'standard' or 'experimental'."
  }
}

# ============================================
# Deployment Method
# ============================================

variable "deployment_method" {
  description = "Deployment method: terraform-only, helm, kustomize, or helm-kustomize"
  type        = string
  default     = "terraform-only"

  validation {
    condition     = contains(["terraform-only", "helm", "kustomize", "helm-kustomize"], var.deployment_method)
    error_message = "Deployment method must be one of: terraform-only, helm, kustomize, helm-kustomize."
  }
}

# ============================================
# Helm Configuration
# ============================================

variable "helm_release_name" {
  description = "Name of the Helm release"
  type        = string
  default     = "gateway-api"
}

variable "helm_values" {
  description = "Additional Helm values as a map"
  type        = map(string)
  default     = {}
}

# ============================================
# Gateway Configuration
# ============================================

variable "deploy_gateway" {
  description = "Deploy a Gateway resource"
  type        = bool
  default     = true
}

variable "gateway_name" {
  description = "Name of the Gateway resource"
  type        = string
  default     = "default-gateway"
}

variable "gateway_class_name" {
  description = "GatewayClass name to use"
  type        = string
  default     = "nginx"
}

variable "gateway_controller_name" {
  description = "Controller name for the GatewayClass"
  type        = string
  default     = "k8s.io/ingress-nginx"
}

variable "deploy_example_routes" {
  description = "Deploy example HTTPRoutes"
  type        = bool
  default     = false
}

# ============================================
# NGINX Gateway Fabric Configuration
# ============================================

variable "enable_nginx_gateway" {
  description = "Enable NGINX Gateway Fabric for external routing"
  type        = bool
  default     = true
}

variable "nginx_gateway_version" {
  description = "NGINX Gateway Fabric version"
  type        = string
  default     = "2.4.1"
}

variable "nginx_gateway_namespace" {
  description = "Namespace for NGINX Gateway Fabric"
  type        = string
  default     = "nginx-gateway"
}

variable "nginx_gateway_class_name" {
  description = "Name of the GatewayClass for NGINX"
  type        = string
  default     = "nginx"
}

variable "gateway_nodeport_port" {
  description = "NodePort port for Gateway access (30000-32767)"
  type        = number
  default     = 30080
}

# ============================================
# Istio Service Mesh Configuration
# ============================================

variable "enable_istio_service_mesh" {
  description = "Enable Istio Service Mesh for sidecar injection and mTLS"
  type        = bool
  default     = false
}

variable "istio_version" {
  description = "Istio version"
  type        = string
  default     = "1.20.0"
}

variable "istio_gateway_class_name" {
  description = "Name of the GatewayClass for Istio (optional)"
  type        = string
  default     = "istio"
}

# ============================================
# OpenTelemetry Configuration
# ============================================

variable "enable_opentelemetry" {
  description = "Enable OpenTelemetry stack for unified observability (logs, metrics, traces)"
  type        = bool
  default     = false
}

variable "otel_collector_version" {
  description = "OpenTelemetry Collector version"
  type        = string
  default     = "0.91.0"
}

variable "otel_namespace" {
  description = "Namespace for OpenTelemetry components"
  type        = string
  default     = "monitoring"
}

variable "enable_grafana" {
  description = "Enable Grafana for visualization (requires OpenTelemetry)"
  type        = bool
  default     = true
}

variable "grafana_version" {
  description = "Grafana version"
  type        = string
  default     = "10.2.3"
}

variable "enable_tempo" {
  description = "Enable Grafana Tempo for trace backend (requires OpenTelemetry)"
  type        = bool
  default     = true
}

variable "enable_loki" {
  description = "Enable Grafana Loki for log aggregation (requires OpenTelemetry)"
  type        = bool
  default     = true
}

# ============================================
# CRD Configuration
# ============================================

variable "wait_for_crds" {
  description = "Wait for CRDs to be established after installation"
  type        = bool
  default     = true
}

variable "preserve_crds_on_destroy" {
  description = "Preserve CRDs when destroying resources (recommended for production)"
  type        = bool
  default     = true
}

# ============================================
# TLS/HTTPS Configuration
# ============================================

variable "enable_https" {
  description = "Enable HTTPS listener on the Gateway"
  type        = bool
  default     = false
}

variable "tls_certificate_secret_name" {
  description = "Name of the Kubernetes secret containing the TLS certificate"
  type        = string
  default     = ""
}

variable "tls_certificate_namespace" {
  description = "Namespace of the TLS certificate secret (defaults to var.namespace)"
  type        = string
  default     = ""
}

variable "https_nodeport_port" {
  description = "NodePort port for HTTPS access (30000-32767)"
  type        = number
  default     = 30443
}
