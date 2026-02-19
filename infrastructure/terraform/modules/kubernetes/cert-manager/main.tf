# Cert-Manager Module - Terraform
# Manages cert-manager installation and Let's Encrypt configuration

locals {
  # Environment-specific Let's Encrypt server
  acme_server = var.environment == "prod" ? "https://acme-v02.api.letsencrypt.org/directory" : "https://acme-staging-v02.api.letsencrypt.org/directory"
}

# ============================================
# STEP 1: Install Cert-Manager via Helm
# ============================================
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_version

  create_namespace = true

  set {
    name  = "crds.enabled"
    value = "true"
  }

  set {
    name  = "webhook.enabled"
    value = "true"
  }

  set {
    name  = "cainjector.enabled"
    value = "true"
  }

  set {
    name  = "startupapicheck.enabled"
    value = "true"
  }

  timeout         = 300
  cleanup_on_fail = true
}

# ============================================
# STEP 2: Cloudflare API Token Secret
# ============================================
resource "kubernetes_secret" "cloudflare_api_token" {
  depends_on = [helm_release.cert_manager]

  metadata {
    name      = "cloudflare-api-token"
    namespace = "cert-manager"
  }

  data = {
    "api-token" = var.cloudflare_api_token
  }

  type = "Opaque"
}

# ============================================
# STEP 3: ClusterIssuer for Let's Encrypt Staging
# ============================================
resource "kubernetes_manifest" "letsencrypt_staging" {
  depends_on = [
    helm_release.cert_manager,
    kubernetes_secret.cloudflare_api_token
  ]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-staging"
    }
    spec = {
      acme = {
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        email  = var.acme_email
        privateKeySecretRef = {
          name = "letsencrypt-staging"
        }
        solvers = [
          {
            dns01 = {
              cloudflare = {
                apiTokenSecretRef = {
                  name = kubernetes_secret.cloudflare_api_token.metadata[0].name
                  key  = "api-token"
                }
              }
            }
          }
        ]
      }
    }
  }
}

# ============================================
# STEP 4: ClusterIssuer for Let's Encrypt Production
# ============================================
resource "kubernetes_manifest" "letsencrypt_prod" {
  depends_on = [
    helm_release.cert_manager,
    kubernetes_secret.cloudflare_api_token
  ]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.acme_email
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [
          {
            dns01 = {
              cloudflare = {
                apiTokenSecretRef = {
                  name = kubernetes_secret.cloudflare_api_token.metadata[0].name
                  key  = "api-token"
                }
              }
            }
          }
        ]
      }
    }
  }
}

# ============================================
# STEP 5: Certificate for Wildcard Domain
# ============================================
resource "kubernetes_manifest" "certificate" {
  depends_on = [
    kubernetes_manifest.letsencrypt_staging,
    kubernetes_manifest.letsencrypt_prod
  ]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "${replace(var.domain_name, ".", "-")}-tls"
      namespace = var.namespace
    }
    spec = {
      secretName = "${replace(var.domain_name, ".", "-")}-tls"
      issuerRef = {
        name = var.environment == "prod" ? "letsencrypt-prod" : "letsencrypt-staging"
        kind = "ClusterIssuer"
      }
      dnsNames = var.include_apex_domain ? [
        var.domain_name,
        "*.${var.domain_name}"
      ] : [
        "*.${var.domain_name}"
      ]
    }
  }
}

# ============================================
# STEP 6: Wait for Certificate to be Ready
# ============================================
resource "null_resource" "wait_for_certificate" {
  depends_on = [kubernetes_manifest.certificate]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for certificate to be ready..."
      kubectl wait --for=condition=Ready certificate/${replace(var.domain_name, ".", "-")}-tls -n ${var.namespace} --timeout=300s || echo "Certificate may still be issuing..."
    EOT
  }

  triggers = {
    certificate_name = kubernetes_manifest.certificate.manifest.metadata.name
    namespace        = var.namespace
    always_run       = timestamp()
  }
}
