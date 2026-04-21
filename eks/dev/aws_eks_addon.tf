# ------ Pod Identity Agent Addon ------
resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "eks-pod-identity-agent"
  addon_version               = var.addon_configs.pod_identity_agent.addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  preserve                    = true

  configuration_values = jsonencode({
    resources   = var.addon_configs.pod_identity_agent.resources
    tolerations = var.addon_configs.pod_identity_agent.tolerations
  })
}

# ------ CoreDNS Addon ------
resource "aws_eks_addon" "core_dns" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "coredns"
  addon_version               = var.addon_configs.core_dns.addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  preserve                    = true

  configuration_values = jsonencode({
    replicaCount = var.addon_configs.core_dns.replicaCount
    resources    = var.addon_configs.core_dns.resources

    affinity = var.addon_configs.core_dns.enable_custom_affinity ? jsondecode(templatefile("${path.module}/templates/affinity.json.tftpl", {
      weight          = 100
      capacity_key    = "eks.amazonaws.com/capacityType"
      capacity_values = ["ON_DEMAND"] # "SPOT"
      label_key       = "k8s-app"
      label_value     = "coredns"
    })) : null # Using null allows the addon to use its internal defaults
  })

  depends_on = [aws_eks_addon.pod_identity_agent]
}

# ------ Kube-Proxy Addon ------
resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "kube-proxy"
  addon_version               = var.addon_configs.kube_proxy.addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  preserve                    = true

  configuration_values = jsonencode({
    resources   = var.addon_configs.kube_proxy.resources
    tolerations = var.addon_configs.kube_proxy.tolerations
  })

  depends_on = [aws_eks_addon.pod_identity_agent]
}

# ------ VPC CNI Addon ------
data "aws_iam_policy_document" "vpc_cni_pod_identity" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cni_role" {
  name               = "${aws_eks_cluster.main.name}-vpc-cni-role"
  assume_role_policy = data.aws_iam_policy_document.vpc_cni_pod_identity.json
}

# If the cluster is IPv6 then we need to add this policy.
# Default AmazonEKS_CNI_Policy has no policies approporate to IPv6

# This document aligns with the official AWS EKS IPv6 documentation
# See: https://docs.aws.amazon.com/eks/latest/userguide/deploy-ipv6-cluster.html
data "aws_iam_policy_document" "vpc_cni_ipv6" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:AssignIpv6Addresses",
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeInstanceTypes"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateTags"
    ]
    resources = ["arn:aws:ec2:*:*:network-interface/*"]
  }
}

resource "aws_iam_policy" "vpc_cni_ipv6" {
  count  = var.kubernetes_network_config.ip_family == "ipv6" ? 1 : 0
  name   = "${aws_eks_cluster.main.name}-vpc-cni-ipv6-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.vpc_cni_ipv6.json
}

# Attach the Standard IPv4 Managed Policy (Always needed for basic EC2 actions)
resource "aws_iam_role_policy_attachment" "vpc_cni_managed" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.cni_role.name
}

# Attach the Custom IPv6 Policy (Only if family is ipv6)
resource "aws_iam_role_policy_attachment" "vpc_cni_ipv6" {
  count      = var.kubernetes_network_config.ip_family == "ipv6" ? 1 : 0
  policy_arn = aws_iam_policy.vpc_cni_ipv6[0].arn
  role       = aws_iam_role.cni_role.name
}

resource "aws_eks_pod_identity_association" "vpc_cni" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "aws-node"
  role_arn        = aws_iam_role.cni_role.arn
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "vpc-cni"
  addon_version = var.addon_configs.vpc_cni.addon_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  preserve                    = true

  configuration_values = jsonencode({
    env = merge(
      {
        # Enable Prefix Delegation for high pod density.
        # See: https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
        ENABLE_PREFIX_DELEGATION = tostring(var.addon_configs.vpc_cni.enable_prefix_delegation)

        # Recommended to avoid "stuck traffic" (timeouts) & NetworkPolicies wont take affect when the PODs in the same node.
        # All because of the shorcut of packets, if it sees the destination being local then directly delivers to POD by skipping Policies.
        DISABLE_TCP_EARLY_DEMUX = tostring(var.addon_configs.vpc_cni.disable_tcp_early_demux)
      },
      # Only inject these if we are in IPv4 mode
      var.kubernetes_network_config.ip_family == "ipv4" ? {
        MINIMUM_IP_TARGET  = tostring(var.addon_configs.vpc_cni.minimum_ip_target)
        WARM_IP_TARGET     = tostring(var.addon_configs.vpc_cni.warm_ip_target)
        WARM_PREFIX_TARGET = tostring(var.addon_configs.vpc_cni.warm_prefix_target)
      } : {}
    )
  })

  depends_on = [aws_eks_addon.pod_identity_agent]
}

# ------ EBS CSI Addon ------
data "aws_iam_policy_document" "ebs_csi_pod_identity_trust" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_role" {
  name               = "${aws_eks_cluster.main.name}-ebs-csi-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_pod_identity_trust.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_role.name
}

resource "aws_eks_pod_identity_association" "ebs_csi" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_csi_role.arn
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = var.addon_configs.ebs_csi.addon_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  preserve                    = true

  configuration_values = jsonencode({
    # Deployment
    controller = {
      replicaCount = var.addon_configs.ebs_csi.controller.replicaCount
      resources    = var.addon_configs.ebs_csi.controller.resources

      affinity = var.addon_configs.ebs_csi.enable_custom_affinity ? jsondecode(templatefile("${path.module}/templates/affinity.json.tftpl", {
        weight          = 100
        capacity_key    = "eks.amazonaws.com/capacityType"
        capacity_values = ["ON_DEMAND"] # "SPOT"
        label_key       = "app.kubernetes.io/name"
        label_value     = "aws-ebs-csi-driver"
      })) : null
    }

    # DaemonSet
    node = {
      resources   = var.addon_configs.ebs_csi.node.resources
      tolerations = var.addon_configs.ebs_csi.node.tolerations
    }
  })

  depends_on = [aws_eks_addon.pod_identity_agent]
}
