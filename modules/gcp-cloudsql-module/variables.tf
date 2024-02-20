# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

variable "project_id" {
  description = "The GCP project for your resources"
  type        = string
}

variable "region" {
  description = "The region for your GCP resources"
  default     = "us-east4"
  type        = string
}

variable "name" {
  description = "The name for the CloudSQL database instance"
  type        = string
}

variable "username" {
  description = "Username for the CloudSQL database instance"
  default     = "root"
  type        = string
}

variable "password" {
  description = "Password for the CloudSQL database instance"
  type        = string
}


variable "mysql_version" {
  description = "The MySQL version"
  type        = string
  default     = "MYSQL_8_0"
}

variable "database" {
  description = "The name for the default database to create"
  type        = string
  default     = null
}

variable "instance_tier" {
  description = "The instance class to use for the database"
  default     = "db-n1-standard-1"
  type        = string
}

variable "disk_size" {
  description = "The allocated storage in gigabytes"
  default     = 10
  type        = number
}
