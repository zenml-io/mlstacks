# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# set up local kubectl client to access the newly created cluster
resource "null_resource" "configure-local-kubectl" {
  count = var.enable_mlflow ? 1 : 0
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${module.gke[0].name} --region ${local.region} --project ${local.project_id}"
  }
}
