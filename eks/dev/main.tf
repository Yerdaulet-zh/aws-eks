module "eks_dev" {
  source = "../../modules/eks"
  cluster_access_config = [{
    user_arn          = data.aws_iam_role.sso_admin.arn
    kubernetes_groups = []
    policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    access_scope = {
      type       = "cluster"
      namespaces = []
    }
  }]

  kubernetes_network_config = {
    ip_family = "ipv6"
    service_ipv4_cidr = {
      use_custom_service_cidr  = true
      vpc_cidr_prefix_to_check = "10."
      first_cidr               = "172.20.0.0/16" # If VPC is 10.x, use 172.x
      second_cidr              = "10.100.0.0/16" # If VPC is not 10.x, use 10.x
    }
  }

  node_group_configs = {
    # General purpose nodes
    "app1" = {
      node_group_name     = "app-workloads-1"
      instance_types      = ["t3.small", "t3.medium"]
      capacity_type       = "ON_DEMAND"
      subnet_ids          = [data.terraform_remote_state.vpc.outputs.public_dual_stack_subnets["public_dual_stack_a"]]
      ami_type            = "AL2023_x86_64_STANDARD"
      ami_release_version = "1.35.3-20260415"
      role_key            = "app*"
      desired_size        = 1
      max_size            = 2
      min_size            = 0
      labels              = { role = "state-full-less-apps" }
      taints              = []
    },
    "app2" = {
      node_group_name     = "app-workloads-2"
      instance_types      = ["t3.small", "t3.medium"]
      capacity_type       = "ON_DEMAND"
      subnet_ids          = [data.terraform_remote_state.vpc.outputs.public_dual_stack_subnets["public_dual_stack_a"]]
      ami_type            = "AL2023_x86_64_STANDARD"
      ami_release_version = "1.35.3-20260415"
      role_key            = "app*"
      desired_size        = 1
      max_size            = 2
      min_size            = 0
      labels              = { role = "state-full-less-apps" }
      taints              = []
    },
    # Spot instances
    "ai-ml-workers" = {
      node_group_name     = "ai-ml-workers"
      instance_types      = ["t3.small", "t3.medium", "t3.large"]
      capacity_type       = "SPOT"
      subnet_ids          = [data.terraform_remote_state.vpc.outputs.public_dual_stack_subnets["public_dual_stack_a"]]
      ami_type            = "AL2023_x86_64_STANDARD"
      ami_release_version = "1.35.3-20260415"
      role_key            = "ai-ml-workloads"
      desired_size        = 1
      max_size            = 2
      min_size            = 0
      labels              = { role = "ai-worker" }
      taints = [{
        key    = "workload"
        value  = "heavy"
        effect = "NO_SCHEDULE"
      }]
    }
  }
}
