# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

output "ingress-gateway-spec" {
  value = kubectl_manifest.gateway.live_manifest_incluster
}
