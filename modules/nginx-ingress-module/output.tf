# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

output "ingress-controller-name" {
  value = helm_release.nginx-controller.name
}
output "ingress-controller-namespace" {
  value = kubernetes_namespace.nginx-ns.metadata[0].name
}
output "ingress-hostname" {
  value = data.kubernetes_service.nginx-ingress-controller.status.0.load_balancer.0.ingress.0.hostname
}
output "ingress-ip-address" {
  value = data.kubernetes_service.nginx-ingress-controller.status.0.load_balancer.0.ingress.0.ip
}

data "external" "getIP" {
  program = ["${path.module}/dig.sh"]

  query = {
    hostname = data.kubernetes_service.nginx-ingress-controller.status.0.load_balancer.0.ingress.0.hostname
  }
}

output "ingress-ip-address-aws" {
  value = data.external.getIP.result.ip
}
