# ============================================
# Core Outputs
# ============================================

output "gateway_api_version" {
  description = "Installed Gateway API version"
  value       = var.gateway_version
}

output "gateway_api_channel" {
  description = "Installed Gateway API channel (standard or experimental)"
  value       = var.channel
}

output "deployment_method" {
  description = "Method used for deployment"
  value       = var.deployment_method
}

output "environment" {
  description = "Target environment"
  value       = var.environment
}

# ============================================
# Deployment Status Outputs
# ============================================

output "crd_installation_status" {
  description = "Status of CRD installation"
  value       = null_resource.gateway_api_crds.id != null ? "installed" : "pending"
}

output "helm_release_status" {
  description = "Status of Helm release (if deployed)"
  value       = length(helm_release.gateway_api) > 0 ? helm_release.gateway_api[0].status : "not_deployed"
}

output "kustomize_status" {
  description = "Status of Kustomize overlay application (if deployed)"
  value       = length(null_resource.kustomize_apply) > 0 ? "applied" : "not_deployed"
}

# ============================================
# Gateway Resource Outputs
# ============================================

output "gateway_class_name" {
  description = "Name of the deployed GatewayClass"
  value       = var.deploy_gateway ? var.gateway_class_name : null
}

output "gateway_name" {
  description = "Name of the deployed Gateway"
  value       = var.deploy_gateway ? var.gateway_name : null
}

output "gateway_namespace" {
  description = "Namespace of the deployed Gateway"
  value       = var.deploy_gateway ? var.namespace : null
}

# ============================================
# Gateway API CRD List
# ============================================

output "gateway_api_crds" {
  description = "List of Gateway API CRD names installed"
  value = compact([
    "gatewayclasses.gateway.networking.k8s.io",
    "gateways.gateway.networking.k8s.io",
    "httproutes.gateway.networking.k8s.io",
    "referencegrants.gateway.networking.k8s.io",
    var.channel == "experimental" ? "grpcroutes.gateway.networking.k8s.io" : null,
    var.channel == "experimental" ? "tcproutes.gateway.networking.k8s.io" : null,
    var.channel == "experimental" ? "tlsroutes.gateway.networking.k8s.io" : null,
    var.channel == "experimental" ? "udproutes.gateway.networking.k8s.io" : null,
    var.channel == "experimental" ? "backendtlspolicies.gateway.networking.k8s.io" : null,
  ])
}

# ============================================
# Verification Commands
# ============================================

output "verification_commands" {
  description = "Commands to verify the Gateway API installation"
  value = {
    crds = "kubectl get crd | grep gateway.networking.k8s.io"
    gateways = "kubectl get gateway -n ${var.namespace}"
    gatewayclasses = "kubectl get gatewayclass"
    httproutes = "kubectl get httproute -n ${var.namespace}"
    describe_gateway = var.deploy_gateway ? "kubectl describe gateway ${var.gateway_name} -n ${var.namespace}" : "Gateway not deployed"
  }
}

# ============================================
# Next Steps
# ============================================

output "next_steps" {
  description = "Recommended next steps after deployment"
  value = <<-EOT
    Gateway API has been deployed successfully!

    Verification Commands:
    - CRDs: kubectl get crd | grep gateway.networking.k8s.io
    - GatewayClasses: kubectl get gatewayclass
    - Gateways: kubectl get gateway -n ${var.namespace}
    - HTTPRoutes: kubectl get httproute -n ${var.namespace}

    ${var.enable_istio_service_mesh ? "Istio Service Mesh Enabled:\n    - Check Istio pods: kubectl get pods -n istio-system\n    - Check sidecars: kubectl get pods -n ${var.namespace} (should show 2/2)\n    - Check mTLS: istioctl authn tls-check <service>.${var.namespace}.svc.cluster.local\n    " : ""}

    Next Steps:
    1. Deploy your applications to namespace: ${var.namespace}

    2. Create HTTPRoutes:
       kubectl apply -f my-httproute.yaml

    3. Verify routing:
       kubectl get httproute -n ${var.namespace}
       kubectl describe gateway ${var.gateway_name} -n ${var.namespace}

    4. Test connectivity:
       curl http://<gateway-ip>/<path>
  EOT
}
