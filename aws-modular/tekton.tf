# using the tekton pipelines module to create a tekton pipelines deployment
module "tekton-pipelines" {
  source = "../modules/tekton-pipelines-module"

  count = local.tekton.enable ? 1 : 0

  # run only after the gke cluster is set up and cert-manager and nginx-ingress
  # are installed 
  depends_on = [
    module.eks,
    null_resource.configure-local-kubectl,
    module.cert-manager,
    module.nginx-ingress,
  ]

  pipeline_version = local.tekton.version
  dashboard_version = local.tekton.dashboard_version
  ingress_host = local.tekton.ingress_host
}

# the namespace where zenml will run tekton pipelines
resource "kubernetes_namespace" "tekton-workloads" {

  count = local.tekton.enable ? 1 : 0

  metadata {
    name = local.tekton.workloads_namespace
  }

  depends_on = [
    module.tekton-pipelines,
  ]
}
