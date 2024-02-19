# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# using the tekton pipelines module to create a tekton pipelines deployment
module "tekton-pipelines" {
  source = "../modules/tekton-pipelines-module"

  count = var.enable_orchestrator_tekton ? 1 : 0

  # run only after the gke cluster is set up and cert-manager and nginx-ingress
  # are installed 
  depends_on = [
    aws_eks_cluster.cluster,
    null_resource.configure-local-kubectl,
    module.cert-manager,
    module.nginx-ingress,
  ]

  pipeline_version  = local.tekton.version
  dashboard_version = local.tekton.dashboard_version
  ingress_host      = "${local.tekton.ingress_host_prefix}.${module.nginx-ingress[0].ingress-ip-address-aws}.nip.io"
}

# the namespace where zenml will run tekton pipelines
resource "kubernetes_namespace" "tekton-workloads" {

  count = var.enable_orchestrator_tekton ? 1 : 0

  metadata {
    name = local.tekton.workloads_namespace
  }

  depends_on = [
    module.tekton-pipelines,
  ]
}
