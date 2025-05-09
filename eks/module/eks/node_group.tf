resource "aws_eks_node_group" "main" {
  for_each = var.managed_node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.value["node_group_name"]
  instance_types  = each.value["instance_types"]
  capacity_type   = each.value["capacity_type"]
  # ami_id가 설정되면 release_version은 null로 설정됩니다.
  release_version = each.value["ami_id"] == null ? each.value["release_version"] : null
  ami_type        = each.value["ami_type"] != null ? each.value["ami_type"] : null
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = var.private_subnets_ids
  labels          = each.value["labels"]

  dynamic "taint" {
    for_each = each.value["taints"]
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  scaling_config {
    desired_size = each.value["desired_size"]
    max_size     = each.value["max_size"]
    min_size     = each.value["min_size"]
  }

  launch_template {
    id      = aws_launch_template.node_group[each.key].id
    version = aws_launch_template.node_group[each.key].latest_version
  }

  timeouts {
    create = "5m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [
    aws_eks_access_entry.cluster_admins,
    aws_iam_role_policy_attachment.node_group_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_group_AmazonEC2RoleforSSM,
    aws_iam_role_policy_attachment.node_group_AmazonEKS_CNI_Policy,
  ]
}

resource "aws_launch_template" "node_group" {
  for_each = var.managed_node_groups

  name = format("%s-eks-nodegroup-%s", aws_eks_cluster.main.name, each.value["node_group_name"])

  # (optional) AMI_ID
  image_id = each.value.ami_id

  user_data = each.value["user_data"]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }
}
