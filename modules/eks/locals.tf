locals {
  contol_plane_subnets = [
    data.terraform_remote_state.vpc.outputs.public_dual_stack_subnets["public_dual_stack_a"],
    data.terraform_remote_state.vpc.outputs.public_dual_stack_subnets["public_dual_stack_b"]
  ]

  worker_node_subnets = [
    data.terraform_remote_state.vpc.outputs.public_dual_stack_subnets["public_dual_stack_a"],
    data.terraform_remote_state.vpc.outputs.private_dual_stack_subnets["private_dual_stack_a"],
  ]
}

output "contol_plane_subnets" {
  value = local.contol_plane_subnets
}

output "worker_node_subnets" {
  value = local.worker_node_subnets
}
