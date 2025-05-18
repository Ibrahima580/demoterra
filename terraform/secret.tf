resource "kubernetes_secret" "postgres_credentials" {
  metadata {
    name = "postgres-credentials"
  }

  type = "Opaque"

  string_data = {
    POSTGRES_USER     = "odc"
    POSTGRES_PASSWORD = "odc123"
    POSTGRES_DB       = "odcdb"
  }
}

