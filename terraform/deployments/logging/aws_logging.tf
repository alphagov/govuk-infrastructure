locals {
  log_bucket_name = "govuk-${var.govuk_environment}-aws-logging"
  log_bucket_arn  = "arn:aws:s3:::${local.log_bucket_name}"
}

data "aws_elb_service_account" "main" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "s3_aws_logging" {
  statement {
    actions   = ["s3:PutObject"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${local.log_bucket_name}/*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
  }

  statement {
    sid = "AccountLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = ["arn:aws:s3:::${local.log_bucket_name}/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

data "aws_iam_policy_document" "s3_govuk_aws_logging_replication_policy" {
  statement {
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
    effect    = "Allow"
    resources = [local.log_bucket_arn]
  }
  statement {
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging"
    ]
    effect    = "Allow"
    resources = ["${local.log_bucket_arn}/*"]
  }
  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:GetObjectVersionTagging",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.cyber_slunk_s3_bucket_name}/*"]
  }
}

data "aws_iam_policy_document" "s3_govuk_aws_logging_replication_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "govuk_aws_logging_replication_policy" {
  name        = "govuk-${var.govuk_environment}-aws-logging-bucket-replication-policy"
  policy      = data.aws_iam_policy_document.s3_govuk_aws_logging_replication_policy.json
  description = "Allows replication of the aws-logging bucket"
}

resource "aws_iam_role" "govuk_aws_logging_replication_role" {
  name               = "govuk-aws-logging-replication-role"
  assume_role_policy = data.aws_iam_policy_document.s3_govuk_aws_logging_replication_role.json
}

resource "aws_iam_role_policy_attachment" "govuk_aws_logging_replication_policy_attachment" {
  role       = aws_iam_role.govuk_aws_logging_replication_role.name
  policy_arn = aws_iam_policy.govuk_aws_logging_replication_policy.arn
}

moved {
  from = aws_s3_bucket.aws_logging
  to   = module.aws_logging_bucket.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_policy.aws_logging
  to   = module.aws_logging_bucket.aws_s3_bucket_policy.bucket_policy
}

# Create a bucket that allows AWS services to write to it
module "aws_logging_bucket" {
  source = "../../shared-modules/s3"

  govuk_environment      = var.govuk_environment
  name                   = local.log_bucket_name
  disable_bucket_logging = true
  extra_bucket_policies = [
    data.aws_iam_policy_document.s3_aws_logging.json
  ]
  force_destroy = false
  lifecycle_rules = [{
    id     = "ExpireRule"
    status = "Enabled"

    expiration = {
      days = 30
    }

    noncurrent_version_expiration = {
      noncurrent_days = 1
    }
  }]

  replication_config = {
    role = aws_iam_role.govuk_aws_logging_replication_role.arn
    rules = [{
      id     = "govuk-aws-logging-elb-govuk-public-ckan-rule"
      status = var.govuk_environment == "production" ? "Enabled" : "Disabled"
      destination = {
        bucket        = "arn:aws:s3:::${var.cyber_slunk_s3_bucket_name}"
        storage_class = "STANDARD"
        account       = var.cyber_slunk_aws_account_id

        access_control_translation = {
          owner = "Destination"
        }
      }
      filter = {
        prefix = "elb/govuk-ckan-public-elb"
      }
      delete_marker_replication = {
        status = "Enabled"
      }
    }]
  }
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.aws_logging
  to   = module.aws_logging_bucket.aws_s3_bucket_lifecycle_configuration.this[0]
}

moved {
  from = aws_s3_bucket_versioning.aws_logging
  to   = module.aws_logging_bucket.aws_s3_bucket_versioning.this
}

moved {
  from = aws_s3_bucket_replication_configuration.aws_logging
  to   = module.aws_logging_bucket.aws_s3_bucket_replication_configuration.this[0]
}
# IAM role and policy for RDS Enhanced Monitoring

data "aws_iam_policy_document" "rds_enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  name               = "rds-monitoring-role"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# IAM role and policy for CloudFront V2 logging
resource "aws_iam_role" "cloudfront_cloudwatch" {
  name               = "${var.govuk_environment}-cloudfront-cloudwatch-role"
  assume_role_policy = data.aws_iam_policy_document.cloudfront_cloudwatch_assume_role.json
}

data "aws_iam_policy_document" "cloudfront_cloudwatch_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "cloudfront_cloudwatch" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:logs:${var.aws_region_global}:${data.aws_caller_identity.current.account_id}:log-group:/aws/cloudfront/*:*",
    ]
  }
}

resource "aws_iam_policy" "cloudfront_cloudwatch" {
  name   = "${var.govuk_environment}-cloudfront-cloudwatch-policy"
  policy = data.aws_iam_policy_document.cloudfront_cloudwatch.json
}

resource "aws_iam_role_policy_attachment" "cloudfront_cloudwatch" {
  role       = aws_iam_role.cloudfront_cloudwatch.name
  policy_arn = aws_iam_policy.cloudfront_cloudwatch.arn
}

