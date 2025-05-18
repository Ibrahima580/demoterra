terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config" # Utilise la config Minikube locale
}

# FRONTEND
resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "front-app"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "front-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "front-app"
        }
      }

      spec {
        container {
          name  = "frontend-container"
          image = "ibrahim372/fr"
          image_pull_policy = "Always"

          port {
            container_port = 80
          }

          resources {
            requests = {
              memory = "128Mi"
              cpu    = "150m"
            }

            limits = {
              memory = "256Mi"
              cpu    = "500m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name = "front-service"
  }

  spec {
    selector = {
      app = "front-app"
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
      node_port   = 30517
    }

    type = "NodePort"
  }
}

# BACKEND
resource "kubernetes_deployment" "backend" {
  metadata {
    name = "backend"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "backend"
        }
      }

      spec {
        container {
          name  = "backend"
          image = "ibrahim372/bk"
          image_pull_policy = "Always"

          port {
            container_port = 8000
          }

          resources {
            requests = {
              memory = "128Mi"
              cpu    = "150m"
            }

            limits = {
              memory = "256Mi"
              cpu    = "500m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name = "backend"
  }

  spec {
    selector = {
      app = "backend"
    }

    port {
      port        = 8000
      target_port = 8000
      node_port   = 30519
    }

    type = "NodePort"
  }
}

# SECRET PostgreSQL
resource "kubernetes_secret" "postgres_credentials" {
  metadata {
    name = "postgres-credentials"
  }

  type = "Opaque"

  data = {
    POSTGRES_USER     = "odc"
    POSTGRES_PASSWORD = "odc123"
    POSTGRES_DB       = "odcdb"
  }
}

# PVC PostgreSQL
resource "kubernetes_persistent_volume_claim" "postgres_pvc" {
  metadata {
    name = "postgres-pvc"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

# POSTGRES DEPLOYMENT + SERVICE
resource "kubernetes_deployment" "postgres" {
  metadata {
    name = "postgres"
  }

  spec {
    replicas = 1

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
          image = "postgres:latest"

          env_from {
            secret_ref {
              name = kubernetes_secret.postgres_credentials.metadata[0].name
            }
          }

          port {
            container_port = 5432
          }

          volume_mount {
            mount_path = "/var/lib/postgresql/data"
            name       = "postgres-data"
          }

          readiness_probe {
            exec {
              command = ["pg_isready", "-U", "odc"]
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }

            limits = {
              memory = "512Mi"
              cpu    = "1000m"
            }
          }
        }

        volume {
          name = "postgres-data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name = "database"
  }

  spec {
    selector = {
      app = "postgres"
    }

    port {
      port        = 5432
      target_port = 5432
    }
  }
}

