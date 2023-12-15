output "kubeconfig-certificate-authority-data" {
  description = "kube config context"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}
