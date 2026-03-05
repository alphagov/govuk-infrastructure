data "aws_iam_policy_document" "irsa_to_db" {
  for_each = var.neptune_dbs

  statement {
    sid = "AllowDataAccessForNeptune"

    effect = "Allow"

    actions = [
      "neptune-db:*"
    ]
    resources = [
      aws_neptune_cluster.this[each.key].arn,
      "arn:aws:neptune-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_neptune_cluster.this[each.key].cluster_resource_id}/*"
    ]
  }
}

resource "aws_iam_policy" "neptune" {
  for_each = var.neptune_dbs

  name        = "govuk-${var.govuk_environment}-neptune-${each.value.name}"
  description = "Allow data access to relevant neptune db"
  policy      = data.aws_iam_policy_document.irsa_to_db[each.key].json
}

