# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

output "ingress-controller-name" {
  value = helm_release.nginx-controller.name
}
output "ingress-controller-namespace" {
  value = kubernetes_namespace.nginx-ns.metadata[0].name
}
