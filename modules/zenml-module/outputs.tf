# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

output "zenml_server_url" {
  value = "https://${var.ingress_host}"
}
output "username" {
  value = var.username
}
output "password" {
  value     = var.password
  sensitive = true
}
