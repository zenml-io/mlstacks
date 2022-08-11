data "google_client_config" "default" {}
resource "google_container_cluster" "gke" {
  name               = "${local.prefix}-${local.gke.cluster_name}"
  location           = local.region
  initial_node_count = 1

  node_config {
    service_account = google_service_account.gke-service-account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    machine_type = "e2-standard-4"
  }
}