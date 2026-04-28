# ---------- Nginx Gateway Fabric ----------
resource "aws_iam_policy" "lbc_policy" {
  name        = "${local.cluster_name}-lbc-policy"
  description = "Permissions for AWS Load Balancer Controller"
  policy      = file("iam_policies/aws-load-balancer-controller.json")
}
