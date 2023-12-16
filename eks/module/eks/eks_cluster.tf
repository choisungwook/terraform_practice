resource "aws_eks_cluster" "main" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_role.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids = var.private_subnets_ids
    # EKS Additional security group
    security_group_ids      = [aws_security_group.cluster.id]
    endpoint_private_access = var.endpoint_prviate_access
    endpoint_public_access  = var.endpoint_public_access
  }

  depends_on = [
    aws_iam_policy_attachment.eks_cluster_policy,
    aws_iam_policy_attachment.eks_cluster_vpc_controller
  ]
}
