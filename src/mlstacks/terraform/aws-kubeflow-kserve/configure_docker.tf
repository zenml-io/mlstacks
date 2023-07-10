# set up local docker client to access the newly created registry
resource "null_resource" "configure-local-docker" {
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${local.region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com"
  }

}