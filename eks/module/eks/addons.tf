resource "aws_eks_addon" "before_compute" {
  for_each = { for addon in var.eks_addons : addon.name => addon if addon.before_compute }

  cluster_name         = aws_eks_cluster.main.id
  addon_name           = each.value.name
  addon_version        = each.value.version
  configuration_values = each.value.configuration_values

  dynamic "pod_identity_association" {
    for_each = each.value.pod_identity_associations
    content {
      role_arn        = pod_identity_association.value.role_arn
      service_account = pod_identity_association.value.service_account
    }
  }

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
}

resource "aws_eks_addon" "after_compute" {
  for_each = { for addon in var.eks_addons : addon.name => addon if !addon.before_compute }

  cluster_name         = aws_eks_cluster.main.id
  addon_name           = each.value.name
  addon_version        = each.value.version
  configuration_values = each.value.configuration_values

  dynamic "pod_identity_association" {
    for_each = each.value.pod_identity_associations
    content {
      role_arn        = pod_identity_association.value.role_arn
      service_account = pod_identity_association.value.service_account
    }
  }

  depends_on = [
    aws_eks_addon.before_compute,
    aws_eks_node_group.main,
  ]

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
}
