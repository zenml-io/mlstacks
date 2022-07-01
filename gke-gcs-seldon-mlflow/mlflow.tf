# # using the mlflow module to create an mlflow deployment
# module "mlflow" {
#     source = "./mlflow-module"

#     # run only after the eks cluster is set up
#     depends_on = [module.eks]

#     # details about the mlflow deployment
#     htpasswd = local.mlflow.htpasswd
#     artifact_S3 = local.mlflow.artifact_S3
#     artifact_S3_Bucket = local.mlflow.artifact_S3_Bucket == "" ? aws_s3_bucket.zenml-artifact-store.bucket : local.mlflow.artifact_S3_Bucket
#     artifact_S3_Access_Key = local.mlflow.artifact_S3_Access_Key
#     artifact_S3_Secret_Key = local.mlflow.artifact_S3_Secret_Key

# }