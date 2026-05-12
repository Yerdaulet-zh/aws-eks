resource "aws_iam_policy" "eks_integration" {
  name = "KarpenterControllerEKSIntegrationPolicy-${var.cluster_name}"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        "Sid" : "AllowAPIServerEndpointDiscovery",
        "Effect" : "Allow",
        "Resource" : "arn:${data.aws_partition.current.partition}:eks:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}",
        "Action" : "eks:DescribeCluster"
      }
    ]
  })
}
