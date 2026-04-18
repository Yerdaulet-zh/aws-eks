resource "aws_eks_access_policy_association" "this" {
  # We need to check for duplicates by creating a unique key for entry
  # {user_arn}/{policy_arn} = {entry}
  for_each = {
    for entry in var.cluster_access_config : "${entry.user_arn}/${entry.policy_arn}" => entry
  }

  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = each.value.policy_arn
  principal_arn = each.value.user_arn

  access_scope {
    type       = each.value.access_scope.type
    namespaces = each.value.access_scope.type == "namespace" ? each.value.access_scope.namespaces : null
  }

  depends_on = [aws_eks_access_entry.this]
}
