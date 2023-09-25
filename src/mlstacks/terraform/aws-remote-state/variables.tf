variable "region" {
  description = "The region to deploy resources to"
  default     = "eu-north-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket to deploy"
  default     = ""
}
