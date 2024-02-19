# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# using the nginx-ingress module to create an nginx-ingress deployment
module "nginx-ingress" {
  source = "../modules/nginx-ingress-module"

  count = (var.enable_experiment_tracker_mlflow || var.enable_orchestrator_kubeflow || var.enable_zenml || var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes) ? 1 : 0

  # run only after the gke cluster is set up
  depends_on = [
    google_container_cluster.gke,
    null_resource.configure-local-kubectl
  ]

  chart_version = local.nginx_ingress.version
}
