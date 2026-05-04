# ---------- Nginx Gateway Fabric ----------
resource "aws_iam_role" "lbc_pod_identity_role" {
  name               = "${local.cluster_name}-lbc-role"
  assume_role_policy = file("iam_policies/pod-identity-policy.json")
}

# ---------- Route53 Cert Manager ----------
resource "aws_iam_role" "cert_manager_route53" {
  name               = "${local.cluster_name}-cert_manager_route53"
  assume_role_policy = file("iam_policies/pod-identity-policy.json")
}

# ---------- Loki S3 Storage ----------
resource "aws_iam_role" "loki_s3_storage" {
  name               = "${local.cluster_name}-loki-s3-storage"
  assume_role_policy = file("iam_policies/pod-identity-policy.json")
}
