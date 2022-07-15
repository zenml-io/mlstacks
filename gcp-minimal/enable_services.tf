# You must have owner, editor, service config editor roles 
# to be able to enable services.

# enable secret manager
resource "null_resource" "enable-secretmanager" {
  provisioner "local-exec" {
    command = "gcloud services enable secretmanager.googleapis.com --project=${local.project_id}"
  }
}

# enable container registry
resource "null_resource" "enable-containerregistry" {
  provisioner "local-exec" {
    command = "gcloud services enable containerregistry.googleapis.com --project=${local.project_id}"
  }
}