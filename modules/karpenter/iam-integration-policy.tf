resource "aws_iam_policy" "iam_integration" {
  name = "KarpenterControllerIAMIntegrationPolicy-${var.cluster_name}"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowPassingInstanceRole"
        Effect = "Allow"

        Resource = aws_iam_role.karpenter_node_role.arn

        Action = [
          "iam:PassRole"
        ]

        Condition = {
          StringEquals = {
            "iam:PassedToService" = [
              "ec2.amazonaws.com",
              "ec2.amazonaws.com.cn"
            ]
          }
        }
      }
    ]
  })
}
