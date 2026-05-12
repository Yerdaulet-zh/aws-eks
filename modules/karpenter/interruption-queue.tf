resource "aws_sqs_queue" "karpenter" {
  count = var.enable_interruption_handling ? 1 : 0

  name                      = "${var.cluster_name}-karpenter"
  message_retention_seconds = 300
  sqs_managed_sse_enabled   = true
}

resource "aws_iam_policy" "interruption" {
  count = var.enable_interruption_handling ? 1 : 0

  name = "KarpenterControllerInterruptionPolicy-${var.cluster_name}"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        "Sid" : "AllowInterruptionQueueActions",
        "Effect" : "Allow",
        "Resource" : "${aws_sqs_queue.karpenter[0].arn}",
        "Action" : [
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage"
        ]
      }
    ]
  })
}
