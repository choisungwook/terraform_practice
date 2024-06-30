resource "aws_s3_bucket" "sungwook_upgrade_eks" {
  bucket = "sungwook-upgrade-eks"
}

resource "aws_iam_role" "access_s3_from_eks" {
  name               = "access-s3-from-eks"
  assume_role_policy = data.aws_iam_policy_document.access_s3_from_eks.json
}

data "aws_iam_policy_document" "access_s3_from_eks" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:access-s3"]
    }
  }
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "S3AccessPolicy"
  description = "Policy to allow access to S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.sungwook_upgrade_eks.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.sungwook_upgrade_eks.bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_access_policy" {
  role       = aws_iam_role.access_s3_from_eks.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}
