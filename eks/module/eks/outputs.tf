output "kubeconfig-certificate-authority-data" {
  description = "kube config context"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "eks_cluster_arn" {
  description = "eks cluster arn"
  value       = aws_eks_cluster.main.arn
}
