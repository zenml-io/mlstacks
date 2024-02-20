# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# using the mlflow module to create an mlflow deployment
module "mlflow" {
  source = "./mlflow-module"

  # run only after the eks cluster is set up
  depends_on = [module.gke]
  count      = var.enable_mlflow ? 1 : 0

  # details about the mlflow deployment
  htpasswd                = "${var.mlflow-username}:${htpasswd_password.hash.apr1}"
  artifact_Proxied_Access = local.mlflow.artifact_Proxied_Access
  artifact_GCS            = local.mlflow.artifact_GCS
  artifact_GCS_Bucket     = local.mlflow.artifact_GCS_Bucket == "" ? google_storage_bucket.artifact-store.name : local.mlflow.artifact_GCS_Bucket

  # set workload identity annotations for mlflow kubernetes sa
  kubernetes_sa = google_service_account.gke-service-account.email
}

resource "htpasswd_password" "hash" {
  password = var.mlflow-password
}

# allow the mlflow kubernetes sa to access GKE's IAM role
# the GKE IAM role should have access to Storage resources
resource "google_service_account_iam_member" "mlflow-storage-access" {
  service_account_id = google_service_account.gke-service-account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[default/mlflow-tracking]"
  depends_on = [
    module.mlflow
  ]
}
