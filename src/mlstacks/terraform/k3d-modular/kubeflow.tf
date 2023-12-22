# using the kubeflow pipelines module to create a kubeflow pipelines deployment
module "kubeflow-pipelines" {
  source = "../modules/kubeflow-pipelines-module"

  count = var.enable_orchestrator_kubeflow ? 1 : 0

  # run only after the gke cluster is set up and nginx-ingress
  # is installed 
  depends_on = [
    k3d_cluster.zenml-cluster,
    module.nginx-ingress,
    module.istio,
  ]

  pipeline_version = local.kubeflow.version
  ingress_host     = (var.enable_model_deployer_seldon) ? "${local.kubeflow.ingress_host_prefix}.${module.istio[0].ingress-ip-address}.nip.io" : "${local.kubeflow.ingress_host_prefix}.${module.nginx-ingress[0].ingress-ip-address}.nip.io"
  tls_enabled      = false
  istio_enabled    = (var.enable_model_deployer_seldon) ? true : false
}
