# Gateway API Module - Terraform + Helm + Kustomize Integration
# This module provides comprehensive Gateway API deployment with multi-environment support

locals {
  # Determine deployment method based on configuration
  use_helm      = var.deployment_method == "helm" || var.deployment_method == "helm-kustomize"
  use_kustomize = var.deployment_method == "kustomize" || var.deployment_method == "helm-kustomize"

  # Environment-specific values
  environment = var.environment

  # Gateway API version
  gateway_version = var.gateway_version

  # CRD URL based on channel - Use NGINX Gateway Fabric CRDs (includes NGF-specific fields)
  crd_url = var.channel == "experimental" ? "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/experimental?ref=v${var.nginx_gateway_version}" : "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v${var.nginx_gateway_version}"
}

# ============================================
# STEP 1: Install Gateway API CRDs (Terraform)
# ============================================
resource "null_resource" "gateway_api_crds" {
  triggers = {
    version        = local.gateway_version
    channel        = var.channel
    crd_url        = local.crd_url
    nginx_version  = var.nginx_gateway_version
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Installing Gateway API CRDs from NGINX (v${var.nginx_gateway_version})..."
      kubectl kustomize "${local.crd_url}" | kubectl apply --server-side -f -
      echo "Waiting for CRDs to be established..."
      kubectl wait --for condition=established --timeout=60s crd/gatewayclasses.gateway.networking.k8s.io || echo "CRD may still be establishing..."
      echo "Gateway API CRDs installation completed!"
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "Gateway API CRDs are preserved on destroy to avoid breaking existing resources."
      echo "To remove them manually, run: kubectl kustomize '${self.triggers.crd_url}' | kubectl delete -f -"
    EOT
    on_failure = continue
  }
}

# ============================================
# STEP 2: Deploy Istio Service Mesh (Optional)
# ============================================

resource "helm_release" "istio_base" {
  count = var.enable_istio_service_mesh ? 1 : 0

  depends_on = [null_resource.gateway_api_crds]

  name       = "istio-base"
  namespace  = "istio-system"
  chart      = "base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  version    = var.istio_version

  create_namespace = true

  set {
    name  = "defaultRevision"
    value = "default"
  }
}

resource "helm_release" "istiod" {
  count = var.enable_istio_service_mesh ? 1 : 0

  depends_on = [helm_release.istio_base]

  name       = "istiod"
  namespace  = "istio-system"
  chart      = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  version    = var.istio_version

  values = [
    <<-EOT
    meshConfig:
      accessLogFile: /dev/stdout
      defaultConfig:
        proxyMetadata:
          ISTIO_META_DNS_CAPTURE: "true"
      enableAutoMtls: true
      enableTelemetry: true
    EOT
  ]
}

# ============================================
# STEP 3: Deploy NGINX Gateway Fabric (Optional)
# ============================================

resource "helm_release" "nginx_gateway_fabric" {
  count = var.enable_nginx_gateway ? 1 : 0

  depends_on = [null_resource.gateway_api_crds]

  name       = "ngf"
  namespace  = var.nginx_gateway_namespace
  chart      = "nginx-gateway-fabric"
  repository = "oci://ghcr.io/nginx/charts"
  version    = var.nginx_gateway_version

  create_namespace = true

  set {
    name  = "nginxGateway.config.logging.level"
    value = var.environment == "dev" ? "debug" : "info"
  }

  timeout         = 300
  cleanup_on_fail = true
}

# ============================================
# STEP 4: GatewayClass for NGINX
# ============================================
# NOTE: NGINX Gateway Fabric Helm chart creates the GatewayClass automatically.
# No Terraform resource needed - the GatewayClass is managed by the Helm release.

# ============================================
# STEP 5: Create GatewayClass for Istio (Optional)
# ============================================

resource "kubernetes_manifest" "istio_gateway_class" {
  count = var.enable_istio_service_mesh ? 1 : 0

  depends_on = [
    null_resource.gateway_api_crds,
    helm_release.istiod
  ]

  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "GatewayClass"
    metadata = {
      name = var.istio_gateway_class_name
      annotations = {
        "app.kubernetes.io/managed-by" = "terraform"
      }
    }
    spec = {
      controllerName = "istio.io/gateway-controller"
      description    = "Istio Gateway for ${local.environment}"
    }
  }
}

