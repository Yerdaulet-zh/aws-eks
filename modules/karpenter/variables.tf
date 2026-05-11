variable "cluster_name" {
  type = string
}

variable "namespace" {
  type    = string
  default = "kube-system"
}

variable "service_account_name" {
  type    = string
  default = "karpenter"
}

variable "enable_interruption_handling" {
  type    = bool
  default = false
}

variable "enable_ecr_ro" {
  type    = bool
  default = true
}

variable "enable_node_ssm" {
  type    = bool
  default = false
}

variable "enable_cloudwatch_logs" {
  type    = bool
  default = true
}
