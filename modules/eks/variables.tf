variable "cluster_config" {
  description = <<EOT
    Configuration object for the EKS Cluster, including networking, security, and resiliency settings.

    Zonal shift: https://docs.aws.amazon.com/r53recovery/latest/dg/arc-zonal-shift.resource-types.eks.html
  EOT

  type = object({
    cluster_name                  = string
    cluster_version               = number
    deletion_protection           = bool
    bootstrap_self_managed_addons = bool
    force_update_version          = bool
    enabled_cluster_log_types     = list(string)
    authentication_mode           = string
    control_plane_scaling_tier    = string

    kms_key_arn = string

    upgrade_policy = object({
      support_type = string
    })

    zonal_shift_enabled = bool
  })

  default = {
    cluster_name                  = "eks-academy"
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
}

variable "kubernetes_network_config" {
  description = <<EOT
  Configuration for the EKS cluster's internal networking.
  - ip_family: Use 'ipv4' (default) or 'ipv6'. Changing this forces a new cluster.
  - service_ipv4_cidr: Logic for internal Service IP ranges. NOT PODS
    - use_custom_service_cidr: If false, AWS automatically picks 10.100.0.0/16 or 172.20.0.0/16.
    - vpc_cidr_prefix_to_check: The string (e.g., "10.") to look for in the VPC CIDR to avoid overlap.
    - first_cidr: The range to use if the VPC prefix matches.
    - second_cidr: The fallback range if the VPC prefix does NOT match.
  EOT

  type = object({
    ip_family = string
    service_ipv4_cidr = object({
      use_custom_service_cidr  = bool
      vpc_cidr_prefix_to_check = string
      first_cidr               = string
      second_cidr              = string
    })
  })

  default = {
    ip_family = "ipv4"
    service_ipv4_cidr = {
      use_custom_service_cidr  = true
      vpc_cidr_prefix_to_check = "10."
      first_cidr               = "172.20.0.0/16" # If VPC is 10.x, use 172.x
      second_cidr              = "10.100.0.0/16" # If VPC is not 10.x, use 10.x
    }
  }
}

variable "vpc_config" {
  description = <<EOT
Configuration for the EKS Cluster VPC and API Server Endpoints.

- endpoint_private_access: (Recommended: true) Whether the Amazon EKS private API server endpoint is enabled.
  When enabled, worker nodes and kube-proxy communicate with the control plane within the VPC via
  cross-account ENIs, avoiding the public internet.

- endpoint_public_access: (Default: true) Whether the API server is reachable from the internet.
  If set to false, you must have a VPN or Bastion to reach the cluster.

- public_access_cidrs: List of CIDR blocks allowed to access the public endpoint.
  NOTE: If private access is disabled, your NAT Gateway/Node IPs MUST be in this list
  for nodes to register successfully.

- security_group_ids: (Optional) IDs for the ENIs EKS creates in your subnets to allow
  the Control Plane to talk to your Worker Nodes.
EOT

  type = object({
    endpoint_private_access = bool
    endpoint_public_access  = bool
    contol_plane_subnets    = list(string)
    public_access_cidrs     = list(string) # list(string)
    security_group_ids      = list(string)
  })

  default = {
    endpoint_private_access = true
    endpoint_public_access  = true
    contol_plane_subnets    = ["value"]
    public_access_cidrs = [
      # ---------- IPv4 ----------
      # Kazakhtelecom
      "2.132.0.0/14",
      "95.56.0.0/14",
      "147.30.0.0/16",

      # Kcell / Activ
      "2.72.0.0/13",
      "164.0.0.0/16",

      # Kar-Tel (Beeline)
      "5.34.0.0/17",
      "37.99.0.0/17",
      "87.247.0.0/18",

      # Tele2 / Altel
      "176.64.0.0/16",
      "188.162.0.0/16",

      # ---------- IPv6 ----------
      # Kcell / Activ,
      "2a02:50c0::/29",

      # Kazakhtelecom
      "2a00:13c8::/32",

      # Mobile Telecom-Service (Tele2/Altel)
      "2a03:32c0::/32",

      # Kar-Tel (Beeline)
      "2a10:b780::/29",

      # Freedom Telecom
      "2a04:3b00::/29",

      # Yandex Cloud (KZ)
      "2a12:5a40::/29"
    ]
    security_group_ids = []
  }
}

variable "cluster_access_config" {
  description = <<EOT
    - Cluster Access Configuration only supports access_entry type of "STANDARD"
    - Configuration is designed to manage multiple users including cluster admin
EOT
  type = list(object({
    user_arn          = string
    kubernetes_groups = list(string)
    policy_arn        = string
    access_scope = object({
      type       = string
      namespaces = list(string)
    })
  }))

  default = [
    {
      user_arn          = "admin_iam_user_arn"
      kubernetes_groups = []
      policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      access_scope = {
        type       = "cluster"
        namespaces = []
      }
    },
    {
      user_arn          = "network_iam_user_arn"
      kubernetes_groups = ["junior-network-manager"]                                   # restrict via RBAC the permissions to certain groups and resources
      policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy" # for jun-network engineer might be dangerous
      access_scope = {
        type       = "namespace"
        namespaces = ["dev-frontend", "dev-backend"]
      }
    },
  ]
}

variable "addon_configs" {
  type = object({
    metrics_server = object({
      addon_version = string
    })

    pod_identity_agent = object({
      addon_version = string
      resources = object({
        limits = object({
          cpu    = string
          memory = string
        })
        requests = object({
          cpu    = string
          memory = string
        })
      })
      tolerations = list(
        object({
          operator = string
          effect   = string
        })
      )
    })

    core_dns = object({
      addon_version = string
      replicaCount  = number
      resources = object({
        limits = object({
          cpu    = string
          memory = string
        })
        requests = object({
          cpu    = string
          memory = string
        })
      })
      enable_custom_affinity = bool
    })

    kube_proxy = object({
      addon_version = string
      mode          = string
      resources = object({
        limits = object({
          cpu    = string
          memory = string
        })
        requests = object({
          cpu    = string
          memory = string
        })
      })
    })

    vpc_cni = object({
      addon_version            = string
      enable_prefix_delegation = bool
      disable_tcp_early_demux  = bool
      minimum_ip_target        = number
      warm_ip_target           = number
      warm_prefix_target       = number
    })

    ebs_csi = object({
      addon_version = string
      controller = object({
        replicaCount = number
        resources = object({
          limits = object({
            cpu    = string
            memory = string
          })
          requests = object({
            cpu    = string
            memory = string
          })
        })
      })

      node = object({
        resources = object({
          limits = object({
            cpu    = string
            memory = string
          })
          requests = object({
            cpu    = string
            memory = string
          })
        })
        tolerations = list(
          object({
            operator = string
            effect   = string
          })
        )
      })
      enable_custom_affinity = bool
    })
  })

  default = {
    metrics_server = {
      addon_version = null
    }

    pod_identity_agent = {
      addon_version = null
      resources = {
        limits = {
          cpu    = "100m"
          memory = "128Mi"
        }
        requests = {
          cpu    = "10m"
          memory = "64Mi"
        }
      }
      tolerations = [
        {
          operator = "Exists"
          effect   = "NoSchedule"
        },
        {
          operator = "Exists"
          effect   = "NoExecute"
        }
      ]
    }

    core_dns = {
      addon_version = null
      replicaCount  = 3
      resources = {
        limits = {
          cpu    = "100m"
          memory = "128Mi"
        }
        requests = {
          cpu    = "10m"
          memory = "64Mi"
        }
      }
      enable_custom_affinity = true
    }

    kube_proxy = {
      addon_version = null
      mode          = "nftables"
      resources = {
        limits = {
          cpu    = "100m"
          memory = "128Mi"
        }
        requests = {
          cpu    = "10m"
          memory = "64Mi"
        }
      }
    }

    vpc_cni = {
      # If null then default "stable" version for that specific cluster version
      addon_version            = null
      enable_prefix_delegation = true,
      disable_tcp_early_demux  = true,
      minimum_ip_target        = 16,
      warm_ip_target           = 10,
      warm_prefix_target       = 0,
    }

    ebs_csi = {
      addon_version = null
      controller = {
        replicaCount = 3
        resources = {
          limits = {
            cpu    = "100m"
            memory = "128Mi"
          }
          requests = {
            cpu    = "10m"
            memory = "64Mi"
          }
        }
      }

      node = {
        resources = {
          limits = {
            cpu    = "100m"
            memory = "128Mi"
          }
          requests = {
            cpu    = "10m"
            memory = "64Mi"
          }
        }
        tolerations = [
          {
            operator = "Exists"
            effect   = "NoSchedule"
          },
          {
            operator = "Exists"
            effect   = "NoExecute"
          }
        ]
      }
      enable_custom_affinity = true
    }
  }
}

variable "node_group_configs" {
  type = map(object({
    node_group_name     = string
    instance_types      = list(string)
    capacity_type       = string # "ON_DEMAND" or "SPOT"
    subnet_ids          = list(string)
    role_key            = string
    ami_type            = string
    ami_release_version = string

    # Scaling settings
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })

    update_config = optional(object({
      max_unavailable            = optional(number)
      max_unavailable_percentage = optional(number)
    }), { max_unavailable = 1 })

    # Kubernetes labels and taints
    labels = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))

    enable_autoscaling = bool
    tags               = optional(map(string), {})
  }))

  default = {
    # General purpose nodes
    "app1" = {
      node_group_name     = "app-workloads-1"
      instance_types      = ["t3.small", "t3.medium", "t3.large"]
      capacity_type       = "ON_DEMAND"
      subnet_ids          = []
      ami_type            = "AL2023_x86_64_STANDARD"
      ami_release_version = "1.35.3-20260415"
      role_key            = "app*"
      scaling_config = {
        desired_size = 1
        max_size     = 2
        min_size     = 0
      }
      update_config = {
        max_unavailable_percentage = 25
      }
      labels             = { role = "state-full-less-apps" }
      taints             = []
      enable_autoscaling = true
    },
    "app2" = {
      node_group_name     = "app-workloads-2"
      instance_types      = ["t3.small", "t3.medium", "t3.large"]
      capacity_type       = "ON_DEMAND"
      subnet_ids          = []
      ami_type            = "AL2023_x86_64_STANDARD"
      ami_release_version = "1.35.3-20260415"
      role_key            = "app*"
      scaling_config = {
        desired_size = 1
        max_size     = 2
        min_size     = 0
      }
      update_config = {
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
      subnet_ids          = []
      ami_type            = "AL2023_x86_64_STANDARD"
      ami_release_version = "1.35.3-20260415"
      role_key            = "ai-ml-workloads"
      scaling_config = {
        desired_size = 1
        max_size     = 2
        min_size     = 0
      }
      update_config = {
        max_unavailable_percentage = 25
      }
      labels = { role = "ai-worker" }
      taints = [{
        key    = "workload"
        value  = "heavy"
        effect = "NO_SCHEDULE"
      }]
      enable_autoscaling = true
    }
  }
}

variable "node_group_iam_configs" {
  type = map(object({
    role_name              = string
    enable_ssm             = bool
    enable_cloudwatch_logs = bool
    enable_ecr_ro_access   = bool
    custom_policy_arns     = list(string)
  }))

  default = {
    "app*" = {
      role_name              = "general-purpose-app"
      enable_ssm             = true
      enable_cloudwatch_logs = true
      enable_ecr_ro_access   = true
      custom_policy_arns     = []
    },
    "ai-ml-workloads" = {
      role_name              = "ai-ml-workloads"
      enable_ssm             = true
      enable_cloudwatch_logs = true
      enable_ecr_ro_access   = true
      custom_policy_arns     = []
    }
  }
}
