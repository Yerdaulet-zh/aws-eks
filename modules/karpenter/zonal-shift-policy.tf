
resource "aws_iam_policy" "zonal_shift" {
  name = "KarpenterControllerZonalShiftPolicy-${var.cluster_name}"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        "Sid" : "AllowZonalShiftStatusReadOnly",
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : [
          "arc-zonal-shift:GetManagedResource"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceIdentifier" : "arn:${data.aws_partition.current.partition}:eks:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"
          }
        }
      }
    ]
  })
}
