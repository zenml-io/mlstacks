# Variables for the CloudSQL metadata store
variable "metadata-db-username" {
  description = "The username for the Azure MySQL metadata store"
  default     = "zenmladmin"
  type        = string
}
variable "metadata-db-password" {
  description = "The password for the Azure MySQL metadata store"
  default     = ""
  type        = string
}

# variables for creating a ZenML stack configuration file
variable "zenml-version" {
  description = "The version of ZenML being used"
  default     = "0.13.0"
  type        = string
}
