resource "aws_iam_role_policy_attachment" "controller_node_lifecycle" {
  role       = aws_iam_role.karpenter_controller_role.name
  policy_arn = aws_iam_policy.node_lifecycle.arn
}

resource "aws_iam_role_policy_attachment" "controller_iam_integration" {
  role       = aws_iam_role.karpenter_controller_role.name
  policy_arn = aws_iam_policy.iam_integration.arn
}

resource "aws_iam_role_policy_attachment" "controller_eks_integration" {
  role       = aws_iam_role.karpenter_controller_role.name
  policy_arn = aws_iam_policy.eks_integration.arn
}

resource "aws_iam_role_policy_attachment" "controller_resource_discovery" {
  role       = aws_iam_role.karpenter_controller_role.name
  policy_arn = aws_iam_policy.resource_discovery.arn
}

resource "aws_iam_role_policy_attachment" "controller_zonal_shift" {
  role       = aws_iam_role.karpenter_controller_role.name
  policy_arn = aws_iam_policy.zonal_shift.arn
}

resource "aws_iam_role_policy_attachment" "controller_aws_sqs_queue_policy" {
  count = var.enable_interruption_handling ? 1 : 0

  role       = aws_iam_role.karpenter_controller_role.name
  policy_arn = aws_iam_policy.aws_sqs_queue_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "controller_interruption" {
  count = var.enable_interruption_handling ? 1 : 0

  role       = aws_iam_role.karpenter_controller_role.name
  policy_arn = aws_iam_policy.interruption[0].arn
}
