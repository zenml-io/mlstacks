# using the seldon module for creating a 
# seldon + istio deployment
module "seldon" {
  source = "./seldon"

  # run only after the eks cluster is set up
  depends_on = [module.gke]

  # details about the seldon deployment
  seldon_name      = local.seldon.name
  seldon_namespace = local.seldon.namespace

  # details about the cluster
  cluster_endpoint       = "https://${module.gke.endpoint}"
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  cluster_token          = data.google_client_config.default.access_token
}

resource "kubernetes_namespace" "seldon-workloads" {
  metadata {
    name = "zenml-seldon-workloads"
  }
}
