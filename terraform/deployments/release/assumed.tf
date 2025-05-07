locals {
  # roles in production and current account can assume this role
  assumed_identifiers = distinct([
    "arn:aws:iam::172025368201:role/release-assumer",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/release-assumer"
  ])
}

data "aws_iam_policy_document" "release_assumed_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    dynamic "principals" {
      for_each = toset(local.assumed_identifiers)
      content {
        type        = "AWS"
        identifiers = principals.key
      }
    }
  }
}

resource "aws_iam_role" "release_assumed" {
  name               = "release-assumed"
  assume_role_policy = data.aws_iam_policy_document.release_assumed_assume.json
}

data "aws_iam_policy_document" "release_assumed" {
  statement {
    actions = [
      "eks:DescribeCluster",
      "eks:AccessKubernetesApi"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "release_assumed" {
  name        = "release-assumed"
  description = "Allows Release to access the K8S API"
  policy      = data.aws_iam_policy_document.release_assumed.json
}

resource "aws_iam_role_policy_attachment" "release_assumed" {
  role       = aws_iam_role.release_assumed.name
  policy_arn = aws_iam_policy.release_assumed.arn
}

resource "aws_eks_access_entry" "release_assumed" {
  cluster_name      = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id
  principal_arn     = aws_iam_role.release_assumed.arn
  kubernetes_groups = ["release-assumed"]
}
