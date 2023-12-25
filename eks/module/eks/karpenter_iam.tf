resource "aws_iam_role" "eks_karpenter_irsa" {
  count = var.karpenter_enabled ? 1 : 0

  name               = "${var.eks_cluster_name}-karpenter-irsa"
  assume_role_policy = data.aws_iam_policy_document.eks_karpenter_irsa_assume_role_policy[0].json
  tags = {
    eks = "${var.eks_cluster_name}-irsa"
  }
}

data "aws_iam_policy_document" "eks_karpenter_irsa_assume_role_policy" {
  count = var.karpenter_enabled ? 1 : 0

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
      values   = ["system:serviceaccount:karpenter:karpenter-irsa-sa"]
    }
  }
}

resource "aws_iam_policy" "eks_karpenter_irsa_policy" {
  count = var.karpenter_enabled ? 1 : 0

  name   = "${var.eks_cluster_name}-karpenter-irsa-policy"
  policy = data.aws_iam_policy_document.eks_karpenter_irsa_policy[0].json
}

data "aws_iam_policy_document" "eks_karpenter_irsa_policy" {
  count = var.karpenter_enabled ? 1 : 0

  version = "2012-10-17"
  statement {
    sid    = "Karpenter"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ec2:DescribeImages",
      "ec2:RunInstances",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeAvailabilityZones",
      "ec2:DeleteLaunchTemplate",
      "ec2:TerminateInstances",
      "ec2:CreateTags",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateFleet",
      "ec2:DescribeSpotPriceHistory",
      "ec2:TerminateInstances",
      "pricing:GetProducts",
      "iam:GetInstanceProfile",
      "iam:CreateInstanceProfile",
      "iam:TagInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:PassRole"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "EKSClusterEndpointLookup"
    effect    = "Allow"
    actions   = ["eks:DescribeCluster"]
    resources = [aws_eks_cluster.main.arn]
  }
  statement {
    sid    = "KarpenterSQS"
    effect = "Allow"
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage"
    ]
    resources = [aws_sqs_queue.karpenter_interruption_queue[0].arn]
  }
}

resource "aws_iam_role_policy_attachment" "eks_karpenter_irsa" {
  count = var.karpenter_enabled ? 1 : 0

  role       = aws_iam_role.eks_karpenter_irsa[0].name
  policy_arn = aws_iam_policy.eks_karpenter_irsa_policy[0].arn
}

resource "aws_iam_role" "eks_karpenter_fis" {
  count = var.karpenter_enabled ? 1 : 0

  name               = "${var.eks_cluster_name}-karpenter-fis"
  assume_role_policy = data.aws_iam_policy_document.eks_karpenter_fis_trust[0].json
  tags = {
    eks = "${var.eks_cluster_name}-fis"
  }
}

data "aws_iam_policy_document" "eks_karpenter_fis_trust" {
  count = var.karpenter_enabled ? 1 : 0

  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["fis.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_karpenter_fis_ec2_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorEC2Access"
  role       = aws_iam_role.eks_karpenter_fis[0].id
}

resource "aws_iam_role_policy_attachment" "eks_karpenter_fis_eks_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorEKSAccess"
  role       = aws_iam_role.eks_karpenter_fis[0].id
}

resource "aws_iam_policy" "eks_karpenter_fis" {
  count = var.karpenter_enabled ? 1 : 0

  name   = "${var.eks_cluster_name}-karpenter-fis"
  policy = data.aws_iam_policy_document.eks_karpenter_fis[0].json
}

data "aws_iam_policy_document" "eks_karpenter_fis" {
  count = var.karpenter_enabled ? 1 : 0

  version = "2012-10-17"
  statement {
    sid    = "Karpenter"
    effect = "Allow"
    actions = [
      "fis:InjectApiInternalError",
      "fis:InjectApiThrottleError",
      "fis:InjectApiUnavailableError"

    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "eks_karpenter_fis" {
  count = var.karpenter_enabled ? 1 : 0

  role       = aws_iam_role.eks_karpenter_fis[0].name
  policy_arn = aws_iam_policy.eks_karpenter_fis[0].arn
}
