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
  value       = aws_ecr_repository.zenml-ecr-repository.name
  description = "The ECR registry repository for storing your images"
}

# nginx ingress hostname
output "nginx-ingress-hostname" {
  value = length(module.nginx-ingress) > 0 ? module.nginx-ingress[0].ingress-hostname : null
}

# istio ingress hostname
output "istio-ingress-hostname" {
  value = length(module.istio) > 0 ? module.istio[0].ingress-hostname : null
}


output "kubeflow-pipelines-ui-URL" {
  value = local.kubeflow.enable ? module.kubeflow-pipelines[0].pipelines-ui-URL : null
}

output "tekton-pipelines-ui-URL" {
  value = local.tekton.enable ? module.tekton-pipelines[0].pipelines-ui-URL : null
}

# outputs for the MLflow tracking server
output "mlflow-tracking-URL" {
  value = local.mlflow.enable ? module.mlflow[0].mlflow-tracking-URL : null
}

# output for kserve model deployer
output "kserve-workload-namespace" {
  value       = local.kserve.enable ? local.kserve.workloads_namespace : null
  description = "The namespace created for hosting your Kserve workloads"
}
output "kserve-base-url" {
  value = local.kserve.enable ? module.kserve[0].kserve-base-URL : null
}

# output for seldon model deployer
output "seldon-workload-namespace" {
  value       = local.seldon.enable ? local.seldon.workloads_namespace : null
  description = "The namespace created for hosting your Seldon workloads"
}

output "seldon-base-url" {
  value = local.seldon.enable ? "http://${module.istio[0].ingress-hostname}:${module.istio[0].ingress-port}" : null
}

# output the name of the stack YAML file created
output "stack-yaml-path" {
  value = local_file.stack_file.filename
}

# outputs for the ZenML server
output "zenml-url" {
  value = local.zenml.enable ? module.zenml[0].zenml_server_url : null
}
output "zenml-username" {
  value = local.zenml.enable ? module.zenml[0].username : null
}