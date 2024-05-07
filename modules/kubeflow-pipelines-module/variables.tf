# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

variable "pipeline_version" {
  type    = string
  default = "1.8.3"
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
