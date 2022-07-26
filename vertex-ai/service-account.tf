resource "google_service_account" "sa" {
  account_id   = local.service_account.account_id
  project      = local.project_id
  display_name = "${local.prefix}-${local.service_account.account_id}"
}

resource "google_project_iam_binding" "ai-customcode" {
  project = local.project_id
  role    = "roles/aiplatform.customCodeServiceAgent"

  members = [
    "serviceAccount:${google_service_account.sa.email}",
  ]
}

resource "google_project_iam_binding" "ai-serviceagent" {
  project = local.project_id
  role    = "roles/aiplatform.serviceAgent"

  members = [
    "serviceAccount:${google_service_account.sa.email}",
  ]
}

resource "google_project_iam_binding" "container-registry" {
  project = local.project_id
  role    = "roles/containerregistry.ServiceAgent"

  members = [
    "serviceAccount:${google_service_account.sa.email}",
  ]
}

resource "google_project_iam_binding" "secret-manager" {
  project = local.project_id
  role    = "roles/secretmanager.admin"

  members = [
    "serviceAccount:${google_service_account.sa.email}",
  ]
}

resource "google_project_iam_binding" "serviceaccount-user" {
  project = local.project_id
  role    = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${google_service_account.sa.email}",
  ]
}