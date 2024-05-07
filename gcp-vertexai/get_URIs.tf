# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# get URI for  MLflow tracking server
data "kubernetes_service" "mlflow_tracking" {
  count = var.enable_mlflow ? 1 : 0
  metadata {
    name      = "${module.mlflow[0].ingress-controller-name}-ingress-nginx-controller"
    namespace = module.mlflow[0].ingress-controller-namespace
  }

  depends_on = [
    module.mlflow
  ]
}
