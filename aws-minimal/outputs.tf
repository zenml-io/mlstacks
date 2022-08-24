# output for eks cluster
output "eks-cluster-name" {
  value = data.aws_eks_cluster.cluster.name
}

# output for s3 bucket
output "s3-bucket-path" {
  value       = "s3://${aws_s3_bucket.zenml-artifact-store.bucket}"
  description = "The S3 bucket path for storing your artifacts"
}

# outputs for the metadata store
output "metadata-db-host" {
  value = module.metadata_store.db_instance_address
}
output "metadata-db-username" {
  value     = module.metadata_store.db_instance_username
  sensitive = true
}
output "metadata-db-password" {
  value     = module.metadata_store.db_instance_password
  sensitive = true
}

# output for container registry
output "container-registry-URI" {
  value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com"
}
output "ecr-registry-name" {
  value       = aws_ecr_repository.zenml-ecr-repository[0].name
  description = "The ECR registry repository for storing your images"
}

# outputs for the Mlflow tracking server
output "ingress-controller-name" {
  value = module.mlflow.ingress-controller-name
}
output "ingress-controller-namespace" {
  value = module.mlflow.ingress-controller-namespace
}
output "mlflow-tracking-URL" {
  value = data.kubernetes_service.mlflow_tracking.status.0.load_balancer.0.ingress.0.hostname
}

# output for seldon model deployer
output "seldon-core-workload-namespace" {
  value       = kubernetes_namespace.seldon-workloads.metadata[0].name
  description = "The namespace created for hosting your Seldon workloads"
}
output "seldon-prediction-spec" {
  value     = module.seldon.ingress-gateway-spec
  sensitive = true
}
output "seldon-base-url" {
  value = data.kubernetes_service.seldon_ingress.status.0.load_balancer.0.ingress.0.hostname
}

# output the name of the stack YAML file created
output "stack-yaml-path" {
  value = local_file.stack_file.filename
}