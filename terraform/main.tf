provider "kubernetes" {
  config_path = "/var/lib/jenkins/.kube/config"
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "myapp"
  }
}

