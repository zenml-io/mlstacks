# using the kubeflow pipelines module to create a kubeflow pipelines deployment
module "kubeflow-pipelines" {
  source = "../modules/kubeflow-pipelines-module"

  count = var.enable_kubeflow ? 1 : 0

  # run only after the gke cluster is set up and cert-manager and nginx-ingress
  # are installed 
  depends_on = [
    google_container_cluster.gke,
    null_resource.configure-local-kubectl,
    module.cert-manager,
    module.nginx-ingress,
  ]

  pipeline_version = local.kubeflow.version
  ingress_host     = "${local.kubeflow.ingress_host_prefix}.${module.nginx-ingress[0].ingress-ip-address}.nip.io"
}

# tie the kubeflow kubernetes SA to the GKE service account
resource "null_resource" "kubeflow-sa-workload-access" {

  count = var.enable_kubeflow ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl -n kubeflow annotate serviceaccount pipeline-runner iam.gke.io/gcp-service-account=${google_service_account.gke-service-account[0].email} --overwrite=true"
  }

  depends_on = [
    module.kubeflow-pipelines,
  ]
}

# allow the kubeflow kubernetes sa to access GKE's IAM role
# the GKE IAM role should have access to GCS, the GCP Secrets Manager and the
# Vertex AI resources, which are needed for ZenML pipelines
resource "google_service_account_iam_member" "kubeflow-workload-access" {

  count = var.enable_kubeflow ? 1 : 0

  service_account_id = google_service_account.gke-service-account[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[kubeflow/pipeline-runner]"
  depends_on = [
    module.kubeflow-pipelines
  ]
}
