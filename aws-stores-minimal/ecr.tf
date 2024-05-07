# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# add an optional container registry
resource "aws_ecr_repository" "zenml-ecr-repository" {
  name                 = local.ecr.name
  image_tag_mutability = "MUTABLE"
  count                = local.ecr.enable_container_registry ? 1 : 0
  tags                 = local.tags
}
