variable "region" {
  description = "The region to deploy resources to"
  default     = "eu-north-1"
}

variable "project_id" {
  description = "The project ID to deploy resources to"
  default     = ""
}

variable "bucket_name" {
  description = "The name of the GCS bucket to deploy"
  default     = ""
}
