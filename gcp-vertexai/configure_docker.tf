# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# set up local docker client to access the newly created registry
resource "null_resource" "configure-local-docker" {
  provisioner "local-exec" {
    command = "gcloud auth configure-docker --project ${local.project_id}"
  }

}
