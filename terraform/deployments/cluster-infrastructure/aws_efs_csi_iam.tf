locals {
  efs_csi_driver_controller_service_account_name = "efs-csi-controller-sa"
}

module "aws_efs_csi_driver_iam_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 4.0"
  create_role                   = true
  role_name                     = "${local.efs_csi_driver_controller_service_account_name}-${var.cluster_name}"
  role_description              = "Role for the AWS EFS CSI driver controller. Corresponds to ${local.efs_csi_driver_controller_service_account_name} k8s ServiceAccount."
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [aws_iam_policy.aws_efs_csi_driver.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:${local.efs_csi_driver_controller_service_account_name}"]
}

resource "aws_iam_role_policy_attachment" "eks_nodes_efs" {
  role       = module.eks.eks_managed_node_groups["main"].iam_role_name
  policy_arn = aws_iam_policy.aws_efs_csi_driver.arn
}

resource "aws_iam_policy" "aws_efs_csi_driver" {
  name        = "AWSEfsCsiController-${var.cluster_name}"
  description = "Allow the driver to manage AWS EFS"

  # The argument to jsonencode() is the verbatim contents of
  # https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/master/docs/iam-policy-example.json
  # (except for whitespace changes from terraform fmt).
  policy = jsonencode({

    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticfilesystem:DescribeAccessPoints",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeMountTargets",
          "ec2:DescribeAvailabilityZones"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticfilesystem:CreateAccessPoint"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringLike" : {
            "aws:RequestTag/efs.csi.aws.com/cluster" : "true"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : "elasticfilesystem:DeleteAccessPoint",
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/efs.csi.aws.com/cluster" : "true"
          }
        }
      }
    ]
  })
}
