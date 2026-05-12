
resource "aws_iam_policy" "resource_discovery" {
  name = "KarpenterControllerResourceDiscoveryPolicy-${var.cluster_name}"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        "Sid" : "AllowRegionalReadActions",
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : [
          "ec2:DescribeCapacityReservations",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribePlacementGroups",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSubnets"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestedRegion" : "${data.aws_region.current.region}"
          }
        }
      },

      {
        "Sid" : "AllowSSMReadActions",
        "Effect" : "Allow",
        "Resource" : "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.region}::parameter/aws/service/*",
        "Action" : "ssm:GetParameter"
      },

      {
        "Sid" : "AllowPricingReadActions",
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : "pricing:GetProducts"
      },

      {
        "Sid" : "AllowUnscopedInstanceProfileListAction",
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : "iam:ListInstanceProfiles"
      },

      {
        "Sid" : "AllowInstanceProfileReadActions",
        "Effect" : "Allow",
        "Resource" : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*",
        "Action" : "iam:GetInstanceProfile"
      }
    ]
  })
}
