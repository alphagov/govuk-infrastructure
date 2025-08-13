locals {
  # only prooduction assumer role can assume production
  # other accounts can assume into non-prod accounts
  _prod_account_id = ["172025368201"]
  _non_prod_account_ids = [
    "696911096973", # staging
    "210287912431"  # integration
  ]
  assumer_account_ids = (var.govuk_environment == "production" ?
  local._prod_account_id : concat(local._non_prod_account_ids, local._prod_account_id))

  assumed_identifiers = [
    for id in local.assumer_account_ids : "arn:aws:iam::${id}:role/release-assumer"
  ]
}

data "aws_iam_policy_document" "release_assumed_assume" {
  dynamic "statement" {
    for_each = toset(local.assumed_identifiers)
    content {
      actions = ["sts:AssumeRole"]
      effect  = "Allow"
      principals {
        type        = "AWS"
        identifiers = [statement.key]
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
