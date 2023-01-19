# using the nginx-ingress module to create an nginx-ingress deployment
module "nginx-ingress" {
  source = "../modules/nginx-ingress-module"

  count = (var.enable_mlflow || var.enable_kubeflow || var.enable_zenml || var.enable_tekton) ? 1 : 0

  # run only after the gke cluster is set up
  depends_on = [
    module.eks,
    null_resource.configure-local-kubectl
  ]

  chart_version = local.nginx_ingress.version
}
