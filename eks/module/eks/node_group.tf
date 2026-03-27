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

  # 커스텀 AMI 사용 시 NodeConfig user data를 자동 생성
  # managed node group은 커스텀 AMI + launch template 조합에서 user data를 자동 주입하지 않음
  # NodeConfig는 모듈이 항상 생성하고, 사용자 user_data가 있으면 MIME 파트로 병합
  user_data = each.value.ami_id != null ? base64encode(join("\n", compact([
    "MIME-Version: 1.0",
    "Content-Type: multipart/mixed; boundary=\"BOUNDARY\"",
    "",
    "--BOUNDARY",
    "Content-Type: application/node.eks.aws",
    "",
    "---",
    "apiVersion: node.eks.aws/v1alpha1",
    "kind: NodeConfig",
    "spec:",
    "  cluster:",
    "    name: ${aws_eks_cluster.main.name}",
    "    apiServerEndpoint: ${aws_eks_cluster.main.endpoint}",
    "    certificateAuthority: ${aws_eks_cluster.main.certificate_authority[0].data}",
    "    cidr: ${aws_eks_cluster.main.kubernetes_network_config[0].service_ipv4_cidr}",
    "",
    each.value["user_data"] != null ? "--BOUNDARY\nContent-Type: text/x-shellscript; charset=\"us-ascii\"\n\n${each.value["user_data"]}" : "",
    "--BOUNDARY--",
  ]))) : each.value["user_data"]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = each.value["disk_size"]
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }
}
