######################################################################
# EKS cluster role
######################################################################
resource "aws_iam_role" "eks_role" {
  name               = "${var.eks_cluster_name}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster.json
}

data "aws_iam_policy_document" "eks_cluster" {
  statement {
    sid = "EKSClusterAssumeRole"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
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

resource "aws_iam_policy_attachment" "eks_cluster_automode_storage" {
  name       = "${var.eks_cluster_name}-AmazonEKSBlockStoragePolicy"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  roles      = [aws_iam_role.eks_role.name]
}

resource "aws_iam_policy_attachment" "eks_cluster_automode_compute" {
  name       = "${var.eks_cluster_name}-AmazonEKSComputePolicy"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
  roles      = [aws_iam_role.eks_role.name]
}

resource "aws_iam_policy_attachment" "eks_cluster_automode_loadbalancing" {
  name       = "${var.eks_cluster_name}-AmazonEKSLoadBalancingPolicy"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  roles      = [aws_iam_role.eks_role.name]
}

resource "aws_iam_policy_attachment" "eks_cluster_automode_networking" {
  name       = "${var.eks_cluster_name}-AmazonEKSNetworkingPolicy"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  roles      = [aws_iam_role.eks_role.name]
}

######################################################################
# managed node group role
######################################################################

resource "aws_iam_role" "node_group_role" {
  name               = "${var.eks_cluster_name}-eks-worker-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_group.json
}

data "aws_iam_policy_document" "node_group" {
  statement {
    sid = "EKSClusterAssumeRole"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
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

######################################################################
# OIDC provider
######################################################################

data "tls_certificate" "eks_oidc_cert" {
  count = var.oidc_provider_enabled ? 1 : 0
  url   = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "main" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc_cert[0].certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.eks_oidc_cert[0].url
}

# ######################################################################
# # EKS auto Mode Node Role
# ######################################################################

resource "aws_iam_role" "eks_auto" {
  count = var.auto_mode_enabled ? 1 : 0

  name               = "${var.eks_cluster_name}-AmazonEKSAutoNodeRole"
  assume_role_policy = data.aws_iam_policy_document.eks_auto[0].json
}

data "aws_iam_policy_document" "eks_auto" {
  count = var.auto_mode_enabled ? 1 : 0

  statement {
    sid = "EKSAutoNodeAssumeRole"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_auto_AmazonEKSWorkerNodeMinimalPolicy" {
  count = var.auto_mode_enabled ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.eks_auto[0].id
}

resource "aws_iam_role_policy_attachment" "eks_auto_AmazonEC2ContainerRegistryPullOnly" {
  count = var.auto_mode_enabled ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.eks_auto[0].id
}
