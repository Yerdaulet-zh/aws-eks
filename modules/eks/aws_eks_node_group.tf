resource "aws_eks_node_group" "main" {
  for_each = var.node_group_configs

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.value.node_group_name
  node_role_arn   = aws_iam_role.eks_node_role[each.value.role_key].arn
  subnet_ids      = each.value.subnet_ids
  ami_type        = each.value.ami_type
  release_version = each.value.ami_release_version

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type

  update_config {
    max_unavailable            = each.value.update_config.max_unavailable
    max_unavailable_percentage = each.value.update_config.max_unavailable_percentage
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

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }

  tags = merge(
    each.value.tags
  )


  depends_on = [
    aws_iam_role.eks_node_role,
    aws_iam_role_policy_attachment.worker_node,
    aws_iam_role_policy_attachment.cni
  ]
}
