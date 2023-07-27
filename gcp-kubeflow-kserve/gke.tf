data "google_client_config" "default" {}
module "gke" {
  depends_on = [
    google_project_service.compute_engine_api
  ]

  source            = "terraform-google-modules/kubernetes-engine/google"
  project_id        = local.project_id
  name              = "${local.prefix}-${local.gke.cluster_name}"
  region            = local.region
  zones             = ["${local.region}-a", "${local.region}-b", "${local.region}-c"]
  network           = module.vpc.network_name
  subnetwork        = module.vpc.subnets_names[0]
  ip_range_pods     = "gke-pods"
  ip_range_services = "gke-services"

  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false

  node_pools = [
    {
      name            = "default-node-pool"
      machine_type    = "e2-standard-4"
      node_locations  = "${local.region}-b"
      min_count       = 1
      max_count       = 3
      local_ssd_count = 0
      disk_size_gb    = 100
      disk_type       = "pd-standard"
      image_type      = "COS_CONTAINERD"
      enable_gcfs     = false
      auto_repair     = true
      auto_upgrade    = true
      service_account = google_service_account.gke-service-account.email

      preemptible        = false
      initial_node_count = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }
}

# service account for GKE nodes
resource "google_service_account" "gke-service-account" {
  account_id   = "${local.prefix}-${local.gke.service_account_name}"
  project      = local.project_id
  display_name = "Terraform GKE SA"
}

resource "google_project_iam_binding" "container-registry" {
  project = local.project_id
  role    = "roles/containerregistry.ServiceAgent"

  members = [
    "serviceAccount:${google_service_account.gke-service-account.email}",
  ]
}

resource "google_project_iam_binding" "secret-manager" {
  project = local.project_id
  role    = "roles/secretmanager.admin"

  members = [
    "serviceAccount:${google_service_account.gke-service-account.email}",
  ]
}

resource "google_project_iam_binding" "cloudsql" {
  project = local.project_id
  role    = "roles/cloudsql.admin"

  members = [
    "serviceAccount:${google_service_account.gke-service-account.email}",
  ]
}

resource "google_project_iam_binding" "storageadmin" {
  project = local.project_id
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.gke-service-account.email}",
  ]
}