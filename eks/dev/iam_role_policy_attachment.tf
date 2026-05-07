# ---------- Nginx Gateway Fabric ----------
resource "aws_iam_role_policy_attachment" "lbc_attach" {
  policy_arn = aws_iam_policy.lbc_policy.arn
  role       = aws_iam_role.lbc_pod_identity_role.name
}

# ---------- Route53 Cert Manager ----------
resource "aws_iam_role_policy_attachment" "aws_cert_manager" {
  policy_arn = aws_iam_policy.cert_manager_route53.arn
  role       = aws_iam_role.cert_manager_route53.name
}

# ---------- Loki S3 Storage ----------
resource "aws_iam_role_policy_attachment" "loki_s3_storage_attach" {
  policy_arn = aws_iam_policy.loki_s3_policy.arn
  role       = aws_iam_role.loki_s3_storage.name
}

# ---------- Tempo S3 Storage ----------
resource "aws_iam_role_policy_attachment" "tempo_s3_storage_attach" {
  policy_arn = aws_iam_policy.tempo_s3_policy.arn
  role       = aws_iam_role.tempo_s3_storage.name
}
