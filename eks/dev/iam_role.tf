# ---------- Nginx Gateway Fabric ----------
resource "aws_iam_role" "lbc_pod_identity_role" {
  name = "${local.cluster_name}-lbc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

# ---------- Route53 Cert Manager ----------
resource "aws_iam_role" "cert_manager_route53" {
  name = "${local.cluster_name}-cert_manager_route53"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}
