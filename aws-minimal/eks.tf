# eks module to creater a cluster
# newer versions of it had some error so going with v17.23.0 for now
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.23.0"

  cluster_name    = "${local.prefix}-${local.eks.cluster_name}"
  cluster_version = "1.22"
  subnets         = module.vpc.private_subnets
  enable_irsa     = true
  tags            = local.tags

  vpc_id = module.vpc.vpc_id

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }


  node_groups = {
    main = {
      desired_capacity = 1
      max_capacity     = 4
      min_capacity     = 1

      instance_types = ["t3.medium"]
      update_config = {
        max_unavailable_percentage = 50
      }
    }
  }

  # allowing worker nodes access to other resources  
  workers_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AutoScalingFullAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
  ]

  depends_on = [
    module.vpc
  ]
}
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
