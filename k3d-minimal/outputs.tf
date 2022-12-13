# output for the GKE cluster
output "k3d-clutser-name" {
  value = "${k3d_cluster.zenml-cluster.name}"
}

# output for container registry
output "container-registry-URI" {
  value = "${k3d_cluster.zenml-cluster.registries[0].create[0].host}:${k3d_cluster.zenml-cluster.registries[0].create[0].host_port}"
}

# output the name of the stack YAML file created
output "stack-yaml-path" {
  value = local_file.stack_file.filename
}
  