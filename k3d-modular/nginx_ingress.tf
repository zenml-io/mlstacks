# using the nginx-ingress module to create an nginx-ingress deployment
module "nginx-ingress" {
  source = "../modules/nginx-ingress-module"

  count = (local.mlflow.enable || local.kubeflow.enable || local.tekton.enable) ? 1 : 0

  # run only after the gke cluster is set up
  depends_on = [
    k3d_cluster.zenml-cluster,
  ]

  chart_version = local.nginx_ingress.version
}
