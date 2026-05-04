module "s3_bucket" {
  source   = "terraform-aws-modules/s3-bucket/aws"
  for_each = toset(["yerdaulet-loki-chunks", "yerdaulet-loki-ruler", "yerdaulet-loki-admin"])
  bucket   = each.key
  acl      = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}