# ============================================
# STEP 6: Deploy OpenTelemetry Stack (Optional)
# ============================================

resource "kubernetes_namespace" "otel_namespace" {
  count = var.enable_opentelemetry ? 1 : 0

  metadata {
    name = var.otel_namespace
  }
}

resource "helm_release" "opentelemetry_collector" {
  count = var.enable_opentelemetry ? 1 : 0

  depends_on = [
    kubernetes_namespace.otel_namespace
  ]

  name       = "otel-collector"
  namespace  = var.otel_namespace
  chart      = "opentelemetry-collector"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  version    = var.otel_collector_version

  create_namespace = false

  values = [
    <<-EOT
    mode: deployment
    config:
      receivers:
        otlp:
          protocols:
            grpc:
              endpoint: 0.0.0.0:4317
            http:
              endpoint: 0.0.0.0:4318
        prometheus:
          config:
            scrape_configs:
              - job_name: 'istiod'
                kubernetes_sd_configs:
                  - role: endpoints
                    namespaces:
                      names:
                        - istio-system
                relabel_configs:
                  - source_labels: [__meta_kubernetes_service_name]
                    action: keep
                    regex: istiod
      processors:
        batch:
          timeout: 1s
          send_batch_size: 1024
      exporters:
        otlp:
          endpoint: tempo:4317
          tls:
            insecure: true
        loki:
          endpoint: http://loki:3100/loki/api/v1/push
        prometheusremotewrite:
          endpoint: http://prometheus:9090/api/v1/write
          tls:
            insecure: true
      service:
        pipelines:
          traces:
            receivers: [otlp]
            processors: [batch]
            exporters: [otlp]
          metrics:
            receivers: [otlp, prometheus]
            processors: [batch]
            exporters: [prometheusremotewrite]
          logs:
            receivers: [otlp]
            processors: [batch]
            exporters: [loki]
    EOT
  ]
}

resource "helm_release" "grafana" {
  count = var.enable_opentelemetry && var.enable_grafana ? 1 : 0

  depends_on = [
    kubernetes_namespace.otel_namespace
  ]

  name       = "grafana"
  namespace  = var.otel_namespace
  chart      = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  version    = var.grafana_version

  create_namespace = false

  set {
    name  = "adminUser"
    value = "admin"
  }

  set {
    name  = "adminPassword"
    value = "admin"
  }
}

resource "helm_release" "tempo" {
  count = var.enable_opentelemetry && var.enable_tempo ? 1 : 0

  depends_on = [
    kubernetes_namespace.otel_namespace
  ]

  name       = "tempo"
  namespace  = var.otel_namespace
  chart      = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  version    = "1.7.1"

  create_namespace = false
}

resource "helm_release" "loki" {
  count = var.enable_opentelemetry && var.enable_loki ? 1 : 0

  depends_on = [
    kubernetes_namespace.otel_namespace
  ]

  name       = "loki"
  namespace  = var.otel_namespace
  chart      = "loki"
  repository = "https://grafana.github.io/helm-charts"
  version    = "5.41.2"

  create_namespace = false
}

resource "helm_release" "prometheus" {
  count = var.enable_opentelemetry ? 1 : 0

  depends_on = [
    kubernetes_namespace.otel_namespace
  ]

  name       = "prometheus"
  namespace  = var.otel_namespace
  chart      = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "25.8.0"

  create_namespace = false

  set {
    name  = "server.retention"
    value = "15d"
  }
}

