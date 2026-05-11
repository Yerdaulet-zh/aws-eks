resource "aws_eks_pod_identity_association" "karpenter" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account_name

  role_arn = aws_iam_role.karpenter_controller_role.arn
}
