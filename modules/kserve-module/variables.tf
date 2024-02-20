# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

variable "knative_version" {
  type    = string
  default = "1.8.1"
}

variable "kserve_version" {
  type    = string
  default = "0.9.0"
}

variable "kserve_domain" {
  type    = string
  default = "example.com"
}
