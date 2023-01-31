
variable "namespace" {
  type    = string
  default = "seldon-system"
}
variable "istio_gateway_name" {
  type    = string
  default = "seldon-gateway"
}
variable "istio_ns" {
  type    = string
  default = "istio-system"
}
# Helm chart version. If this is not specified, the latest version is installed.
variable "chart_version" {
  type    = string
  default = "1.15.0"
}