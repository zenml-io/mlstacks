# using the nginx-ingress module to create an nginx-ingress deployment
module "nginx-ingress" {
  source = "../modules/nginx-ingress-module"

  count = (var.enable_mlflow || var.enable_kubeflow || var.enable_tekton) && (!var.enable_seldon && !var.enable_kserve) ? 1 : 0

  # run only after the gke cluster is set up
  depends_on = [
    k3d_cluster.zenml-cluster,
  ]

  chart_version = local.nginx_ingress.version
}
