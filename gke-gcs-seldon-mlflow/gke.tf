data "google_client_config" "default" {}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = local.project_id
  name                       = "${local.prefix}-${local.gke.cluster_name}"
  region                     = local.region
  zones                      = ["${local.region}-a", "${local.region}-b", "${local.region}-c"]
  # network                    = "${local.prefix}-${local.vpc.name}"
  # subnetwork                 = "${local.prefix}-${local.vpc.name}-01"
  # ip_range_pods              = "${local.region}-01-gke-01-pods"
  # ip_range_services          = "${local.region}-01-gke-01-services"
  network                    = module.vpc.network_name
  subnetwork                 = module.vpc.subnets_names[0]
  ip_range_pods              = "gke-pods"
  ip_range_services          = "gke-services"

  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false

  node_pools = [
    {
      name                      = "default-node-pool"
      machine_type              = "e2-medium"
      node_locations            = "${local.region}-b"
      min_count                 = 1
      max_count                 = 3
      local_ssd_count           = 0
      disk_size_gb              = 100
      disk_type                 = "pd-standard"
      image_type                = "COS_CONTAINERD"
      enable_gcfs               = false
      auto_repair               = true
      auto_upgrade              = true
      # service_account           = "${local.prefix}-${local.gke.service_account_name}@${local.project_id}.iam.gserviceaccount.com"
      preemptible               = false
      initial_node_count        = 1
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