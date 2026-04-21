resource "aws_iam_role" "eks_node_role" {
  for_each = var.node_group_iam_configs
  name     = each.value.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# --- Mandatory Policies (Attached to EVERY role in the map) ---
resource "aws_iam_role_policy_attachment" "worker_node" {
  for_each   = var.node_group_iam_configs
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role[each.key].name
}

resource "aws_iam_role_policy_attachment" "cni" {
  for_each   = var.node_group_iam_configs
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role[each.key].name
}

# --- Conditional Policies (Using the map's boolean toggles) ---
resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  for_each   = { for k, v in var.node_group_iam_configs : k => v if v.enable_ecr_ro_access }
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role[each.key].name
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  for_each   = { for k, v in var.node_group_iam_configs : k => v if v.enable_ssm }
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_node_role[each.key].name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  for_each   = { for k, v in var.node_group_iam_configs : k => v if v.enable_cloudwatch_logs }
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.eks_node_role[each.key].name
}
