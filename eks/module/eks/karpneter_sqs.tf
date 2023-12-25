resource "aws_sqs_queue" "karpenter_interruption_queue" {
  count = var.karpenter_enabled ? 1 : 0

  name                      = var.eks_cluster_name
  message_retention_seconds = 300
  sqs_managed_sse_enabled   = true
}

resource "aws_sqs_queue_policy" "karpenter_interruption" {
  count = var.karpenter_enabled ? 1 : 0

  queue_url = aws_sqs_queue.karpenter_interruption_queue[0].id
  policy    = data.aws_iam_policy_document.karpenter_interruption_queue[0].json
}

data "aws_iam_policy_document" "karpenter_interruption_queue" {
  count = var.karpenter_enabled ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com", "sqs.amazonaws.com"]
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.karpenter_interruption_queue[0].arn]
  }
}

resource "aws_cloudwatch_event_rule" "karpenter_spot_interruption" {
  count = var.karpenter_enabled ? 1 : 0

  name        = "karpenter_spot_interruption"
  description = "EC2 Spot Instance Interruption Warning"
  event_pattern = jsonencode({
    "source" : ["aws.ec2"],
    "detail-type" : ["EC2 Spot Instance Interruption Warning"]
  })
}

resource "aws_cloudwatch_event_target" "karpenter_spot_interruption" {
  count = var.karpenter_enabled ? 1 : 0

  rule      = aws_cloudwatch_event_rule.karpenter_spot_interruption[0].name
  target_id = "KarpenterQueueTarget"
  arn       = aws_sqs_queue.karpenter_interruption_queue[0].arn
}
