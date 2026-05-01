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
