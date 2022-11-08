data "google_project" "project" {
  project_id = local.project_id
}

resource "google_composer_environment" "zenml-airflow" {
  name   = "${local.prefix}-${local.airflow.environment_name}"
  region = local.airflow.region
  config {

    software_config {
      image_version = "composer-2-airflow-2"
    }

    environment_size = local.airflow.environment_size

    node_config {
      service_account = google_service_account.env-sa.name
    }
  }

  depends_on = [
    google_project_service.enable_services
  ]
}

# service account to use for composer environment
resource "google_service_account" "env-sa" {
  account_id   = "${local.prefix}-${local.airflow.environment_service_account}"
  display_name = "Service Account for ZenML Composer Environment"
}

# define roles to give to the env service account
locals {
  roles_to_grant_to_env_service_account = [
    "roles/containerregistry.ServiceAgent",
    "roles/secretmanager.admin",
    "roles/storage.admin",
    "roles/composer.worker",
  ]
}

resource "google_project_iam_member" "roles-env-sa" {
  project = local.project_id

  member   = "serviceAccount:${google_service_account.env-sa.email}"
  for_each = toset(local.roles_to_grant_to_env_service_account)
  role     = each.value
}

# allow cloud composer service account access to env sa to add k8s bindings
resource "google_service_account_iam_member" "cc-sa-extension" {
  provider           = google-beta
  service_account_id = google_service_account.env-sa.email
  role               = "roles/composer.ServiceAgentV2Ext"
  member             = "serviceAccount:service-${data.google_project.project.number}@cloudcomposer-accounts.iam.gserviceaccount.com"

  depends_on = [
    google_project_service.enable_services
  ]
}