# variable "sso_admin_iam_name" {
#   type      = string
#   sensitive = true
# }

variable "vpc_id" {
  type = string
}

variable "load_balancer_name" {
  type = string
}

variable "idenitiy_user_role_arns" {
  type = object({
    clusterAdmin = string
    devops       = string
    dev          = string
    audit        = string
  })
}
