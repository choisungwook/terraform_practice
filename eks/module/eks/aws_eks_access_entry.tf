locals {
  cluster_admins = [
    for admin_role in var.aws_auth_admin_roles :
    {
      principal_arn     = admin_role
      kubernetes_groups = []
      username          = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      type              = "STANDARD"
    }
  ]
}

resource "aws_eks_access_entry" "cluster_admins" {
  for_each = { for idx, role in local.cluster_admins : idx => role }

  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = each.value.principal_arn
  kubernetes_groups = each.value.kubernetes_groups
  type              = each.value.type
}

resource "aws_eks_access_policy_association" "cluster_admins" {
  for_each = { for idx, role in local.cluster_admins : idx => role }

  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = each.value.username
  principal_arn = each.value.principal_arn

  access_scope {
    type = "cluster"
  }
}
