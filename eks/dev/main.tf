module "eks_dev" {
  source = "../../modules/eks"
  cluster_config = {
    cluster_name                  = local.cluster_name
    cluster_version               = 1.35
    deletion_protection           = false
    bootstrap_self_managed_addons = false
    force_update_version          = false
    enabled_cluster_log_types     = ["api", "authenticator", "controllerManager", "scheduler"] # "audit"
    authentication_mode           = "API_AND_CONFIG_MAP"
    control_plane_scaling_tier    = "standard" # standard, tier-xl, tier-2xl, tier-4xl, tier-8xl

    kms_key_arn = null

    upgrade_policy = {
      support_type = "STANDARD"
    }

    zonal_shift_enabled = false
  }

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
    ip_family = "ipv4"
    service_ipv4_cidr = {
      use_custom_service_cidr  = true
      vpc_cidr_prefix_to_check = "10."
      first_cidr               = "172.20.0.0/16" # If VPC is 10.x, use 172.x
      second_cidr              = "10.100.0.0/16" # If VPC is not 10.x, use 10.x
    }
  }

  vpc_config = {
    endpoint_private_access = true
    endpoint_public_access  = true
    contol_plane_subnets    = local.contol_plane_subnets["public_dual"]
    public_access_cidrs = [
      "0.0.0.0/0"
    ]
    security_group_ids = []
  }

  node_group_configs = {
    # General purpose nodes
    "app1" = {
      node_group_name     = "app-workloads-1"
      instance_types      = ["t3.large"]
      capacity_type       = "ON_DEMAND"
      subnet_ids          = [data.terraform_remote_state.vpc.outputs.public_dual_stack_subnets["public_dual_stack_a"]]
      ami_type            = "AL2023_x86_64_STANDARD"
      ami_release_version = "1.35.3-20260415"
      role_key            = "app*"
      scaling_config = {
        desired_size = 1
        max_size     = 2
        min_size     = 0
      }
      update_config = {
        # max_unavailable            = null
        max_unavailable_percentage = 25
      }
      labels             = { role = "state-full-less-apps" }
      taints             = []
      enable_autoscaling = true
    },
    "app2" = {
      node_group_name     = "app-workloads-2"
      instance_types      = ["t3.large"]
      capacity_type       = "ON_DEMAND"
      subnet_ids          = [data.terraform_remote_state.vpc.outputs.public_dual_stack_subnets["public_dual_stack_a"]]
      ami_type            = "AL2023_x86_64_STANDARD"
      ami_release_version = "1.35.3-20260415"
      role_key            = "app*"
      scaling_config = {
        desired_size = 1
        max_size     = 2
        min_size     = 0
      }
      update_config = {
        max_unavailable            = null
        max_unavailable_percentage = 25
      }
      labels             = { role = "state-full-less-apps" }
      taints             = []
      enable_autoscaling = true
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
      scaling_config = {
        desired_size = 2
        max_size     = 4
        min_size     = 0
      }
      update_config = {
        max_unavailable            = null
        max_unavailable_percentage = 25
      }
      labels = { role = "ai-worker" }
      taints = []
      # taints = [{
      #   key    = "workload"
      #   value  = "heavy"
      #   effect = "NO_SCHEDULE"
      # }]
      enable_autoscaling = true
    },
    # Stateful workloads
    "stateful-node1" = {
      node_group_name     = "stateful-node1"
      instance_types      = ["t3.large"]
      capacity_type       = "ON_DEMAND"
      subnet_ids          = [data.terraform_remote_state.vpc.outputs.public_dual_stack_subnets["public_dual_stack_a"]]
      ami_type            = "AL2023_x86_64_STANDARD"
      ami_release_version = "1.35.3-20260415"
      role_key            = "stateful*"
      scaling_config = {
        desired_size = 1
        max_size     = 2
        min_size     = 0
      }
      update_config = {
        max_unavailable            = null
        max_unavailable_percentage = 25
      }
      labels = { role = "statefull" }
      taints = [{
        key    = "workload"
        value  = "stateful"
        effect = "NO_SCHEDULE"
      }]
      enable_autoscaling = true
    },
    "stateful-node2" = {
      node_group_name     = "stateful-node2"
      instance_types      = ["t3.large"]
      capacity_type       = "ON_DEMAND"
      subnet_ids          = [data.terraform_remote_state.vpc.outputs.public_dual_stack_subnets["public_dual_stack_a"]]
      ami_type            = "AL2023_x86_64_STANDARD"
      ami_release_version = "1.35.3-20260415"
      role_key            = "stateful*"
      scaling_config = {
        desired_size = 1
        max_size     = 2
        min_size     = 0
      }
      update_config = {
        max_unavailable            = null
        max_unavailable_percentage = 25
      }
      labels = { role = "statefull" }
      taints = [{
        key    = "workload"
        value  = "stateful"
        effect = "NO_SCHEDULE"
      }]
      enable_autoscaling = true
    },
    "stateful-node3" = {
      node_group_name     = "stateful-node3"
      instance_types      = ["t3.large"]
      capacity_type       = "ON_DEMAND"
      subnet_ids          = [data.terraform_remote_state.vpc.outputs.public_dual_stack_subnets["public_dual_stack_a"]]
      ami_type            = "AL2023_x86_64_STANDARD"
      ami_release_version = "1.35.3-20260415"
      role_key            = "stateful*"
      scaling_config = {
        desired_size = 1
        max_size     = 2
        min_size     = 0
      }
      update_config = {
        max_unavailable            = null
        max_unavailable_percentage = 25
      }
      labels = { role = "statefull" }
      taints = [{
        key    = "workload"
        value  = "stateful"
        effect = "NO_SCHEDULE"
      }]
      enable_autoscaling = true
    },
  }
}
