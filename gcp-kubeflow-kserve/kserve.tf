# create kserve module
module "kserve" {
  source = "./kserve-module"

  workloads_namespace = local.kserve.workloads_namespace

  depends_on = [
    module.gke,
    null_resource.configure-local-kubectl,
  ]
}

# add role to allow kubeflow to access kserve
resource "kubernetes_cluster_role_v1" "kflow" {
  metadata {
    name = "kserve-permission"
    labels = {
      app = "zenml"
    }
  }

  rule {
    api_groups = ["serving.kserve.io", ""]
    resources  = ["inferenceservices", "secrets", "serviceaccounts"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  depends_on = [
    module.kserve,
    null_resource.kubeflow,
  ]
}

# assign role to kubeflow pipeline runner
resource "kubernetes_cluster_role_binding_v1" "example" {
  metadata {
    name = "kserve-permission-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.kflow.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "pipeline-runner"
    namespace = "kubeflow"
  }
}

# service account for Kserve
resource "google_service_account" "kserve-service-account" {
  account_id   = local.kserve.service_account_name
  project      = local.project_id
  display_name = "Kserve SA"
}
resource "google_project_iam_binding" "kserve-storageadmin" {
  project = local.project_id
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.kserve-service-account.email}",
  ]
}
resource "google_project_iam_binding" "kserve-container-registry" {
  project = local.project_id
  role    = "roles/containerregistry.ServiceAgent"

  members = [
    "serviceAccount:${google_service_account.kserve-service-account.email}",
  ]
}

# creating a sa key
resource "google_service_account_key" "kserve_sa_key" {
  service_account_id = google_service_account.kserve-service-account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# create the credentials file JSON
resource "local_file" "sa_key_file" {
  content  = base64decode(google_service_account_key.kserve_sa_key.private_key)
  filename = "./kserve_sa_key.json"
}