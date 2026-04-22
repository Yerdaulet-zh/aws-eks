data "aws_caller_identity" "current" {}

data "aws_iam_role" "sso_admin" {
  name = var.sso_admin_iam_name
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
