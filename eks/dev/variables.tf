variable "cluster_config" {
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
    public_access_cidrs     = list(string)
    security_group_ids      = list(string)
  })

  default = {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    security_group_ids      = []
  }
}

