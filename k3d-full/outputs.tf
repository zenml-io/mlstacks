# output for the GKE cluster
output "k3d-clutser-name" {
  value = "${k3d_cluster.zenml-cluster.name}"
}

# output for container registry
output "container-registry-URI" {
  value = "${local.k3d_registry.host}:${local.k3d_registry.port}"
}

# output the name of the stack YAML file created
output "stack-yaml-path" {
  value = local_file.stack_file.filename
}
  