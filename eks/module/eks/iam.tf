resource "aws_iam_role" "eks_role" {
  name = "${var.eks_cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "node_group_role" {
  name = "${var.eks_cluster_name}-eks-worker-node-role"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy_attachment" "eks_cluster_policy" {
  name       = "${var.eks_cluster_name}-AmazonEKSClusterPolicyAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  roles      = [aws_iam_role.eks_role.name]
}

resource "aws_iam_policy_attachment" "eks_cluster_vpc_controller" {
  name       = "${var.eks_cluster_name}-AmazonEKSClusterPolicyAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  roles      = [aws_iam_role.eks_role.name]
}

resource "aws_iam_role_policy_attachment" "node_group_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_role.id
}

resource "aws_iam_role_policy_attachment" "node_group_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_role.id
}

resource "aws_iam_role_policy_attachment" "node_group_AmazonEC2RoleforSSM" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.node_group_role.id
}

resource "aws_iam_role_policy_attachment" "node_group_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_role.id
}

resource "aws_iam_role_policy_attachment" "node_group_CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.node_group_role.id
}

////
// OIDC provider
///

data "tls_certificate" "eks_oidc_cert" {
  count = var.oidc_provider_enabled ? 1 : 0
  url   = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "main" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc_cert[0].certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.eks_oidc_cert[0].url
}
