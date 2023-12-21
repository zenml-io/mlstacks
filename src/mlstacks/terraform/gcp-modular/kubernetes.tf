# a default (non-aliased) provider configuration for "kubernetes"
# not defining the kubernetes provider throws an error while running the eks module
provider "kubernetes" {
  host                   = (data.external.get_cluster.result != null) ? "https://${lookup(data.external.get_cluster.result, "endpoint", "")}" : ""
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = (data.external.get_cluster.result != null) ? base64decode(lookup(data.external.get_cluster.result, "ca_certificate", "")) : ""
}

provider "kubectl" {
  host                   = (data.external.get_cluster.result != null) ? "https://${lookup(data.external.get_cluster.result, "endpoint", "")}" : ""
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = (data.external.get_cluster.result != null) ? base64decode(lookup(data.external.get_cluster.result, "ca_certificate", "")) : ""
}

# the namespace where zenml will run kubernetes orchestrator workloads
resource "kubernetes_namespace" "k8s-workloads" {
  count = (var.enable_orchestrator_kubeflow || var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
    var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow ||
  var.enable_zenml) ? 1 : 0
  metadata {
    name = local.gke.workloads_namespace
  }
  depends_on = [
    google_container_cluster.gke,
  ]
}

# tie the kubernetes workloads SA to the GKE service account
resource "null_resource" "k8s-sa-workload-access" {
  count = (var.enable_orchestrator_kubeflow || var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
    var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow ||
  var.enable_zenml) ? 1 : 0
  provisioner "local-exec" {
    command = "kubectl -n ${kubernetes_namespace.k8s-workloads[0].metadata[0].name} annotate serviceaccount default iam.gke.io/gcp-service-account=${google_service_account.gke-service-account[0].email} --overwrite=true"
  }

  depends_on = [
    google_container_cluster.gke,
  ]
}

# allow the kubernetes workloads sa to access GKE's IAM role
# the GKE IAM role should have access to GCS, the GCP Secrets Manager and the
# Vertex AI resources, which are needed for ZenML pipelines
resource "google_service_account_iam_member" "k8s-workload-access" {
  count = (var.enable_orchestrator_kubeflow || var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
    var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow ||
  var.enable_zenml) ? 1 : 0
  service_account_id = google_service_account.gke-service-account[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${kubernetes_namespace.k8s-workloads[0].metadata[0].name}/default]"
  depends_on = [
    kubernetes_namespace.k8s-workloads,
  ]
}
