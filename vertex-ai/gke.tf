data "google_client_config" "default" {}
resource "google_container_cluster" "gke" {
  name               = "${local.prefix}-${local.gke.cluster_name}"
  location           = local.region
  initial_node_count = 1
  count              = local.enable_mlflow ? 1 : 0

  node_config {
    service_account = google_service_account.gke-service-account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    machine_type = "e2-medium"
  }

  depends_on = [
    google_project_service.compute_engine_api
  ]
}

# service account for GKE nodes
resource "google_service_account" "gke-service-account" {
  account_id   = local.gke.service_account_name
  project      = local.project_id
  display_name = "Terraform GKE SA"
}

resource "google_project_iam_binding" "gke-container-registry" {
  project = local.project_id
  role    = "roles/containerregistry.ServiceAgent"

  members = [
    "serviceAccount:${google_service_account.gke-service-account.email}",
  ]
}

resource "google_project_iam_binding" "gke-secret-manager" {
  project = local.project_id
  role    = "roles/secretmanager.admin"

  members = [
    "serviceAccount:${google_service_account.gke-service-account.email}",
  ]
}

resource "google_project_iam_binding" "gke-cloudsql" {
  project = local.project_id
  role    = "roles/cloudsql.admin"

  members = [
    "serviceAccount:${google_service_account.gke-service-account.email}",
  ]
}

resource "google_project_iam_binding" "gke-storageadmin" {
  project = local.project_id
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.gke-service-account.email}",
  ]
}