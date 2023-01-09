output "minio-server-endpoint" {
  value = "${var.ingress_host}"
}

output "minio-console-URL" {
  value = "${var.tls_enabled ? "https" : "http"}://${var.ingress_host}/console"
}
