
variable "chart_version" {
  description = "The ZenML chart version to use. Leave empty to use the latest."
  default     = ""
  type        = string
}

variable "namespace" {
  description = "The namespace to install the ZenML server Helm chart in"
  default     = "zenml-server"
  type        = string
}

variable "username" {
  description = "Username for the default ZenML server account"
  default     = "default"
  type        = string
}

variable "password" {
  description = "Password for the default ZenML server account"
  type        = string
}

# database URL (including username/password)
variable "database_url" {
  description = "The URL for the AWS RDS instance"
  default     = ""
  type        = string
}
variable "database_ssl_ca" {
  description = "The server ca for the AWS RDS instance"
  default     = ""
  type        = string
}
variable "database_ssl_cert" {
  description = "The client cert for the AWS RDS instance"
  default     = ""
  type        = string
}
variable "database_ssl_key" {
  description = "The client key for the AWS RDS instance"
  default     = ""
  type        = string
}
variable "database_ssl_verify_server_cert" {
  description = "Should SSL be verified?"
  default     = true
  type        = bool
}

# ingress hostname
variable "ingress_host" {
  description = "The hostname to use for the ingress"
  default     = ""
  type        = string
}
variable "istio_enabled" {
  type    = bool
  default = false
}
variable "ingress_tls" {
  description = "Whether to enable tls on the ingress or not"
  default     = false
  type        = bool
}
variable "ingress_tls_generate_certs" {
  description = "Whether to enable tls certificates or not"
  default     = false
  type        = bool
}
variable "ingress_tls_secret_name" {
  description = "Name for the Kubernetes secret that stores certificates"
  default     = "zenml-tls-certs"
  type        = string
}

variable "zenmlserver_image_tag" {
  description = "The tag to use for the zenmlserver docker image."
  default     = "latest"
  type        = string
}

variable "zenmlinit_image_tag" {
  description = "The tag to use for the zenml init docker image."
  default     = "latest"
  type        = string
}
