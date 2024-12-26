resource "aws_iam_role" "grafana_irsa" {
  count = var.enable_amp ? 1 : 0

  name               = "${var.eks_cluster_name}-grafana-irsa"
  assume_role_policy = data.aws_iam_policy_document.grafana_irsa_assume_role_policy[0].json
  tags = {
    Name = "${var.eks_cluster_name}-grafana-irsa"
  }
}

data "aws_iam_policy_document" "grafana_irsa_assume_role_policy" {
  count = var.enable_amp ? 1 : 0

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
      values   = ["system:serviceaccount:monitoring:grafana-irsa-sa"]
    }
  }
}

resource "aws_iam_policy" "grafana_irsa_policy" {
  count = var.enable_amp ? 1 : 0

  name   = "${var.eks_cluster_name}-grafana-irsa-policy"
  policy = data.aws_iam_policy_document.grafana_irsa_policy[0].json
}

data "aws_iam_policy_document" "grafana_irsa_policy" {
  count = var.enable_amp ? 1 : 0

  version = "2012-10-17"

  # reference: https://docs.aws.amazon.com/prometheus/latest/userguide/set-up-irsa.html#set-up-irsa-query
  statement {
    effect = "Allow"
    actions = [
      "aps:QueryMetrics",
      "aps:GetSeries",
      "aps:GetLabels",
      "aps:GetMetricMetadata"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "grafana_irsa" {
  count = var.enable_amp ? 1 : 0

  role       = aws_iam_role.grafana_irsa[0].name
  policy_arn = aws_iam_policy.grafana_irsa_policy[0].arn
}
