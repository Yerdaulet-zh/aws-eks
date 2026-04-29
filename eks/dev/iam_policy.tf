# ---------- Nginx Gateway Fabric ----------
resource "aws_iam_policy" "lbc_policy" {
  name        = "${local.cluster_name}-lbc-policy"
  description = "Permissions for AWS Load Balancer Controller"
  policy      = file("iam_policies/aws-load-balancer-controller.json")
}

# ---------- Route53 Cert Manager ----------
resource "aws_iam_policy" "cert_manager_route53" {
  name        = "${local.cluster_name}-cert_manager_route53"
  description = "Permission for EKS Cert manager to manage Route53 DNS"
  policy      = file("iam_policies/aws-cert-manager-route53.json")
}
