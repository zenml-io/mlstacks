# get URI for  MLflow tracking server
data "external" "tracking_URI" {
  program = ["kubectl","get service ${module.mlflow.ingress-controller-name}-ingress-nginx-controller -n ${module.mlflow.ingress-controller-namespace} -o json"]
}

# get the ingress host URL for the seldon model deployer
data "external" "ingress_host" {
  program = ["kubectl","-n istio-ingress get service istio-ingress-seldon -o json"]
}