# output for eks cluster
output "eks-cluster-name" {
  value = local.enable_eks ? "${local.prefix}-${local.eks.cluster_name}" : ""
}

# if s3 is enabled, set the artifact store outputs to the s3 values
# otherwise, set the artifact store outputs to empty strings
output "artifact_store_id" {
  value = var.enable_artifact_store ? uuid() : ""
}
output "artifact_store_flavor" {
  value = var.enable_artifact_store ? "s3" : ""
}
output "artifact_store_name" {
  value = var.enable_artifact_store ? "s3_artifact_store_${random_string.unique.result}" : ""
}
output "artifact_store_configuration" {
  value = var.enable_artifact_store ? jsonencode({
    path = "s3://${aws_s3_bucket.zenml-artifact-store[0].bucket}"
  }) : ""
}

# if ecr is enabled, set the container registry outputs to the ecr values
# otherwise, set the container registry outputs to empty strings
output "container_registry_id" {
  value = var.enable_container_registry ? uuid() : ""
}
output "container_registry_flavor" {
  value = var.enable_container_registry ? "aws" : ""
}
output "container_registry_name" {
  value = var.enable_container_registry ? "aws_container_registry_${random_string.unique.result}" : ""
}
output "container_registry_configuration" {
  value = var.enable_container_registry ? jsonencode({
    uri = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
  }) : ""
}

# if kubeflow is enabled, set the orchestrator outputs to the kubeflow values
# if tekton is enabled, set the orchestrator outputs to the tekton values
# if kubernetes is enabled, set the orchestrator outputs to the kubernetes values
# if sagemaker is enabled, set the orchestrator outputs to the sagemaker values
# otherwise, set the orchestrator outputs to empty strings
output "orchestrator_id" {
  value = var.enable_orchestrator_kubeflow ? uuid() : var.enable_orchestrator_tekton ? uuid() : var.enable_orchestrator_kubernetes ? uuid() : var.enable_orchestrator_sagemaker ? uuid() : ""
}
output "orchestrator_flavor" {
  value = var.enable_orchestrator_kubeflow ? "kubeflow" : var.enable_orchestrator_tekton ? "tekton" : var.enable_orchestrator_kubernetes ? "kubernetes" : var.enable_orchestrator_sagemaker ? "sagemaker" : ""
}
output "orchestrator_name" {
  value = var.enable_orchestrator_kubeflow ? "eks_kubeflow_orchestrator_${random_string.unique.result}" : var.enable_orchestrator_tekton ? "eks_tekton_orchestrator_${random_string.unique.result}" : var.enable_orchestrator_kubernetes ? "eks_kubernetes_orchestrator_${random_string.unique.result}" : var.enable_orchestrator_sagemaker ? "sagemaker_orchestrator_${random_string.unique.result}" : ""
}
output "orchestrator_configuration" {
  value = var.enable_orchestrator_kubeflow ? jsonencode({
    kubernetes_context = "${aws_eks_cluster.cluster[0].arn}"
    synchronous        = true
    }) : var.enable_orchestrator_tekton ? jsonencode({
    kubernetes_context = "${aws_eks_cluster.cluster[0].arn}"
    }) : var.enable_orchestrator_kubernetes ? jsonencode({
    kubernetes_context = "${aws_eks_cluster.cluster[0].arn}"
    synchronous        = true
    }) : var.enable_orchestrator_sagemaker ? jsonencode({
    execution_role = "${aws_iam_role.sagemaker_role[0].arn}"
  }) : ""
}

# if mlflow is enabled, set the experiment tracker outputs to the mlflow values
# otherwise, set the experiment tracker outputs to empty strings
output "experiment_tracker_id" {
  value = var.enable_experiment_tracker_mlflow ? uuid() : ""
}
output "experiment_tracker_flavor" {
  value = var.enable_experiment_tracker_mlflow ? "mlflow" : ""
}
output "experiment_tracker_name" {
  value = var.enable_experiment_tracker_mlflow ? "eks_mlflow_experiment_tracker_${random_string.unique.result}" : ""
}
output "experiment_tracker_configuration" {
  value = var.enable_experiment_tracker_mlflow ? jsonencode({
    tracking_uri      = module.mlflow[0].mlflow-tracking-URL
    tracking_username = var.mlflow-username
    tracking_password = var.mlflow-password
  }) : ""
}


