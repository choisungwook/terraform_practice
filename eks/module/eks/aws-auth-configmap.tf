locals {
  worker_roles = [
    {
      rolearn  = aws_iam_role.node_group_role.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ]

  aws_auth_admin_roles = [
    for admin_role in var.aws_auth_admin_roles :
    {
      rolearn  = admin_role
      username = split("/", admin_role)[1]
      groups   = ["system:masters"]
    }
  ]
}

provider "kubernetes" {
  host                   = aws_eks_cluster.example.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.example.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args        = concat(["eks", "get-token", "--cluster-name", var.eks-name])
  }
}

resource "kubernetes_config_map" "aws_auth_configmap" {
  data = {
    mapRoles = yamlencode(concat(local.worker_roles, local.aws_auth_admin_roles))
  }

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  depends_on = [aws_eks_cluster.example]
}
