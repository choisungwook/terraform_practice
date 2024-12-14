resource "aws_eks_cluster" "main" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_role.arn
  version  = var.eks_version

  bootstrap_self_managed_addons = var.auto_mode_enabled ? false : true

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
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = false
  }

  dynamic "compute_config" {
    for_each = length(var.cluster_compute_config) > 0 ? [var.cluster_compute_config] : []

    content {
      enabled       = try(compute_config.value.enabled, null)
      node_pools    = var.auto_mode_enabled ? try(compute_config.value.node_pools, []) : null
      node_role_arn = var.auto_mode_enabled && length(try(compute_config.value.node_pools, [])) > 0 ? try(compute_config.value.node_role_arn, aws_iam_role.eks_auto[0].arn, null) : null
    }
  }

  kubernetes_network_config {
    dynamic "elastic_load_balancing" {
      for_each = var.auto_mode_enabled ? [1] : []
      content {
        enabled = var.auto_mode_enabled
      }
    }

    ip_family         = var.cluster_ip_family
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
    service_ipv6_cidr = var.cluster_service_ipv6_cidr
  }

  dynamic "storage_config" {
    for_each = var.auto_mode_enabled ? [1] : []

    content {
      block_storage {
        enabled = var.auto_mode_enabled
      }
    }
  }
}
