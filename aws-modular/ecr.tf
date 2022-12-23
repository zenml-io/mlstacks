# add an optional container registry
resource "aws_ecr_repository" "zenml-ecr-repository" {
  name                 = local.ecr.name
  image_tag_mutability = "MUTABLE"
  tags                 = local.tags
}