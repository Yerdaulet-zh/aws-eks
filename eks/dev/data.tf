data "aws_caller_identity" "current" {}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket  = "epam-terrform-state-bucket"
    key     = "895587011312_NetworkAdministrator/vpc/dual-stack/eks/dev/terraform.tfstate"
    region  = "eu-central-1"
    profile = "895587011312_AdministratorAccess"
  }
}

# # Fetch the NVIDIA-optimized AMI version
# data "aws_ssm_parameter" "eks_ami_nvidia_amazon_linux_2023" {
#   name = "/aws/service/eks/optimized-ami/${var.cluster_config.cluster_version}/amazon-linux-2023/x86_64/nvidia/recommended/release_version"
# }

# # General-purpose EKS-optimized AMI
# data "aws_ssm_parameter" "eks_ami_amazon_linux_2023" {
#   name = "/aws/service/eks/optimized-ami/${var.cluster_config.cluster_version}/amazon-linux-2023/arm64/standard/recommended/release_version"
# }

# data "aws_vpc" "this" {
#   id = data.terraform_remote_state.vpc.outputs.vpc_id
# }

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
