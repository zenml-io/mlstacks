# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

variable "pipeline_version" {
  type    = string
  default = "0.42.0"
}

variable "dashboard_version" {
  type    = string
  default = "0.31.0"
}

variable "ingress_host" {
  type    = string
  default = ""
}

variable "tls_enabled" {
  type    = bool
  default = true
}
variable "istio_enabled" {
  type    = bool
  default = false
}
