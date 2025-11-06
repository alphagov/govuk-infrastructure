resource "aws_iam_role" "manual_snapshot_role" {
  name               = "${var.stackname}-elasticsearch6-manual-snapshot-role"
  assume_role_policy = data.aws_iam_policy_document.es_can_assume_role.json
}

data "aws_iam_policy_document" "es_can_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "manual_snapshot_bucket_policy" {
  name   = "govuk-${var.govuk_environment}-${var.stackname}-elasticsearch6-manual-snapshot-bucket-policy"
  policy = data.aws_iam_policy_document.manual_snapshot_bucket_policy.json
}

data "aws_iam_policy_document" "manual_snapshot_bucket_policy" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = var.elasticsearch6_manual_snapshot_bucket_arns
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = formatlist("%s/*", var.elasticsearch6_manual_snapshot_bucket_arns)
  }
}

resource "aws_iam_role_policy_attachment" "manual_snapshot_role_policy" {
  role       = aws_iam_role.manual_snapshot_role.name
  policy_arn = aws_iam_policy.manual_snapshot_bucket_policy.arn

}

resource "aws_iam_policy" "can_configure_es_snapshots" {
  name        = "govuk-${var.govuk_environment}-${var.stackname}-elasticsearch6-manual-snapshot-domain-configuration-policy"
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
    resources = [aws_iam_role.manual_snapshot_role.arn]
  }
  statement {
    actions   = ["es:ESHttpPut"]
    resources = ["${aws_elasticsearch_domain.opensearch.arn}/*"]
  }
}
