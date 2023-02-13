# set up local kubectl client to access the newly created cluster
resource "null_resource" "configure-local-kubectl" {
  count = length(google_container_cluster.gke) > 0? 1 : 0
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${local.prefix}-${local.gke.cluster_name} --region ${local.region} --project ${local.project_id}"
  }

  depends_on = [
    google_container_cluster.gke
  ]
}