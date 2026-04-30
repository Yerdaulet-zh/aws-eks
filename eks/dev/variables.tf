variable "sso_admin_iam_name" {
  type      = string
  sensitive = true
}

variable "vpc_id" {
  type = string
}

variable "load_balancer_name" {
  type = string
}
