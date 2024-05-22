resource "aws_prometheus_workspace" "this" {
  alias = "eks-${var.eks_cluster_name}"

  tags = {
    AMPAgentlessScraper = ""
    Environment         = "EKS"
  }
}
