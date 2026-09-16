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
    for_each = var.auto_mode_enabled ? [var.cluster_compute_config] : []

    content {
      enabled       = true
      node_pools    = try(compute_config.value.node_pools, [])
      node_role_arn = length(try(compute_config.value.node_pools, [])) > 0 ? try(compute_config.value.node_role_arn, aws_iam_role.eks_auto[0].arn, null) : null
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

  control_plane_scaling_config {
    tier = var.control_plane_scaling_tier
  }

  dynamic "kube_api_server_config" {
    for_each = var.kube_api_server_config == null ? [] : [var.kube_api_server_config]

    content {
      event_ttl = kube_api_server_config.value.event_ttl

      dynamic "service_node_port_range" {
        for_each = kube_api_server_config.value.service_node_port_range == null ? [] : [kube_api_server_config.value.service_node_port_range]

        content {
          min_port = service_node_port_range.value.min_port
          max_port = service_node_port_range.value.max_port
        }
      }
    }
  }

  dynamic "kube_controller_manager_config" {
    for_each = var.kube_controller_manager_config == null ? [] : [var.kube_controller_manager_config]

    content {
      dynamic "horizontal_pod_autoscaler_controller_config" {
        for_each = kube_controller_manager_config.value.horizontal_pod_autoscaler_sync_period == null ? [] : [1]

        content {
          horizontal_pod_autoscaler_sync_period = kube_controller_manager_config.value.horizontal_pod_autoscaler_sync_period
        }
      }

      dynamic "pod_gc_controller_config" {
        for_each = kube_controller_manager_config.value.terminated_pod_gc_threshold == null ? [] : [1]

        content {
          terminated_pod_gc_threshold = kube_controller_manager_config.value.terminated_pod_gc_threshold
        }
      }
    }
  }

  dynamic "kube_scheduler_config" {
    for_each = var.kube_scheduler_config == null ? [] : [var.kube_scheduler_config]

    content {
      node_resources_fit {
        scoring_strategy {
          type = kube_scheduler_config.value.scoring_strategy_type

          dynamic "resource" {
            for_each = kube_scheduler_config.value.scoring_resources

            content {
              name   = resource.value.name
              weight = resource.value.weight
            }
          }
        }
      }
    }
  }
}
