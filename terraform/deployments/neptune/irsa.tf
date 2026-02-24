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


module "iam_assumable_role" {
  for_each = var.neptune_dbs

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.0"

  name                 = "${var.govuk_environment}-${each.value.name}-neptune-irsa"
  use_name_prefix      = false
  description          = "Role for neptune irsa. Corresponds to ${each.value.name} k8s ServiceAccount."
  max_session_duration = 28800
  policies = {
    neptune = aws_iam_policy.neptune[each.key].arn
  }

  oidc_providers = {
    main = {
      provider_arn               = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn
      namespace_service_accounts = ["${local.apps_namespace}:${each.value.name}-neptune-db"]
    }
  }
}

