# using the nginx-ingress module to create an nginx-ingress deployment
module "nginx-ingress" {
  source = "../modules/nginx-ingress-module"

  count = (local.mlflow.enable || local.kubeflow.enable || local.zenml.enable || local.tekton.enable) ? 1 : 0

  # run only after the gke cluster is set up
  depends_on = [
    module.eks,
    null_resource.configure-local-kubectl
  ]

  chart_version = local.nginx_ingress.version
}
