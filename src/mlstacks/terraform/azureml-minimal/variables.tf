# variables for creating a ZenML stack configuration file
variable "zenml-version" {
  description = "The version of ZenML being used"
  default     = "0.20.1"
  type        = string
}

# additional tags defined via CLI
variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}
