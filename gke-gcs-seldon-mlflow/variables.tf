# variables for the MLflow tracking server
variable "htpasswd" {
  description = "The htpasswd string for the MLflow Tracking Server"
  default = ""
  type = string
}

# Variables for the CloudSQL metadata store
variable "metadata-db-username" {
  description = "The username for the CloudSQL metadata store"
  default = "admin"
  type = string
}
variable "metadata-db-password" {
  description = "The password for the CloudSQL metadata store"
  default = ""
  type = string
}