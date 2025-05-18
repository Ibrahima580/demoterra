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
            limits = {
              memory = "256Mi"
              cpu    = "500m"
            }

            requests = {
              memory = "128Mi"
              cpu    = "150m"
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

