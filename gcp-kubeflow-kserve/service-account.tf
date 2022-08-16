# service account for GKE nodes
resource "google_service_account" "gke-service-account" {
  account_id   = local.service_account_gke.account_id
  project      = local.project_id
  display_name = "Terraform GKE SA"
}

resource "google_project_iam_binding" "container-registry" {
  project = local.project_id
  role    = "roles/containerregistry.ServiceAgent"

  members = [
    "serviceAccount:${google_service_account.gke-service-account.email}",
  ]
}

resource "google_project_iam_binding" "secret-manager" {
  project = local.project_id
  role    = "roles/secretmanager.admin"

  members = [
    "serviceAccount:${google_service_account.gke-service-account.email}",
  ]
}

resource "google_project_iam_binding" "secret-manager" {
  project = local.project_id
  role    = "roles/cloudsql.admin"

  members = [
    "serviceAccount:${google_service_account.gke-service-account.email}",
  ]
}

resource "google_project_iam_binding" "secret-manager" {
  project = local.project_id
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.gke-service-account.email}",
  ]
}