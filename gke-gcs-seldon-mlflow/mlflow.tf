# using the mlflow module to create an mlflow deployment
module "mlflow" {
    source = "../eks-s3-seldon-mlflow/mlflow-module"

    # run only after the eks cluster is set up
    depends_on = [module.gke]

    # details about the mlflow deployment
    htpasswd = var.htpasswd
    artifact_GCS = local.mlflow.artifact_S3
    artifact_GCS_Bucket = local.mlflow.artifact_GCS_Bucket == "" ? google_storage_bucket.artifact-store.name : local.mlflow.artifact_GCS_Bucket
}