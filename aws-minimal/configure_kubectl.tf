# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# set up local kubectl client to access the newly created cluster
resource "null_resource" "configure-local-kubectl" {
  provisioner "local-exec" {
    command = "aws eks --region ${local.region} update-kubeconfig --name ${data.aws_eks_cluster.cluster.name} --alias terraform"
  }
}
