resource "aws_eks_addon" "addons" {
  for_each = { for addon in var.eks_addons : addon.name => addon }

  cluster_name         = aws_eks_cluster.main.id
  addon_name           = each.value.name
  addon_version        = each.value.version
  configuration_values = each.value.configuration_values

  depends_on = [aws_eks_node_group.main]
}
