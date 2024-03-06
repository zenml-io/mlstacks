# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

output "pipelines-ui-URL" {
  value = "${var.tls_enabled ? "https" : "http"}://${var.ingress_host}"
}
