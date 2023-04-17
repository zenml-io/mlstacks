data "google_project" "project" {
  project_id = var.project_id
}

# You must have owner, editor, or service config editor roles 
# to be able to enable services.

# enable secret manager
resource "google_project_service" "secret_manager" {
  count   = var.enable_secrets_manager ? 1 : 0
  project = var.project_id
  service = "secretmanager.googleapis.com"

  disable_on_destroy = false
}

# enable container registry
resource "google_project_service" "container_registry" {
  count   = var.enable_container_registry ? 1 : 0
  project = var.project_id
  service = "containerregistry.googleapis.com"

  disable_on_destroy = false
}

# enable container API
resource "google_project_service" "container_api" {
  project = var.project_id
  service = "container.googleapis.com"

  disable_on_destroy = false
}

# enable compute engine API
resource "google_project_service" "compute_engine_api" {
  project = var.project_id
  service = "compute.googleapis.com"

  disable_on_destroy = false
}

# enable cloud resource manager API
resource "google_project_service" "cloud_resource_manager_api" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"

  disable_on_destroy = false
}

# enable vertex ai
resource "google_project_service" "vertex_ai" {
  project = var.project_id
  service = "aiplatform.googleapis.com"

  disable_on_destroy = false
}
