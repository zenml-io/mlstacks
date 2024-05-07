# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

output "ingress-ip-address" {
  value = data.kubernetes_service.istio_ingress.status.0.load_balancer.0.ingress.0.ip
}
output "ingress-hostname" {
  value = data.kubernetes_service.istio_ingress.status.0.load_balancer.0.ingress.0.hostname
}
output "ingress-port" {
  value = data.kubernetes_service.istio_ingress.spec.0.port.1.port
}
