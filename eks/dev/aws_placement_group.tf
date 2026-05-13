resource "aws_placement_group" "eks_nodes" {
  name     = "eks-placement-group"
  strategy = "cluster"

  depends_on = [module.eks_dev]
}
