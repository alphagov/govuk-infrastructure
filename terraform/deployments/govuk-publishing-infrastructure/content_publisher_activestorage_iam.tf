# Replication IAM role/policy

data "aws_iam_policy_document" "content_publisher_activestorage_replication_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "content_publisher_activestorage_replication_role" {
  name               = "govuk-content-publisher-activestorage-replication-role"
  assume_role_policy = data.aws_iam_policy_document.content_publisher_activestorage_replication_role.json
}

data "aws_iam_policy_document" "content_publisher_activestorage_replication_policy" {
  statement {
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.content_publisher_activestorage.arn]
    effect    = "Allow"
  }
  statement {
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging"
    ]
    resources = ["${aws_s3_bucket.content_publisher_activestorage.arn}/*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete"
    ]
    resources = ["${aws_s3_bucket.content_publisher_activestorage_replica.arn}/*"]
  }
}

resource "aws_iam_policy" "content_publisher_activestorage_replication_policy" {
  name        = "govuk-${var.govuk_environment}-content-publisher-activestorage-replication-policy"
  policy      = data.aws_iam_policy_document.content_publisher_activestorage_replication_policy.json
  description = "Allows replication of the content publisher activestorage bucket"
}

resource "aws_iam_role_policy_attachment" "content_publisher_activestorage_replication_policy" {
  role       = aws_iam_role.content_publisher_activestorage_replication_role.name
  policy_arn = aws_iam_policy.content_publisher_activestorage_replication_policy.arn
}

# Imports (temporary)

import {
  to = aws_iam_role.content_publisher_activestorage_replication_role
  id = "govuk-content-publisher-activestorage-replication-role"
}

import {
  to = aws_iam_policy.content_publisher_activestorage_replication_policy
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/govuk-${var.govuk_environment}-content-publisher-activestorage-replication-policy"
}

import {
  to = aws_iam_role_policy_attachment.content_publisher_activestorage_replication_policy
  id = "govuk-content-publisher-activestorage-replication-role/arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/govuk-${var.govuk_environment}-content-publisher-activestorage-replication-policy"
}

# App access role/policy

data "aws_iam_policy_document" "content_publisher_s3" {
  statement {
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources = [aws_s3_bucket.content_publisher_activestorage.arn]
  }

  statement {
    actions = [
      "s3:*MultipartUpload*",
      "s3:*Object",
      "s3:*ObjectAcl",
      "s3:*ObjectVersion",
      "s3:GetObject*Attributes"
    ]
    resources = ["${aws_s3_bucket.content_publisher_activestorage.arn}/*"]
  }
}

resource "aws_iam_policy" "content_publisher_s3" {
  name        = "content_publisher_s3"
  description = "Read and write to this environment's content-publisher-activestorage bucket."

  policy = data.aws_iam_policy_document.content_publisher_s3.json
}

# TODO: consider IRSA (pod identity) rather than granting to nodes.
resource "aws_iam_role_policy_attachment" "content_publisher_s3" {
  role       = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_name
  policy_arn = aws_iam_policy.content_publisher_s3.arn
}