# if secrets manager is enabled, set the secrets manager outputs to the secrets manager values
# otherwise, set the secrets manager outputs to empty strings
output "secrets_manager_id" {
  value = var.enable_secrets_manager ? uuid() : ""
}
output "secrets_manager_flavor" {
  value = var.enable_secrets_manager ? "aws" : ""
}
output "secrets_manager_name" {
  value = var.enable_secrets_manager ? "aws_secrets_manager_${random_string.unique.result}" : ""
}
output "secrets_manager_configuration" {
  value = var.enable_secrets_manager ? jsonencode({
    region_name = var.region
  }) : ""
}

# if kserve is enabled, set the model deployer outputs to the kserve values
# if seldon is enabled, set the model deployer outputs to the seldon values
# otherwise, set the model deployer outputs to empty strings
output "model_deployer_id" {
  value = var.enable_model_deployer_kserve ? uuid() : var.enable_model_deployer_seldon ? uuid() : ""
}
output "model_deployer_flavor" {
  value = var.enable_model_deployer_kserve ? "kserve" : var.enable_model_deployer_seldon ? "seldon" : ""
}
output "model_deployer_name" {
  value = var.enable_model_deployer_kserve ? "eks_kserve_model_deployer_${random_string.unique.result}" : var.enable_model_deployer_seldon ? "eks_seldon_model_deployer_${random_string.unique.result}" : ""
}
output "model_deployer_configuration" {
  value = var.enable_model_deployer_kserve ? jsonencode({
    kubernetes_context   = "${aws_eks_cluster.cluster[0].arn}"
    kubernetes_namespace = local.kserve.workloads_namespace
    base_url             = module.kserve[0].kserve-base-URL
    secret               = "aws_kserve_secret"
    }) : var.enable_model_deployer_seldon ? jsonencode({
    kubernetes_context   = "${aws_eks_cluster.cluster[0].arn}"
    kubernetes_namespace = local.seldon.workloads_namespace
    base_url             = "http://${module.istio[0].ingress-hostname}:${module.istio[0].ingress-port}"
  }) : ""
}

# if sagemaker is enabled as step operator, set the step operator outputs to the sagemaker values
# otherwise, set the step operator outputs to empty strings
output "step_operator_id" {
  value = var.enable_step_operator_sagemaker ? uuid() : ""
}
output "step_operator_flavor" {
  value = var.enable_step_operator_sagemaker ? "sagemaker" : ""
}
output "step_operator_name" {
  value = var.enable_step_operator_sagemaker ? "sagemaker_step_operator_${random_string.unique.result}" : ""
}
output "step_operator_configuration" {
  value = var.enable_step_operator_sagemaker ? jsonencode({
    role = "${aws_iam_role.sagemaker_role[0].arn}"
  }) : ""
}

# ingress controller hostname (for the zenserver deploy CLI)
output "ingress-controller-host" {
  value = length(module.nginx-ingress) > 0 ? module.nginx-ingress[0].ingress-hostname : null
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
  value = var.enable_orchestrator_kubeflow ? module.kubeflow-pipelines[0].pipelines-ui-URL : null
}

output "tekton-pipelines-ui-URL" {
  value = var.enable_orchestrator_tekton ? module.tekton-pipelines[0].pipelines-ui-URL : null
}

# outputs for the MLflow tracking server
output "mlflow-tracking-URL" {
  value = var.enable_experiment_tracker_mlflow ? module.mlflow[0].mlflow-tracking-URL : null
}
output "mlflow-bucket" {
  value = (var.enable_experiment_tracker_mlflow && var.mlflow_bucket == "") ? "mlflow-s3-${random_string.mlflow_bucket_suffix.result}" : ""
}

# output for kserve model deployer
output "kserve-workload-namespace" {
  value       = var.enable_model_deployer_kserve ? local.kserve.workloads_namespace : null
  description = "The namespace created for hosting your Kserve workloads"
}
output "kserve-base-url" {
  value = var.enable_model_deployer_kserve ? module.kserve[0].kserve-base-URL : null
}

# output for seldon model deployer
output "seldon-workload-namespace" {
  value       = var.enable_model_deployer_seldon ? local.seldon.workloads_namespace : null
  description = "The namespace created for hosting your Seldon workloads"
}

output "seldon-base-url" {
  value = var.enable_model_deployer_seldon ? "http://${module.istio[0].ingress-hostname}:${module.istio[0].ingress-port}" : null
}

# output the name of the stack YAML file created
output "stack-yaml-path" {
  value = local_file.stack_file.filename
}

# outputs for the ZenML server
output "zenml-url" {
  value = var.enable_zenml ? module.zenml[0].zenml_server_url : null
}
output "zenml-username" {
  value = var.enable_zenml ? module.zenml[0].username : null
}