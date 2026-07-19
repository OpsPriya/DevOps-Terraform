# EKS-focused IAM Module
# Creates IAM roles and policies for EKS services

# IAM Role
resource "aws_iam_role" "eks_role" {
  name = var.role_name

  assume_role_policy = var.trust_policy_file != "" ? templatefile("${path.module}/policies/${var.trust_policy_file}", {
    account_id   = var.account_id
    oidc_id      = var.oidc_id
    cluster_name = var.cluster_name
    region       = var.region
    }) : jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = var.service_principal
        }
      }
    ]
  })

}

# Attach policies from JSON files
resource "aws_iam_role_policy" "eks_policies" {
  for_each = var.policy_files

  name = "${var.role_name}-${each.key}"
  role = aws_iam_role.eks_role.id
  policy = templatefile("${path.module}/policies/${each.value}", {
    account_id   = var.account_id
    oidc_id      = var.oidc_id
    cluster_name = var.cluster_name
    region       = var.region
  })
}

# Attach AWS managed policies
resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.eks_role.name
  policy_arn = each.value
}

# Instance Profile (for EC2)
resource "aws_iam_instance_profile" "eks_profile" {
  count = var.create_instance_profile ? 1 : 0

  name = "${var.role_name}-profile"
  role = aws_iam_role.eks_role.name

}
