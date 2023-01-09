# Helm chart version. If this is not specified, the latest version is installed.
variable "chart_version" {
  type    = string
  default = "1.9.1"
}

variable "namespace" {
    type    = string
    default = "cert-manager"
}