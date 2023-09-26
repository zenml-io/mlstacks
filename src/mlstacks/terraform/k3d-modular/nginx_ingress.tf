# using the nginx-ingress module to create an nginx-ingress deployment
module "nginx-ingress" {
  source = "../modules/nginx-ingress-module"

  count = (var.enable_experiment_tracker_mlflow || var.enable_orchestrator_kubeflow || var.enable_orchestrator_tekton || var.enable_artifact_store) && (!var.enable_model_deployer_seldon && !var.enable_model_deployer_kserve) ? 1 : 0

  # run only after the gke cluster is set up
  depends_on = [
    k3d_cluster.zenml-cluster,
  ]

  chart_version = local.nginx_ingress.version
}
