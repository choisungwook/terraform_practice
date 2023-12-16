resource "aws_eks_node_group" "main" {
  for_each = var.managed_node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.value["node_group_name"]
  instance_types  = each.value["instance_types"]
  capacity_type   = each.value["capacity_type"]
  release_version = each.value["release_version"]
  disk_size       = each.value["disk_size"]
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = var.private_subnets_ids

  scaling_config {
    desired_size = each.value["desired_size"]
    max_size     = each.value["max_size"]
    min_size     = each.value["min_size"]
  }

  depends_on = [
    aws_eks_cluster.main,
    kubernetes_config_map.aws_auth_configmap,
    aws_iam_role_policy_attachment.node_group_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_group_AmazonEC2RoleforSSM,
    aws_iam_role_policy_attachment.node_group_AmazonEKS_CNI_Policy,
  ]
}
