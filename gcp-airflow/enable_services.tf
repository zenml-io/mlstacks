# You must have owner, editor, or service config editor roles 
# to be able to enable services.

# services to enable
locals {
  services_to_enable = [
    "secretmanager.googleapis.com",
    "containerregistry.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "composer.googleapis.com",
  ]
}

# enable services
resource "google_project_service" "enable_services" {
  project = local.project_id

  for_each = toset(local.services_to_enable)
  service  = each.value

  disable_on_destroy = false
}
