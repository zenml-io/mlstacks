# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# using the seldon module for creating a 
# seldon + istio deployment
module "seldon" {
  source = "./seldon"

  # run only after the aks cluster is set up
  depends_on = [azurerm_kubernetes_cluster.aks]

  # details about the seldon deployment
  seldon_name      = local.seldon.name
  seldon_namespace = local.seldon.namespace

  # details about the cluster (not required since the configuration 
  # in the caller is inherited into the seldon module)
  cluster_endpoint       = ""
  cluster_ca_certificate = ""
  cluster_token          = ""
}

resource "kubernetes_namespace" "seldon-workloads" {
  metadata {
    name = "zenml-seldon-workloads"
  }
}


# add role to allow kubeflow to access kserve
resource "kubernetes_cluster_role_v1" "seldon" {
  metadata {
    name = "seldon-permission"
    labels = {
      app = "zenml"
    }
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  depends_on = [
    module.seldon,
  ]
}

# assign role to kubeflow pipeline runner
resource "kubernetes_cluster_role_binding_v1" "binding" {
  metadata {
    name = "seldon-permission-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.seldon.metadata[0].name
  }
  subject {
    kind = "User"
    name = "system:serviceaccount:kubeflow:pipeline-runner"
  }
}

