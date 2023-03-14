# Create an IAM role for SageMaker
resource "aws_iam_role" "sagemaker_role" {
  count = var.enable_orchestrator_sagemaker ? 1 : 0
  name = "sagemaker-role-${random_string.unique.result}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "sagemaker.amazonaws.com"
        ]
      },
      "Action": [
        "sts:AssumeRole"
      ]
    }
  ]
}
EOF
}

# attach the AmazonSageMakerFullAccess, AmazonS3FullAccess, SecretsManagerReadWrite policies to the role
resource "aws_iam_role_policy_attachment" "sagemaker_role_policy" {
  count = var.enable_orchestrator_sagemaker ? 1 : 0
  role       = aws_iam_role.sagemaker_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}
resource "aws_iam_role_policy_attachment" "sagemaker_role_policy2" {
  count = var.enable_orchestrator_sagemaker ? 1 : 0
  role       = aws_iam_role.sagemaker_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "sagemaker_role_policy3" {
  count = var.enable_orchestrator_sagemaker ? 1 : 0
  role       = aws_iam_role.sagemaker_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}