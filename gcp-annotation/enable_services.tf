# You must have owner, editor, or service config editor roles 
# to be able to enable services.

# enable secret manager
resource "google_project_service" "secret_manager" {
  project = local.project_id
  service = "secretmanager.googleapis.com"

  disable_dependent_services = true
}
# enable cloud resource manager API
resource "google_project_service" "cloud_resource_manager_api" {
  project = local.project_id
  service = "cloudresourcemanager.googleapis.com"

  disable_dependent_services = true
}