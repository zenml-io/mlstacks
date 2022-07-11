resource "random_string" "sa_id" {
  length           = 6
  special          = false
}

resource "google_service_account" "sa" {
  account_id   = random_string.sa_id
  project = local.project_id
  display_name = "A service account for the Vertex AI pipelines"
}

resource "google_service_account_iam_binding" "ai-customcode" {
  service_account_id = google_service_account.sa.name
  role               = "roles/aiplatform.customCodeServiceAgent"

  members = [
    "serviceAccount:${google_service_account.sa.email}",
  ]
}

resource "google_service_account_iam_binding" "ai-serviceagent" {
  service_account_id = google_service_account.sa.name
  role               = "roles/aiplatform.serviceAgent"

  members = [
    "serviceAccount:${google_service_account.sa.email}",
  ]
}

resource "google_service_account_iam_binding" "container-registry" {
  service_account_id = google_service_account.sa.name
  role               = "roles/containerregistry.ServiceAgent"

  members = [
    "serviceAccount:${google_service_account.sa.email}",
  ]
}

resource "google_service_account_iam_binding" "secret-manager" {
  service_account_id = google_service_account.sa.name
  role               = "roles/secretmanager.admin"

  members = [
    "serviceAccount:${google_service_account.sa.email}",
  ]
}

resource "google_service_account_iam_binding" "serviceaccount-user" {
  service_account_id = google_service_account.sa.name
  role               = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${google_service_account.sa.email}",
  ]
}