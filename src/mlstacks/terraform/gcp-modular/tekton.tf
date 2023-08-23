# using the tekton pipelines module to create a tekton pipelines deployment
module "tekton-pipelines" {
  source = "../modules/tekton-pipelines-module"

  count = var.enable_orchestrator_tekton ? 1 : 0

  # run only after the gke cluster is set up and cert-manager and nginx-ingress
  # are installed 
  depends_on = [
    google_container_cluster.gke,
    null_resource.configure-local-kubectl,
    module.cert-manager,
    module.nginx-ingress,
  ]

  pipeline_version  = local.tekton.version
  dashboard_version = local.tekton.dashboard_version
  ingress_host      = "${local.tekton.ingress_host_prefix}.${module.nginx-ingress[0].ingress-ip-address}.nip.io"
}

# the namespace where zenml will run tekton pipelines
resource "kubernetes_namespace" "tekton-workloads" {

  count = var.enable_orchestrator_tekton ? 1 : 0

  metadata {
    name = local.tekton.workloads_namespace
  }

  depends_on = [
    module.tekton-pipelines,
  ]
}

# tie the tekton kubernetes SA to the GKE service account
resource "null_resource" "tekton-sa-workload-access" {

  count = var.enable_orchestrator_tekton ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl -n ${kubernetes_namespace.tekton-workloads[0].metadata[0].name} annotate serviceaccount default iam.gke.io/gcp-service-account=${google_service_account.gke-service-account[0].email} --overwrite=true"
  }

  depends_on = [
    module.tekton-pipelines,
  ]
}

# allow the tekton kubernetes sa to access GKE's IAM role
# the GKE IAM role should have access to GCS, the GCP Secrets Manager and the
# Vertex AI resources, which are needed for ZenML pipelines
resource "google_service_account_iam_member" "tekton-workload-access" {

  count = var.enable_orchestrator_tekton ? 1 : 0

  service_account_id = google_service_account.gke-service-account[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${kubernetes_namespace.tekton-workloads[0].metadata[0].name}/default]"
  depends_on = [
    module.tekton-pipelines
  ]
}
