resource "aws_eks_node_group" "main" {
  for_each = var.node_group_configs

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.value.node_group_name
  node_role_arn   = aws_iam_role.eks_node_role[each.value.role_key].arn
  subnet_ids      = each.value.subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type

  update_config {
    max_unavailable = 1
  }

  labels = each.value.labels

  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  depends_on = [
    aws_iam_role.eks_node_role,
    aws_iam_role_policy_attachment.worker_node,
    aws_iam_role_policy_attachment.cni
  ]
}
