# using the kubeflow pipelines module to create a kubeflow pipelines deployment
module "kubeflow-pipelines" {
  source = "../modules/kubeflow-pipelines-module"

  count = local.kubeflow.enable ? 1 : 0

  # run only after the eks cluster is set up and cert-manager and nginx-ingress
  # are installed 
  depends_on = [
    module.eks,
    null_resource.configure-local-kubectl,
    module.cert-manager,
    module.nginx-ingress,
  ]

  pipeline_version = local.kubeflow.version
  ingress_host = local.kubeflow.ingress_host
}