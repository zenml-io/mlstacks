# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

variable "namespace" {
  type    = string
  default = "istio-system"
}

variable "chart_version" {
  type    = string
  default = "1.14.1"
}
