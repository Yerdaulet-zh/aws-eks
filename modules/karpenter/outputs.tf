output "karpenter_node_role_name" {
  value = aws_iam_role.karpenter_node_role.name
}

output "karpenter_node_role_arn" {
  value = aws_iam_role.karpenter_node_role.arn
}

output "karpenter_controller_role_arn" {
  value = aws_iam_role.karpenter_controller_role.arn
}

output "karpenter_interruption_queue_name" {
  value = aws_sqs_queue.karpenter["*"].name
}

output "karpenter_instance_profile_name" {
  value = aws_iam_instance_profile.karpenter_node_instance_profile.name
}
