# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

output "kserve-base-URL" {
  value = "https://${var.kserve_domain}"
}
