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

