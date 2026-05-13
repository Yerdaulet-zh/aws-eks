resource "aws_eks_access_entry" "this" {
  # distinct(list) - Removes duplicates, keeps original order
  # toset(list)    - Removes duplicates, but converts to a Set (loses order, often sorts)
  # flatten(list)  - Collapses nested lists into a single flat list (often used before distinct).

  # Some users may require multiple policies to be attched at aws_eks_access_policy_association resource
  for_each = toset([for entry in var.cluster_access_config : entry.principal_arn])

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.value
  # Extract unique groups for this specific user from the config list
  kubernetes_groups = distinct(flatten([
    for entry in var.cluster_access_config : entry.kubernetes_groups
    if entry.principal_arn == each.value
  ]))
  type = distinct(flatten([
    for entry in var.cluster_access_config : entry.access_type
    if entry.principal_arn == each.value
  ]))
}
