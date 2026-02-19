# Cert-Manager Module Outputs

output "cert_manager_version" {
  description = "Installed cert-manager version"
  value       = var.cert_manager_version
}

output "certificate_name" {
  description = "Name of the created certificate"
  value       = "${replace(var.domain_name, ".", "-")}-tls"
}

output "certificate_secret_name" {
  description = "Name of the secret containing the certificate"
  value       = "${replace(var.domain_name, ".", "-")}-tls"
}

output "cluster_issuer_staging" {
  description = "Name of the staging ClusterIssuer"
  value       = "letsencrypt-staging"
}

output "cluster_issuer_prod" {
  description = "Name of the production ClusterIssuer"
  value       = "letsencrypt-prod"
}

output "verification_commands" {
  description = "Commands to verify the cert-manager installation"
  value = {
    check_cert_manager  = "kubectl get pods -n cert-manager"
    check_certificate   = "kubectl get certificate -n ${var.namespace}"
    check_issuers       = "kubectl get clusterissuers"
    describe_certificate = "kubectl describe certificate ${replace(var.domain_name, ".", "-")}-tls -n ${var.namespace}"
  }
}
