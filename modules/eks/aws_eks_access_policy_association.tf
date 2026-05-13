resource "aws_eks_access_policy_association" "this" {
  for_each = {
    for p in local.policy_associations : p.key => p
  }

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.access_scope.type
    namespaces = each.value.access_scope.type == "namespace" ? each.value.access_scope.namespaces : null
  }

  depends_on = [aws_eks_access_entry.this]
}
