# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# create kserve module
module "kserve" {
  source = "./kserve-module"

  workloads_namespace = local.kserve.workloads_namespace

  depends_on = [
    module.eks,
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
