# using the seldon module for creating a 
# seldon + istio deployment
module "seldon" {
  source = "./seldon"

  # run only after the eks cluster is set up
  depends_on = [google_container_cluster.gke]

  # details about the seldon deployment
  seldon_name      = local.seldon.name
  seldon_namespace = local.seldon.namespace

  # details about the cluster
  cluster_endpoint       = "https://${google_container_cluster.gke.endpoint}"
  cluster_ca_certificate = data.google_client_config.default.access_token
  cluster_token          = base64decode(google_container_cluster.gke.ca_certificate)
}

resource "kubernetes_namespace" "seldon-workloads" {
  metadata {
    name = "zenml-seldon-workloads"
  }
}
