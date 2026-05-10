data "aws_caller_identity" "current" {}

data "aws_iam_role" "this" {
  for_each = local.cluster_user_arns
  name     = each.value
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket  = "epam-terrform-state-bucket"
    key     = "895587011312_NetworkAdministrator/vpc/dual-stack/eks/dev/terraform.tfstate"
    region  = "eu-central-1"
    profile = "895587011312_AdministratorAccess"
  }
}

data "aws_route53_zone" "zones" {
  for_each = toset(local.domains)
  name     = each.value
}

# Addons
data "aws_eks_addon_version" "latest_coredns" {
  addon_name         = "coredns"
  kubernetes_version = 1.35
  most_recent        = true
}

data "aws_eks_addon_version" "latest_kube_proxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = 1.35
  most_recent        = true
}

data "aws_eks_addon_version" "latest_vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = 1.35
  most_recent        = true
}

data "aws_eks_addon_version" "latest_ebs_csi" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = 1.35
  most_recent        = true
}
