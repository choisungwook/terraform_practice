resource "aws_iam_role" "eks_external_dns_irsa" {
  count = var.external_dns_enabled ? 1 : 0

  name               = "${var.eks_cluster_name}-external-dns-irsa"
  assume_role_policy = data.aws_iam_policy_document.eks_external_dns_irsa_assume_role_policy[0].json
  tags = {
    eks = "${var.eks_cluster_name}-irsa"
  }
}

data "aws_iam_policy_document" "eks_external_dns_irsa_assume_role_policy" {
  count = var.external_dns_enabled ? 1 : 0

  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.main.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.main.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:external-dns"]
    }
  }
}

resource "aws_iam_policy" "eks_external_dns_irsa_policy" {
  count = var.external_dns_enabled ? 1 : 0

  name   = "${var.eks_cluster_name}-external-dns-irsa-policy"
  policy = data.aws_iam_policy_document.eks_external_dns_irsa_policy[0].json
}

data "aws_iam_policy_document" "eks_external_dns_irsa_policy" {
  count = var.external_dns_enabled ? 1 : 0

  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "eks_external_dns_irsa" {
  count = var.external_dns_enabled ? 1 : 0

  role       = aws_iam_role.eks_external_dns_irsa[0].name
  policy_arn = aws_iam_policy.eks_external_dns_irsa_policy[0].arn
}
