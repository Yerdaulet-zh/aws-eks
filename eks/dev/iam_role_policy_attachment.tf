# ---------- Nginx Gateway Fabric ----------
resource "aws_iam_role_policy_attachment" "lbc_attach" {
  policy_arn = aws_iam_policy.lbc_policy.arn
  role       = aws_iam_role.lbc_pod_identity_role.name
}
