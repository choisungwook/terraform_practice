resource "aws_eks_pod_identity_association" "main" {
  for_each = var.pod_identity_associations

  cluster_name    = aws_eks_cluster.main.name
  namespace       = each.value.namespace
  service_account = each.value.service_account
  role_arn        = each.value.role_arn

  depends_on = [
    aws_eks_addon.after_compute,
    aws_eks_addon.before_compute,
  ]
}
