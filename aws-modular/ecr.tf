# add an optional container registry
resource "aws_ecr_repository" "zenml-ecr-repository" {
  count                = var.enable_ecr ? 1 : 0
  name                 = local.ecr.name
  image_tag_mutability = "MUTABLE"
  tags                 = local.tags
}