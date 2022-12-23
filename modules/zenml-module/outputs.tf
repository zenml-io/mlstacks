output "zenml_server_url" {
  value = "https://${var.ingress_host}"
}
output "username" {
  value = var.username
}
output "password" {
  value = var.password
  sensitive = true
}
