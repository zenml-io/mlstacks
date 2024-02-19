# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

output "minio-server-endpoint" {
  value = var.ingress_host
}

output "minio-console-URL" {
  value = "${var.tls_enabled ? "https" : "http"}://${var.ingress_console_host}"
}

output "artifact_S3_Endpoint_URL" {
  value = "${var.tls_enabled ? "https" : "http"}://${var.ingress_host}"
}
