locals {
  cluster_name = "eks-academy-dev"
  region       = "eu-central-1"

  domains = [
    "imon.work",
    "imon.academy"
  ]

  contol_plane_subnets = {
    "public_ipv4" : [
      data.terraform_remote_state.vpc.outputs.public_ipv4_subnets["public_ipv4_a"],
      data.terraform_remote_state.vpc.outputs.public_ipv4_subnets["public_ipv4_b"]
    ],
    "public_dual" : [
      data.terraform_remote_state.vpc.outputs.public_dual_stack_subnets["public_dual_stack_a"],
      data.terraform_remote_state.vpc.outputs.public_dual_stack_subnets["public_dual_stack_b"]
    ]
  }

  cluster_principal_arns = {
    "clusterAdmin" : var.idenitiy_user_role_arns.clusterAdmin
    "devops" : var.idenitiy_user_role_arns.devops
    "dev" : var.idenitiy_user_role_arns.dev
    "audit" : var.idenitiy_user_role_arns.audit
  }
}
