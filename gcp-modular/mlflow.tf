# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# using the mlflow module to create an mlflow deployment
module "mlflow" {
  source = "../modules/mlflow-module"

  count = var.enable_experiment_tracker_mlflow ? 1 : 0

  # run only after the gke cluster, cert-manager and nginx-ingress are set up
  depends_on = [
    google_container_cluster.gke,
    null_resource.configure-local-kubectl,
    module.cert-manager,
    module.nginx-ingress
  ]

  # details about the mlflow deployment
  chart_version           = local.mlflow.version
  htpasswd                = "${var.mlflow-username}:${htpasswd_password.hash.apr1}"
  ingress_host            = "${local.mlflow.ingress_host_prefix}.${module.nginx-ingress[0].ingress-ip-address}.nip.io"
  artifact_Proxied_Access = local.mlflow.artifact_Proxied_Access
  artifact_GCS            = local.mlflow.artifact_GCS
  artifact_GCS_Bucket     = var.mlflow_bucket == "" ? google_storage_bucket.mlflow-bucket[0].name : var.mlflow_bucket
}

resource "random_string" "mlflow_bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "google_storage_bucket" "mlflow-bucket" {
  count    = (var.enable_experiment_tracker_mlflow && var.mlflow_bucket == "") ? 1 : 0
  name     = "mlflow-gcs-${random_string.mlflow_bucket_suffix.result}"
  project  = var.project_id
  location = local.gcs.location

  force_destroy = true

  uniform_bucket_level_access = true
}

resource "htpasswd_password" "hash" {
  password = var.mlflow-password
}

# tie the mlflow kubernetes SA to the GKE service account
resource "null_resource" "mlflow-sa-workload-access" {

  count = var.enable_experiment_tracker_mlflow ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl -n mlflow annotate serviceaccount mlflow-tracking iam.gke.io/gcp-service-account=${google_service_account.gke-service-account[0].email} --overwrite=true"
  }

  depends_on = [
    module.mlflow,
  ]
}

# # allow the mlflow kubernetes sa to access GKE's IAM role
# # the GKE IAM role should have access to Storage resources
resource "google_service_account_iam_member" "mlflow-storage-access" {

  count = var.enable_experiment_tracker_mlflow ? 1 : 0

  service_account_id = google_service_account.gke-service-account[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[mlflow/mlflow-tracking]"
  depends_on = [
    module.mlflow
  ]
}
