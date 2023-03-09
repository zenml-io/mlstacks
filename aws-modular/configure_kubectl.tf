# set up local kubectl client to access the newly created cluster
resource "null_resource" "configure-local-kubectl" {
  count = length(aws_eks_cluster.cluster) > 0 ? 1 : 0
  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${local.prefix}-${local.eks.cluster_name}"
  }
}