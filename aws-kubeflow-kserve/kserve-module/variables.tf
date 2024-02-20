# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# namespace to create inference services in
variable "workloads_namespace" {
  type    = string
  default = "zenml-workloads"
}
