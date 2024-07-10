resource "aws_iam_role" "external-dns" {
  name = "${local.name}-node-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Principal" : {
          "Federated" : "arn:aws:iam::512646826903:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/FBA241A425D6D800CF4C41C2CA678CFC"
        },
        "Condition" : {
          "StringEquals" : {
            "oidc.eks.us-east-1.amazonaws.com/id/FBA241A425D6D800CF4C41C2CA678CFC:aud" : "sts.amazonaws.com"
            "oidc.eks.us-east-1.amazonaws.com/id/FBA241A425D6D800CF4C41C2CA678CFC:aud" : "system:serviceaccount:default:external-dns"

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