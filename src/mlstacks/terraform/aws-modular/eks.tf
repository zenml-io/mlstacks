# eks module to create a cluster
# newer versions of it had some error so going with v17.23.0 for now
locals {
  enable_eks = (var.enable_orchestrator_kubeflow || var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes || var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow ||
  var.enable_zenml)
}

# module "eks" {
#   count = local.enable_eks? 1: 0
#   source  = "terraform-aws-modules/eks/aws"
#   version = "17.23.0"

#   cluster_name    = "${local.prefix}-${local.eks.cluster_name}"
#   cluster_version = local.eks.cluster_version
#   subnets         = module.vpc[0].private_subnets
#   enable_irsa     = true
#   tags            = merge(local.common_tags, var.additional_tags)

#   vpc_id = module.vpc[0].vpc_id

#   node_groups_defaults = {
#     ami_type  = "AL2_x86_64"
#     disk_size = 50
#   }


#   node_groups = {
#     main = {
#       desired_capacity = 3
#       max_capacity     = 4
#       min_capacity     = 1

#       instance_types = ["t3.xlarge"]
#       update_config = {
#         max_unavailable_percentage = 50
#       }
#     }
#   }

#   # allowing worker nodes access to other resources  
#   workers_additional_policies = [
#     "arn:aws:iam::aws:policy/AmazonS3FullAccess",
#     "arn:aws:iam::aws:policy/AutoScalingFullAccess",
#     "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
#     "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
#     "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
#     "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
#     "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess",
#   ]

#   depends_on = [
#     module.vpc
#   ]
# }



resource "aws_eks_node_group" "nodegroup" {
  count = local.enable_eks ? 1 : 0

  cluster_name    = aws_eks_cluster.cluster[0].name
  node_group_name = "${local.prefix}-${local.eks.cluster_name}-ng"
  node_role_arn   = aws_iam_role.ng[0].arn
  subnet_ids      = module.vpc[0].private_subnets

  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 1
  }
  instance_types = ["t3.xlarge"]


  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.add_roles,
    module.vpc
  ]
}

resource "aws_iam_role" "ng" {
  count = local.enable_eks ? 1 : 0

  name_prefix = "${local.prefix}-${local.eks.cluster_name}-ng"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      },
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${aws_eks_cluster.cluster[0].identity[0].oidc[0].issuer}"
        }
        Condition = {
          StringLike = {
            "${aws_eks_cluster.cluster[0].identity[0].oidc[0].issuer}:aud" = "sts.amazonaws.com"
            "${aws_eks_cluster.cluster[0].identity[0].oidc[0].issuer}:sub" = "system:serviceaccount:mlflow:*"
          }
        }
    }]
    Version = "2012-10-17"
  })
  force_detach_policies = true

  tags = merge(local.common_tags, var.additional_tags)
}

locals {
  roles_to_attach = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AutoScalingFullAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess",
  ]
}

resource "aws_iam_role_policy_attachment" "add_roles" {
  count = local.enable_eks ? length(local.roles_to_attach) : 0

  policy_arn = local.roles_to_attach[count.index]
  role       = aws_iam_role.ng[0].name
}



resource "aws_eks_cluster" "cluster" {
  count    = local.enable_eks ? 1 : 0
  name     = "${local.prefix}-${local.eks.cluster_name}"
  role_arn = aws_iam_role.cluster[0].arn

  version = local.eks.cluster_version

  vpc_config {
    endpoint_public_access  = true
    endpoint_private_access = false
    subnet_ids              = module.vpc[0].private_subnets
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceControllerPolicy,
  ]
}

resource "aws_iam_role" "cluster" {
  count = local.enable_eks ? 1 : 0

  name_prefix           = "${local.prefix}-${local.eks.cluster_name}"
  assume_role_policy    = data.aws_iam_policy_document.cluster_assume_role_policy.json
  force_detach_policies = true

  tags = merge(local.common_tags, var.additional_tags)
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  count = local.enable_eks ? 1 : 0

  policy_arn = "${local.policy_arn_prefix}/AmazonEKSClusterPolicy"
  role       = local.cluster_iam_role_name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  count = local.enable_eks ? 1 : 0

  policy_arn = "${local.policy_arn_prefix}/AmazonEKSServicePolicy"
  role       = local.cluster_iam_role_name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceControllerPolicy" {
  count = local.enable_eks ? 1 : 0

  policy_arn = "${local.policy_arn_prefix}/AmazonEKSVPCResourceController"
  role       = local.cluster_iam_role_name
}

/*
 Adding a policy to cluster IAM role that allow permissions
 required to create AWSServiceRoleForElasticLoadBalancing service-linked role by EKS during ELB provisioning
*/

data "aws_iam_policy_document" "cluster_elb_sl_role_creation" {
  count = local.enable_eks ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeAddresses"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cluster_elb_sl_role_creation" {
  count = local.enable_eks ? 1 : 0

  name_prefix = "${local.prefix}-${local.eks.cluster_name}-elb-sl-role-creation"
  description = "Permissions for EKS to create AWSServiceRoleForElasticLoadBalancing service-linked role"
  policy      = data.aws_iam_policy_document.cluster_elb_sl_role_creation[0].json
}

resource "aws_iam_role_policy_attachment" "cluster_elb_sl_role_creation" {
  count = local.enable_eks ? 1 : 0

  policy_arn = aws_iam_policy.cluster_elb_sl_role_creation[0].arn
  role       = local.cluster_iam_role_name
}

data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    sid = "EKSClusterAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_partition" "current" {}
locals {
  policy_arn_prefix     = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
  cluster_iam_role_name = local.enable_eks ? aws_iam_role.cluster[0].name : ""
}

data "external" "get_cluster_info" {
  program = ["bash", "${path.module}/get_cluster_info.sh"]
  query = {
    cluster_name = "${local.prefix}-${local.eks.cluster_name}"
    region       = var.region
  }

  depends_on = [
    aws_eks_cluster.cluster
  ]
}

data "external" "get_cluster_auth" {
  program = ["bash", "${path.module}/get_cluster_token.sh"]
  query = {
    cluster_name = "${local.prefix}-${local.eks.cluster_name}"
    region       = var.region
  }

  depends_on = [
    aws_eks_cluster.cluster
  ]
}
