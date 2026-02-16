# Secret para credenciales
resource "kubernetes_secret" "postgres" {
  metadata {
    name      = "${var.name}-secret"
    namespace = var.namespace
  }
  data = {
    # NOTE: kubernetes_secret.data expects *plain text* values; the provider
    # base64-encodes them automatically when writing to Kubernetes.
    username = var.postgres_username
    password = var.postgres_password
    database = var.postgres_database
  }
}

# StatefulSet para PostgreSQL
resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      app = "postgres"
    }
  }
  spec {
    service_name = "${var.name}-service"
    replicas     = 1
    
    selector {
      match_labels = {
        app = "postgres"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }
      spec {
        container {
          name  = "postgres"
          image = "postgres:${var.postgres_version}"
          
          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres.metadata[0].name
                key  = "username"
              }
            }
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres.metadata[0].name
                key  = "password"
              }
            }
          }
          env {
            name = "POSTGRES_DB"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres.metadata[0].name
                key  = "database"
              }
            }
          }
          
          port {
            container_port = 5432
            name           = "postgres"
          }
          
          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
          }
          
          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
    
    volume_claim_template {
      metadata {
        name = "postgres-data"
      }
      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = var.storage_class_name
        resources {
          requests = {
            storage = var.storage_size
          }
        }
      }
    }
  }
}

# Service ClusterIP (acceso interno)
resource "kubernetes_service" "postgres" {
  metadata {
    name      = "${var.name}-service"
    namespace = var.namespace
    labels = {
      app = "postgres"
    }
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "postgres"
    }
    port {
      port        = 5432
      target_port = 5432
      protocol    = "TCP"
      name        = "postgres"
    }
  }
}

# Service NodePort (acceso externo opcional)
resource "kubernetes_service" "postgres_nodeport" {
  count = var.enable_nodeport ? 1 : 0
  metadata {
    name      = "${var.name}-nodeport"
    namespace = var.namespace
    labels = {
      app = "postgres"
    }
  }
  spec {
    type = "NodePort"
    selector = {
      app = "postgres"
    }
    port {
      port        = 5432
      target_port = 5432
      node_port   = var.nodeport_port
      protocol    = "TCP"
      name        = "postgres"
    }
  }
}
