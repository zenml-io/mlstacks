# set up local docker client to access the newly created registry
resource "null_resource" "configure-local-docker" {
  provisioner "local-exec" {
    command = "gcloud auth configure-docker --project ${local.project_id}"
  }

}