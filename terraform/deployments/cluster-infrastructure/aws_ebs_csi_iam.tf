locals {
  ebs_csi_driver_controller_service_account_name = "ebs-csi-controller-sa"
}

module "aws_ebs_csi_driver_iam_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 5.0"
  create_role                   = true
  role_name                     = "${local.ebs_csi_driver_controller_service_account_name}-${var.cluster_name}"
  role_description              = "Role for the AWS EBS CSI driver controller. Corresponds to ${local.ebs_csi_driver_controller_service_account_name} k8s ServiceAccount."
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [aws_iam_policy.aws_ebs_csi_driver.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:${local.ebs_csi_driver_controller_service_account_name}"]
}

data "aws_iam_policy_document" "aws_ebs_csi_driver" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateSnapshot",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumesModifications"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateTags"
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
      "ec2:DeleteSnapshot"
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
}

resource "aws_iam_policy" "aws_ebs_csi_driver" {
  name        = "AWSEbsCsiController-${var.cluster_name}"
  description = "Allow the driver to manage AWS EBS"

  # Verbatim contents of
  # https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/docs/example-iam-policy.json
  # (except for whitespace changes from terraform fmt).
  policy = data.aws_iam_policy_document.aws_ebs_csi_driver.json
}
