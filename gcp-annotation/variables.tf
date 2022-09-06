# variables for creating a ZenML stack configuration file
variable "zenml-version" {
  description = "The version of ZenML being used"
  default     = "0.13.0"
  type        = string
}