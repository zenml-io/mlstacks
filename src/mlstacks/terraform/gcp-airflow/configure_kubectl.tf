# set up local kubectl client to access the newly created cluster
resource "null_resource" "configure-local-kubectl" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_composer_environment.zenml-airflow.config[0].gke_cluster} --region ${local.airflow.region} --project ${local.project_id}"
  }
}