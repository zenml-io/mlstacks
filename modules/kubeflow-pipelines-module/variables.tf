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