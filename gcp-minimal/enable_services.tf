# You must have owner, editor, or service config editor roles 
# to be able to enable services.

# enable secret manager
resource "google_project_service" "secret_manager" {
  project = local.project_id
  service = "secretmanager.googleapis.com"
  
  disable_dependent_services = true
}

# enable container registry
resource "google_project_service" "container_registry" {
  project = local.project_id
  service = "containerregistry.googleapis.com"
  
  disable_dependent_services = true
}

# enable container API
resource "google_project_service" "container_api" {
  project = local.project_id
  service = "container.googleapis.com"
  
  disable_dependent_services = true
}

# enable compute engine API
resource "google_project_service" "compute_engine_api" {
  project = local.project_id
  service = "compute.googleapis.com"
  
  disable_dependent_services = true
}

# enable cloud resource manager API
resource "google_project_service" "cloud_resource_manager_api" {
  project = local.project_id
  service = "cloudresourcemanager.googleapis.com"
  
  disable_dependent_services = true
}
