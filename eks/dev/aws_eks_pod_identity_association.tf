# ---------- Nginx Gateway Fabric ----------
resource "aws_eks_pod_identity_association" "lbc" {
  cluster_name    = local.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.lbc_pod_identity_role.arn

  depends_on = [
    module.eks_dev
  ]
}

# ---------- Route53 Cert Manager ----------
resource "aws_eks_pod_identity_association" "cert_manager" {
  cluster_name    = local.cluster_name
  namespace       = "cert-manager"
  service_account = "cert-manager"
  role_arn        = aws_iam_role.cert_manager_route53.arn
  depends_on      = [module.eks_dev]
}

# --------- Loki S3 Storage ----------
resource "aws_eks_pod_identity_association" "loki_s3_storage" {
  cluster_name    = local.cluster_name
  namespace       = "loki"
  service_account = "loki-sa"
  role_arn        = aws_iam_role.loki_s3_storage.arn
  depends_on      = [module.eks_dev]
}
