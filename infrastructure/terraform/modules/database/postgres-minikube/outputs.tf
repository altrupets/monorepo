output "service_name" {
  description = "PostgreSQL service name"
  value       = kubernetes_service.postgres.metadata[0].name
}

output "service_endpoint" {
  description = "PostgreSQL service endpoint (internal)"
  value       = "${kubernetes_service.postgres.metadata[0].name}.${var.namespace}.svc.cluster.local:5432"
}

output "nodeport_url" {
  description = "NodePort URL for external access (if enabled)"
  value       = var.enable_nodeport ? "localhost:${var.nodeport_port}" : null
}
