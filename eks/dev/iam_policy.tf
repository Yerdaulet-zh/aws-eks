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

# ---------- Loki S3 Storage ----------
resource "aws_iam_policy" "loki_s3_policy" {
  name        = "${local.cluster_name}-loki-s3-policy"
  description = "Permissions for Loki to manage S3 storage"
  policy      = file("iam_policies/loki-s3-policy.json")
}

# ---------- Tempo S3 Storage ----------
resource "aws_iam_policy" "tempo_s3_policy" {
  name        = "${local.cluster_name}-tempo-s3-policy"
  description = "Permissions for Tempo to manage S3 storage"
  policy      = file("iam_policies/tempo-s3-policy.json")
}
