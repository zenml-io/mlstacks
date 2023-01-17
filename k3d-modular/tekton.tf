# using the tekton pipelines module to create a tekton pipelines deployment
module "tekton-pipelines" {
  source = "../modules/tekton-pipelines-module"

  count = local.tekton.enable ? 1 : 0

  # run only after the k3d cluster and nginx-ingress are set up
  depends_on = [
    k3d_cluster.zenml-cluster,
    module.nginx-ingress,
  ]

  pipeline_version = local.tekton.version
  dashboard_version = local.tekton.dashboard_version
  ingress_host = "${local.tekton.ingress_host_prefix}.${module.nginx-ingress[0].ingress-ip-address}.nip.io"
  tls_enabled = false
  istio_enabled = (local.kserve.enable || local.seldon.enable) ? true : false
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
