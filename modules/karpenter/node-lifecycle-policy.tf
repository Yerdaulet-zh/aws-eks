
resource "aws_iam_policy" "node_lifecycle" {
  name = "KarpenterControllerNodeLifecyclePolicy-${var.cluster_name}"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        "Sid" : "AllowScopedEC2InstanceAccessActions",
        "Effect" : "Allow",
        "Resource" : [
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}::image/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}::snapshot/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:security-group/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:subnet/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:capacity-reservation/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:placement-group/*"
        ],
        "Action" : [
          "ec2:RunInstances",
          "ec2:CreateFleet"
        ]
      },

      {
        "Sid" : "AllowScopedEC2LaunchTemplateAccessActions",
        "Effect" : "Allow",
        "Resource" : "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:launch-template/*",
        "Action" : [
          "ec2:RunInstances",
          "ec2:CreateFleet"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}" : "owned"
          },
          "StringLike" : {
            "aws:ResourceTag/karpenter.sh/nodepool" : "*"
          }
        }
      },

      {
        "Sid" : "AllowScopedEC2InstanceActionsWithTags",
        "Effect" : "Allow",
        "Resource" : [
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:fleet/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:instance/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:volume/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:network-interface/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:launch-template/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:spot-instances-request/*"
        ],
        "Action" : [
          "ec2:RunInstances",
          "ec2:CreateFleet",
          "ec2:CreateLaunchTemplate"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}" : "owned",
            "aws:RequestTag/eks:eks-cluster-name" : "${var.cluster_name}"
          },
          "StringLike" : {
            "aws:RequestTag/karpenter.sh/nodepool" : "*"
          }
        }
      },
      {
        "Sid" : "AllowScopedResourceCreationTagging",
        "Effect" : "Allow",
        "Resource" : [
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:fleet/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:instance/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:volume/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:network-interface/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:launch-template/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:spot-instances-request/*"
        ],
        "Action" : "ec2:CreateTags",
        "Condition" : {
          "StringEquals" : {
            "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}" : "owned",
            "aws:RequestTag/eks:eks-cluster-name" : "${var.cluster_name}",
            "ec2:CreateAction" : [
              "RunInstances",
              "CreateFleet",
              "CreateLaunchTemplate"
            ]
          },
          "StringLike" : {
            "aws:RequestTag/karpenter.sh/nodepool" : "*"
          }
        }
      },
      {
        "Sid" : "AllowScopedResourceTagging",
        "Effect" : "Allow",
        "Resource" : "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:instance/*",
        "Action" : "ec2:CreateTags",
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}" : "owned"
          },
          "StringLike" : {
            "aws:ResourceTag/karpenter.sh/nodepool" : "*"
          },
          "StringEqualsIfExists" : {
            "aws:RequestTag/eks:eks-cluster-name" : "${var.cluster_name}"
          },
          "ForAllValues:StringEquals" : {
            "aws:TagKeys" : [
              "eks:eks-cluster-name",
              "karpenter.sh/nodeclaim",
              "Name"
            ]
          }
        }
      },

      {
        "Sid" : "AllowScopedDeletion",
        "Effect" : "Allow",
        "Resource" : [
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:instance/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:*:launch-template/*"
        ],
        "Action" : [
          "ec2:TerminateInstances",
          "ec2:DeleteLaunchTemplate"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}" : "owned"
          },
          "StringLike" : {
            "aws:ResourceTag/karpenter.sh/nodepool" : "*"
          }
        }
      }
    ]
  })
}
