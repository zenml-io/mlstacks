# a default (non-aliased) provider configuration for "kubernetes"
# not defining the kubernetes provider throws an error while running the eks module
provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "kubectl" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

# the namespace where zenml will run kubernetes orchestrator workloads
resource "kubernetes_namespace" "k8s-workloads" {
  metadata {
    name = local.gke.workloads_namespace
  }
  depends_on = [
    module.gke,
  ]
}

# tie the kubernetes workloads SA to the GKE service account
resource "null_resource" "k8s-sa-workload-access" {
  provisioner "local-exec" {
    command = "kubectl -n ${kubernetes_namespace.k8s-workloads.metadata[0].name} annotate serviceaccount default iam.gke.io/gcp-service-account=${google_service_account.gke-service-account.email} --overwrite=true"
  }

  depends_on = [
    module.gke,
  ]
}

# allow the kubernetes workloads sa to access GKE's IAM role
# the GKE IAM role should have access to GCS, the GCP Secrets Manager and the
# Vertex AI resources, which are needed for ZenML pipelines
resource "google_service_account_iam_member" "k8s-workload-access" {
  service_account_id = google_service_account.gke-service-account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[${kubernetes_namespace.k8s-workloads.metadata[0].name}/default]"
  depends_on = [
    kubernetes_namespace.k8s-workloads,
  ]
}
