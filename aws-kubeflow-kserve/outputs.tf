# output for eks cluster
output "eks-cluster-name" {
  value = data.aws_eks_cluster.cluster.name
}

# output for s3 bucket
output "s3-bucket-path" {
  value       = "s3://${aws_s3_bucket.zenml-artifact-store.bucket}"
  description = "The S3 bucket path for storing your artifacts"
}

# output for container registry
output "container-registry-URI" {
  value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com"
}
output "ecr-registry-name" {
  value       = aws_ecr_repository.zenml-ecr-repository[0].name
  description = "The ECR registry repository for storing your images"
}

# ingress controller hostname
output "ingress-controller-host" {
  value = data.kubernetes_service.mlflow_tracking.status.0.load_balancer.0.ingress.0.hostname
}

# outputs for the Mlflow tracking server
output "ingress-controller-name" {
  value = module.mlflow.ingress-controller-name
}
output "ingress-controller-namespace" {
  value = module.mlflow.ingress-controller-namespace
}
output "mlflow-tracking-URL" {
  value = "${data.kubernetes_service.mlflow_tracking.status.0.load_balancer.0.ingress.0.hostname}/mlflow/"
}

# output for kserve model deployer
output "kserve-workload-namespace" {
  value       = local.kserve.workloads_namespace
  description = "The namespace created for hosting your Kserve workloads"
}
output "kserve-base-url" {
  value = "http://${data.kubernetes_service.kserve_ingress.status.0.load_balancer.0.ingress.0.hostname}:${data.kubernetes_service.kserve_ingress.spec.0.port.1.port}"

}

# output the name of the stack YAML file created
output "stack-yaml-path" {
  value = local_file.stack_file.filename
}