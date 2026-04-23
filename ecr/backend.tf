terraform {
  backend "s3" {
    bucket       = "epam-terrform-state-bucket"
    key          = "895587011312_AdministratorAccess/ecr/python-backend/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
    profile      = "895587011312_AdministratorAccess"
  }
}
