locals {
  # only production assumer role can assume production and non-prod accounts
  # non-prod accounts can only assume their own account
  assumed_identifiers = distinct([
    "arn:aws:iam::172025368201:role/synthetic-test-assumer",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/synthetic-test-assumer"
  ])
}

data "aws_iam_policy_document" "synthetic_test_assumed_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = local.assumed_identifiers
    }
  }
}

resource "aws_iam_role" "synthetic_test_assumed" {
  name               = "synthetic-test-assumed"
  assume_role_policy = data.aws_iam_policy_document.synthetic_test_assumed_assume.json
}

data "aws_iam_policy_document" "synthetic_test_assumed" {
  statement {
    actions = [
      "eks:DescribeCluster",
      "eks:AccessKubernetesApi"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "synthetic_test_assumed" {
  name        = "synthetic-test-assumed"
  description = "Allows Synthetic Test to access the K8S API"
  policy      = data.aws_iam_policy_document.synthetic_test_assumed.json
}

resource "aws_iam_role_policy_attachment" "synthetic_test_assumed" {
  role       = aws_iam_role.synthetic_test_assumed.name
  policy_arn = aws_iam_policy.synthetic_test_assumed.arn
}

resource "aws_eks_access_entry" "synthetic_test_assumed" {
  cluster_name      = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id
  principal_arn     = aws_iam_role.synthetic_test_assumed.arn
  kubernetes_groups = ["synthetic-test-assumed"]
}
