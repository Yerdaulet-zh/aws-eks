module "karpenter" {
  source               = "../../modules/karpenter"
  cluster_name         = local.cluster_name
  namespace            = "kube-system"
  service_account_name = "karpenter-sa"

  enable_interruption_handling = true
  enable_ecr_ro                = true
  enable_node_ssm              = false
  enable_cloudwatch_logs       = true
}
