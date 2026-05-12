output "cluster_primary_security_group_id" {
  description = "The ID of the primary security group created by the EKS cluster"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}
