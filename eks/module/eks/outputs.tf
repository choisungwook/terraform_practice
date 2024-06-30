output "kubeconfig-certificate-authority-data" {
  description = "kube config context"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "eks_cluster_arn" {
  description = "eks cluster arn"
  value       = aws_eks_cluster.main.arn
}

output "oidc_provider_arn" {
  description = "oidc provider arn"
  value       = aws_iam_openid_connect_provider.main.arn
}

output "oidc_provider_url" {
  description = "oidc provider arn"
  value       = aws_iam_openid_connect_provider.main.url
}
