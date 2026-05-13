locals {
  policy_associations = flatten([
    for entry in var.cluster_access_config : [
      for policy in entry.access_policy_association : {
        key           = "${entry.principal_arn}-${policy.policy_arn}"
        principal_arn = entry.principal_arn
        policy_arn    = policy.policy_arn
        access_scope  = policy.access_scope
      }
    ]
  ])
}
