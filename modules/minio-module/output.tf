output "minio-server-endpoint" {
  value = "${var.ingress_host}"
}

output "minio-console-URL" {
  value = "https://${var.ingress_host}/console"
}
