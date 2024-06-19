data "google_client_config" "default" {}
# module "gke" {
#   count = (var.enable_orchestrator_kubeflow || var.enable_orchestrator_tekton
#   || var.enable_orchestrator_kubernetes ||  
#   var.enable_model_deployer_huggingface || var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow ||
#             var.enable_zenml)? 1: 0

#   depends_on = [
#     google_project_service.compute_engine_api
#   ]

#   source            = "terraform-google-modules/kubernetes-engine/google"
#   project_id        = var.project_id
#   name              = "${local.prefix}-${local.gke.cluster_name}"
#   region            = var.region
#   zones             = ["${var.region}-a", "${var.region}-b", "${var.region}-c"]
#   network           = module.vpc.network_name
#   subnetwork        = module.vpc.subnets_names[0]
#   ip_range_pods     = "gke-pods"
#   ip_range_services = "gke-services"

#   kubernetes_version         = local.gke.cluster_version
#   http_load_balancing        = false
#   network_policy             = false
#   horizontal_pod_autoscaling = true
#   filestore_csi_driver       = false

#   node_pools = [
#     {
#       name            = "default-node-pool"
#       machine_type    = "e2-standard-8"
#       node_locations  = "${var.region}-b"
#       min_count       = 1
#       max_count       = 3
#       local_ssd_count = 0
#       disk_size_gb    = 100
#       disk_type       = "pd-standard"
#       image_type      = "COS_CONTAINERD"
#       enable_gcfs     = false
#       auto_repair     = true
#       auto_upgrade    = true
#       service_account = google_service_account.gke-service-account[0].email

#       preemptible        = false
#       initial_node_count = 1
#     },
#   ]

#   node_pools_oauth_scopes = {
#     all = []

#     default-node-pool = [
#       "https://www.googleapis.com/auth/cloud-platform",
#     ]
#   }

#   node_pools_labels = {
#     all = {}

#     default-node-pool = {
#       default-node-pool = true
#     }
#   }
# }
locals {
  enable_gke = (var.enable_orchestrator_kubeflow || var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
    var.enable_model_deployer_huggingface || var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow ||
  var.enable_zenml)
}

data "external" "get_cluster" {
  program = ["bash", "${path.module}/get_cluster.sh"]
  query = {
    project_id   = var.project_id
    cluster_name = local.enable_gke ? google_container_cluster.gke[0].name : "${local.prefix}-${local.gke.cluster_name}"
    region       = var.region
  }
}

resource "google_container_cluster" "gke" {
  count = (var.enable_orchestrator_kubeflow || var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
    var.enable_model_deployer_huggingface || var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow ||
  var.enable_zenml) ? 1 : 0

  name    = "${local.prefix}-${local.gke.cluster_name}"
  project = var.project_id

  location           = var.region
  node_locations     = ["${var.region}-a", "${var.region}-b", "${var.region}-c"]
  initial_node_count = 1

  network    = module.vpc[0].network_name
  subnetwork = module.vpc[0].subnets_names[0]
  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }
  node_config {
    machine_type = "e2-standard-8"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke-service-account[0].email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  timeouts {
    create = "30m"
    update = "40m"
  }

  depends_on = [
    google_project_service.compute_engine_api
  ]
}

# service account for GKE nodes
resource "google_service_account" "gke-service-account" {
  count = (var.enable_orchestrator_kubeflow || var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
    var.enable_model_deployer_huggingface || var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow ||
  var.enable_zenml) ? 1 : 0
  account_id   = "${local.prefix}-${local.gke.service_account_name}"
  project      = var.project_id
  display_name = "Terraform GKE SA"
}

resource "google_project_iam_binding" "container-registry" {
  count   = length(google_container_cluster.gke)
  project = var.project_id
  role    = "roles/containerregistry.ServiceAgent"

  members = [
    "serviceAccount:${google_service_account.gke-service-account[0].email}",
  ]
}

resource "google_project_iam_binding" "secret-manager" {
  count = (var.enable_orchestrator_kubeflow || var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
    var.enable_model_deployer_huggingface || var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow ||
  var.enable_zenml) ? 1 : 0
  project = var.project_id
  role    = "roles/secretmanager.admin"

  members = [
    "serviceAccount:${google_service_account.gke-service-account[0].email}",
  ]
}

resource "google_project_iam_binding" "cloudsql" {
  count = (var.enable_orchestrator_kubeflow || var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
    var.enable_model_deployer_huggingface || var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow ||
  var.enable_zenml) ? 1 : 0
  project = var.project_id
  role    = "roles/cloudsql.admin"

  members = [
    "serviceAccount:${google_service_account.gke-service-account[0].email}",
  ]
}

resource "google_project_iam_binding" "storageadmin" {
  count = (var.enable_orchestrator_kubeflow || var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
    var.enable_model_deployer_huggingface || var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow ||
  var.enable_zenml) ? 1 : 0
  project = var.project_id
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.gke-service-account[0].email}",
  ]
}

resource "google_project_iam_binding" "vertex-ai-user" {
  count = (var.enable_orchestrator_kubeflow || var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
    var.enable_model_deployer_huggingface || var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow ||
  var.enable_zenml) ? 1 : 0
  project = var.project_id
  role    = "roles/aiplatform.user"

  members = [
    "serviceAccount:${google_service_account.gke-service-account[0].email}",
  ]
}
