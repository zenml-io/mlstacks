
variable "namespace" {
    type    = string
    default = "seldon-system"
}

# Helm chart version. If this is not specified, the latest version is installed.
variable "chart_version" {
    type    = string
    default = "1.15.0"
}
