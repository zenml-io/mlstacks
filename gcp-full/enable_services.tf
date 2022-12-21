# You must have owner, editor, or service config editor roles 
# to be able to enable services.

# enable secret manager
resource "google_project_service" "secret_manager" {
  project = local.project_id
  service = "secretmanager.googleapis.com"

  disable_on_destroy = false
}

# enable container registry
resource "google_project_service" "container_registry" {
  project = local.project_id
  service = "containerregistry.googleapis.com"

  disable_on_destroy = false
}

# enable container API
resource "google_project_service" "container_api" {
  project = local.project_id
  service = "container.googleapis.com"

  disable_on_destroy = false
}

# enable compute engine API
resource "google_project_service" "compute_engine_api" {
  project = local.project_id
  service = "compute.googleapis.com"

  disable_on_destroy = false
}

# enable cloud resource manager API
resource "google_project_service" "cloud_resource_manager_api" {
  project = local.project_id
  service = "cloudresourcemanager.googleapis.com"

  disable_on_destroy = false
}

# enable vertex ai
resource "google_project_service" "vertex_ai" {
  project = local.project_id
  service = "aiplatform.googleapis.com"

  disable_on_destroy = false
}