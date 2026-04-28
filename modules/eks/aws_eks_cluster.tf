resource "aws_eks_cluster" "main" {
  name                          = var.cluster_config.cluster_name
  version                       = var.cluster_config.cluster_version
  role_arn                      = aws_iam_role.eks_cluster_role.arn
  deletion_protection           = var.cluster_config.deletion_protection
  bootstrap_self_managed_addons = var.cluster_config.bootstrap_self_managed_addons
  force_update_version          = var.cluster_config.force_update_version

  # Observability
  enabled_cluster_log_types = var.cluster_config.enabled_cluster_log_types

  access_config {
    authentication_mode = var.cluster_config.authentication_mode
  }

  control_plane_scaling_config {
    tier = var.cluster_config.control_plane_scaling_tier
  }

  kubernetes_network_config {
    ip_family = var.kubernetes_network_config.ip_family

    # LOGIC:
    # If family is IPv6, we MUST return null.
    # If family is IPv4 AND use_custom is true, we run our VPC check.
    # see: https://docs.aws.amazon.com/eks/latest/userguide/cni-ipv6.html
    service_ipv4_cidr = (var.kubernetes_network_config.ip_family == "ipv4" && var.kubernetes_network_config.service_ipv4_cidr.use_custom_service_cidr) ? (
      startswith(data.aws_vpc.this.cidr_block, var.kubernetes_network_config.service_ipv4_cidr.vpc_cidr_prefix_to_check)
      ? var.kubernetes_network_config.service_ipv4_cidr.first_cidr
      : var.kubernetes_network_config.service_ipv4_cidr.second_cidr
    ) : null
  }

  vpc_config {
    endpoint_private_access = var.vpc_config.endpoint_private_access
    endpoint_public_access  = var.vpc_config.endpoint_public_access
    subnet_ids              = var.vpc_config.contol_plane_subnets
    public_access_cidrs     = var.vpc_config.public_access_cidrs
    security_group_ids      = var.vpc_config.security_group_ids
  }

  # This block is only included when key arn is provided
  # If kms_key_arn = null, EKS will use the default AWS-managed encryption.
  dynamic "encryption_config" {
    for_each = var.cluster_config.kms_key_arn != null ? [1] : []
    content {
      resources = ["secrets"]
      provider {
        key_arn = var.cluster_config.kms_key_arn
      }
    }
  }

  upgrade_policy {
    support_type = var.cluster_config.upgrade_policy.support_type
  }

  zonal_shift_config {
    enabled = var.cluster_config.zonal_shift_enabled
  }

  depends_on = [aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy]

  timeouts {
    create = "120m"
    update = "120m"
    delete = "120m"
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_config.cluster_name}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}