# ============================================
# STEP 8: Deploy with Helm (Optional)
# ============================================
resource "helm_release" "gateway_api" {
  count = local.use_helm ? 1 : 0

  depends_on = [null_resource.gateway_api_crds]

  name       = var.helm_release_name
  namespace  = var.namespace
  chart      = "${path.module}/../../../helm-charts/gateway-api"

  # Use environment-specific values file if it exists
  values = fileexists("${path.module}/../../../helm-charts/gateway-api/values-${local.environment}.yaml") ? [
    file("${path.module}/../../../helm-charts/gateway-api/values-${local.environment}.yaml")
  ] : []

  set {
    name  = "global.environment"
    value = local.environment
  }

  set {
    name  = "gateway.enabled"
    value = var.deploy_gateway
  }

  set {
    name  = "gateway.name"
    value = var.gateway_name
  }

  set {
    name  = "gateway.gatewayClassName"
    value = var.enable_nginx_gateway ? var.nginx_gateway_class_name : var.istio_gateway_class_name
  }

  set {
    name  = "httpRoutes.enabled"
    value = var.deploy_example_routes
  }

  dynamic "set" {
    for_each = var.helm_values
    content {
      name  = set.key
      value = set.value
    }
  }

  timeout         = 300
  cleanup_on_fail = true
  force_update    = true
  recreate_pods   = false
}

# ============================================
# STEP 9: Apply Kustomize Overlays (Optional)
# ============================================
resource "null_resource" "kustomize_apply" {
  count = local.use_kustomize ? 1 : 0

  depends_on = [null_resource.gateway_api_crds]

  triggers = {
    environment = local.environment
    overlay_path = "${path.module}/../../../k8s/gateway-api/overlays/${local.environment}"
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Applying Kustomize overlay for ${local.environment}..."
      if [ -d "${self.triggers.overlay_path}" ]; then
        kubectl apply -k ${self.triggers.overlay_path}
        echo "Kustomize overlay applied successfully!"
      else
        echo "Warning: Overlay path not found: ${self.triggers.overlay_path}"
        echo "Skipping Kustomize deployment."
      fi
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "Preserving Kustomize resources on destroy."
      echo "To remove manually, run: kubectl delete -k ${self.triggers.overlay_path}"
    EOT
    on_failure = continue
  }
}

# ============================================
# STEP 10: Create App Namespace
# ============================================

resource "kubernetes_namespace" "app_namespace" {
  metadata {
    name = var.namespace
  }
}

# ============================================
# STEP 11: Create Main Gateway
# ============================================
resource "kubernetes_manifest" "main_gateway" {
  count = var.deploy_gateway ? 1 : 0

  depends_on = [
    null_resource.gateway_api_crds,
    helm_release.nginx_gateway_fabric,
    kubernetes_namespace.app_namespace
  ]

  manifest = jsondecode(templatefile("${path.module}/templates/gateway.json.tpl", {
    gateway_name       = var.gateway_name
    namespace          = var.namespace
    gateway_class_name = var.enable_nginx_gateway ? var.nginx_gateway_class_name : var.istio_gateway_class_name
    enable_https       = var.enable_https
    tls_secret_name    = var.tls_certificate_secret_name
    tls_namespace      = var.tls_certificate_namespace != "" ? var.tls_certificate_namespace : var.namespace
  }))
}

# ============================================
# STEP 12: NodePort Service for Gateway (Minikube/Local)
# ============================================

resource "kubernetes_service" "gateway_nodeport" {
  count = var.deploy_gateway && var.enable_nginx_gateway ? 1 : 0

  depends_on = [
    helm_release.nginx_gateway_fabric,
    kubernetes_manifest.main_gateway
  ]

  metadata {
    name      = "gateway-nodeport"
    namespace = var.nginx_gateway_namespace
  }

  spec {
    type = "NodePort"

    selector = {
      "app.kubernetes.io/name" = "nginx-gateway-fabric"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 80
      node_port   = var.gateway_nodeport_port
      protocol    = "TCP"
    }

    dynamic "port" {
      for_each = var.enable_https ? [1] : []
      content {
        name        = "https"
        port        = 443
        target_port = 443
        node_port   = var.https_nodeport_port
        protocol    = "TCP"
      }
    }
  }
}

# ============================================
# STEP 13: Wait for Gateway to be Ready
# ============================================
resource "time_sleep" "wait_for_gateway" {
  count = var.deploy_gateway ? 1 : 0

  depends_on = [
    null_resource.gateway_api_crds,
    helm_release.nginx_gateway_fabric,
    helm_release.istiod,
    helm_release.gateway_api,
    null_resource.kustomize_apply,
    kubernetes_manifest.main_gateway,
    kubernetes_service.gateway_nodeport
  ]

  create_duration = "60s"
}
