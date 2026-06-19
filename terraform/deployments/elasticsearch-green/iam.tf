resource "aws_iam_policy" "can_configure_es_snapshots" {
  name        = "govuk-${var.govuk_environment}-green-elasticsearch6-manual-snapshot-domain-configuration-policy"
  description = "Human operator permissions for initial setup of the snapshot bucket for the ES domain. https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-managedomains-snapshots.html#es-managedomains-snapshot-prerequisites"
  policy      = data.aws_iam_policy_document.can_configure_es_snapshots.json

  lifecycle {
    ignore_changes = [
      description # Inexplicably immutable in AWS.
    ]
  }
}

data "aws_iam_policy_document" "can_configure_es_snapshots" {
  statement {
    actions   = ["iam:PassRole"]
    resources = [module.opensearch.opensearch_iam_role_arn]
  }
  statement {
    actions   = ["es:ESHttpPut"]
    resources = formatlist("%/*", sort(distinct([for _, arn in module.opensearch.opensearch_domain_arns : arn])))
  }
}
