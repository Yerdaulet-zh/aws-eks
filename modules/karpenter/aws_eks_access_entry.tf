resource "aws_eks_access_entry" "this" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.karpenter_node_role.arn

  kubernetes_groups = []

  type = "EC2_LINUX"

  lifecycle {
    ignore_changes = [
      kubernetes_groups,
    ]
  }
}
