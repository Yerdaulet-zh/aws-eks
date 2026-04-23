module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "3.2.0"

  repository_name = "python-repository"

  repository_image_tag_mutability = "IMMUTABLE"

  repository_image_scan_on_push = true
  repository_encryption_type    = "KMS"
  repository_kms_key            = "" # Optional: defaults to AWS managed key

  repository_read_write_access_arns = [data.aws_caller_identity.this.arn]

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

