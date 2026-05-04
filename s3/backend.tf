terraform {
  backend "s3" {
    bucket       = "epam-terrform-state-bucket"
    key          = "895587011312_AdministratorAccess/eks/eks-academy/s3/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
    profile      = "895587011312_AdministratorAccess"
  }
}
