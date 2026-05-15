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

  cluster_access_config = [
    {
      principal_arn     = data.aws_iam_role.this["clusterAdmin"].arn
      kubernetes_groups = []
      access_type       = "STANDARD"
      access_policy_association = [{
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        access_scope = {
          type       = "cluster"
          namespaces = []
        }
      }]
    },
    {
      principal_arn     = data.aws_iam_role.this["dev"].arn
      kubernetes_groups = []
      access_type       = "STANDARD"
      access_policy_association = [{
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
        access_scope = {
          type       = "namespace"
          namespaces = ["fastapi"]
        }
      }]
    },
    {
      principal_arn     = data.aws_iam_role.this["audit"].arn
      kubernetes_groups = []
      access_type       = "STANDARD"
      access_policy_association = [{
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
        access_scope = {
          type       = "namespace"
          namespaces = ["loki", "monitoring"]
        }
      }]
    },
  ]

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
    # System Node Group| Karpenter & AWS Addons
    "systen-critical-1" = {
      node_group_name     = "systen-critical-1"
      instance_types      = ["t3.large"]
      capacity_type       = "ON_DEMAND"
      subnet_ids          = [data.terraform_remote_state.vpc.outputs.public_dual_stack_subnets["public_dual_stack_a"]]
      ami_type            = "AL2023_x86_64_STANDARD"
      ami_release_version = "1.35.3-20260415"
      role_key            = "system-node-group"
      scaling_config = {
        desired_size = 2
        max_size     = 2
        min_size     = 2
      }
      update_config = {
        max_unavailable = 1
      }
      labels = { "intent" = "system-node-group" }
      taints = [
        {
          key    = "ClusterManagement"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
      enable_autoscaling = true
    },
  }

  node_group_iam_configs = {
    "system-node-group" = {
      role_name              = "system-node-group"
      enable_ssm             = false
      enable_cloudwatch_logs = true
      enable_ecr_ro_access   = true
      custom_policy_arns     = []
    },
  }
}
