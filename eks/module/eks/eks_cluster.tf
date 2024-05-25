resource "aws_eks_cluster" "main" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_role.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids = var.private_subnets_ids
    # EKS Additional security group
    security_group_ids      = [aws_security_group.cluster.id]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }

  depends_on = [
    aws_iam_policy_attachment.eks_cluster_policy,
    aws_iam_policy_attachment.eks_cluster_vpc_controller
  ]

  # https://registry.terraform.io/providers/hashicorp/aws/5.50.0/docs/resources/eks_cluster.html#access_config
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP" # or API
    bootstrap_cluster_creator_admin_permissions = false
  }
}
