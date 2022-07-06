# variables for the MLflow tracking server
# variable "mlflow-artifact-S3-access-key" {
#   description = "Your AWS access key for using S3 as MLflow artifact store"
#   default = "AKIAJX7X7X7X7X7X7X7X"
#   type = string
# }
# variable "mlflow-artifact-S3-secret-key" {
#   description = "Your AWS secret key for using S3 as MLflow artifact store"
#   default = "JbtUCfSc211GYkmZ5MmBF1"
#   type = string
# }
# variable "htpasswd" {
#   description = "The htpasswd string for the MLflow Tracking Server"
#   default = ""
#   type = string
# }

# Variables for the CloudSQL metadata store
variable "metadata-db-username" {
  description = "The username for the AWS RDS metadata store"
  default = "admin"
  type = string
}
variable "metadata-db-password" {
  description = "The password for the AWS RDS metadata store"
  default = ""
  type = string
}