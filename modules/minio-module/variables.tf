variable "minio_storage_size" {
    description = "The size of the Minio storage volume"
    default     = "20Gi"
    type        = string
}
variable "minio_access_key" {
  description = "Your access key for using Minio artifact store"
  type        = string
}
variable "minio_secret_key" {
  description = "Your secret key for using Minio artifact store"
  type        = string
}
variable "zenml_minio_store_bucket" {
  description = "The name of the bucket to use for ZenML"
  type        = string
}
variable "mlflow_minio_store_bucket" {
  description = "The name of the bucket to use for MLFlow"
  type        = string
}
variable "ingress_host" {
  type    = string
  default = ""
}
variable "ingress_console_host" {
  type    = string
  default = ""
}