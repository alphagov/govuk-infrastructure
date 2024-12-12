locals {
  efs_csi_driver_controller_service_account_name = "efs-csi-controller-sa"
}

module "aws_efs_csi_driver_iam_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 5.0"
  create_role                   = true
  role_name                     = "${local.efs_csi_driver_controller_service_account_name}-${var.cluster_name}"
  role_description              = "Role for the AWS EFS CSI driver controller. Corresponds to ${local.efs_csi_driver_controller_service_account_name} k8s ServiceAccount."
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [aws_iam_policy.aws_efs_csi_driver.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:${local.efs_csi_driver_controller_service_account_name}"]
}

data "aws_iam_policy_document" "aws_efs_csi_driver" {
  statement {
    effect = "Allow"

    actions = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets",
      "ec2:DescribeAvailabilityZones"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "elasticfilesystem:CreateAccessPoint"
    ]

    resources = [
      "arn:aws:ec2:*:*:volume/*",
      "arn:aws:ec2:*:*:snapshot/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["CreateVolume", "CreateSnapshot"]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:DeleteTags"
    ]

    resources = [
      "arn:aws:ec2:*:*:volume/*",
      "arn:aws:ec2:*:*:snapshot/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateVolume"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/ebs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateVolume"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/CSIVolumeName"
      values   = ["*"]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateVolume"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/kubernetes.io/cluster/*"
      values   = ["owned"]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:DeleteVolume"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/ebs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:DeleteVolume"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/CSIVolumeName"
      values   = ["*"]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:DeleteVolume"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/kubernetes.io/cluster/*"
      values   = ["owned"]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:DeleteSnapshot"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/CSIVolumeSnapshotName"
      values   = ["*"]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "elasticfilesystem:CreateAccessPoint"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "elasticfilesystem:TagResource"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "elasticfilesystem:DeleteAccessPoint"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
}

resource "aws_iam_policy" "aws_efs_csi_driver" {
  name        = "AWSEfsCsiController-${var.cluster_name}"
  description = "Allow the driver to manage AWS EFS"

  # Verbatim contents of
  # https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/refs/heads/master/docs/iam-policy-example.json
  # (except for whitespace changes from terraform fmt).
  policy = data.aws_iam_policy_document.aws_efs_csi_driver.json
}
