resource "aws_ec2_tag" "cluster_primary_sg_tag" {
  resource_id = module.eks_dev.cluster_primary_security_group_id
  key         = "karpenter.sh/discovery"
  value       = local.cluster_name
}
