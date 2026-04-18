# ------ CoreDNS Addon ------
resource "aws_eks_addon" "core_dns" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "coredns"
  addon_version               = data.aws_eks_addon_version.latest_coredns.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  preserve                    = true

  configuration_values = jsonencode({
    replicaCount = 3
    resources = {
      limits   = { cpu = "100m", memory = "150Mi" }
      requests = { cpu = "100m", memory = "150Mi" }
    }

    affinity = {
      nodeAffinity = {
        preferredDuringSchedulingIgnoredDuringExecution = [{
          weight = 100
          preference = {
            matchExpressions = [{
              key      = "eks.amazonaws.com/capacityType"
              operator = "In"
              values   = ["ON_DEMAND"]
            }]
          }
        }]
      }

      podAntiAffinity = {
        preferredDuringSchedulingIgnoredDuringExecution = [
          {
            weight = 100
            podAffinityTerm = {
              labelSelector = {
                matchExpressions = [{
                  key      = "k8s-app"
                  operator = "In"
                  values   = ["coredns"]
                }]
              }
              topologyKey = "kubernetes.io/hostname"
            }
          },
          {
            weight = 100
            podAffinityTerm = {
              labelSelector = {
                matchExpressions = [{
                  key      = "k8s-app"
                  operator = "In"
                  values   = ["coredns"]
                }]
              }
              topologyKey = "topology.kubernetes.io/zone"
            }
          }
        ]
      }
    }
  })
}
