resource "aws_iam_role" "external-dns" {
  name = "${local.name}-pod-role-for-external-dns"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Principal" : {
          "Federated" : "arn:aws:iam::512646826903:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/${local.cluster_issuer_id}"
        },
        "Condition" : {
          "StringEquals" : {
            "oidc.eks.us-east-1.amazonaws.com/id/${local.cluster_issuer_id}:aud" : "sts.amazonaws.com"
            "oidc.eks.us-east-1.amazonaws.com/id/${local.cluster_issuer_id}:sub" : "system:serviceaccount:default:external-dns"

          }
        }
      }
    ]
  })

  inline_policy {
    name = "parameter-store"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "Route53Access",
          "Effect" : "Allow",
          "Action" : [
            "route53:*"
          ],
          "Resource" : "*"
        }
      ]
    })
  }
}


resource "aws_iam_role" "cluster-autoscaler" {
  name = "${local.name}-pod-role-for-cluster-autoscaler"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Principal" : {
          "Federated" : "arn:aws:iam::512646826903:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/${local.cluster_issuer_id}"
        },
        "Condition" : {
          "StringEquals" : {
            "oidc.eks.us-east-1.amazonaws.com/id/${local.cluster_issuer_id}:aud" : "sts.amazonaws.com"
            "oidc.eks.us-east-1.amazonaws.com/id/${local.cluster_issuer_id}:sub" : "system:serviceaccount:default:node-autoscaler-aws-cluster-autoscaler"

          }
        }
      }
    ]
  })

  inline_policy {
    name = "parameter-store"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "ClusterAutoscaler",
          "Effect" : "Allow",
          "Action" : [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeScalingActivities",
            "autoscaling:SetDesiredCapacity",
            "autoscaling:TerminateInstanceInAutoScalingGroup",
            "eks:DescribeNodegroup",
            "ec2:DescribeLaunchTemplateVersions"
          ],
          "Resource" : "*"
        }
      ]
    })
  }
}


variable "components" {
  default    = [ "frontend", "cart", "catalogue", "shipping", "user", "payment" ]
}


resource "aws_iam_role" "app-ssm-parameters" {
  count  = length(var.components)
  name = "${local.name}-pod-role-for-${var.components[count.index]}-ssm-parameters"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Principal" : {
          "Federated" : "arn:aws:iam::512646826903:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/${local.cluster_issuer_id}"
        },
        "Condition" : {
          "StringEquals" : {
            "oidc.eks.us-east-1.amazonaws.com/id/${local.cluster_issuer_id}:aud" : "sts.amazonaws.com"
            "oidc.eks.us-east-1.amazonaws.com/id/${local.cluster_issuer_id}:sub" : "system:serviceaccount:default:${var.components[count.index]}"

          }
        }
      }
    ]
  })

  inline_policy {
    name = "${var.components[count.index]}-parameter-store"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "APPSSM",
          "Effect" : "Allow",
          "Action" : [
            "ssm:DescribeParameters",
            "ssm:GetParameterHistory",
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:GetParameter",
            "kms:Decrypt"
          ],
          "Resource" : "*"
        }
      ]
    })
  }
}
