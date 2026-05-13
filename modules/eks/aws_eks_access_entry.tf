resource "aws_eks_access_entry" "this" {
  for_each = {
    for entry in var.cluster_access_config :
    entry.principal_arn => entry
  }

  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = each.value.principal_arn
  kubernetes_groups = each.value.kubernetes_groups
  type              = each.value.access_type
}
