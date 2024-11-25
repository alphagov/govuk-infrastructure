data "aws_elb_service_account" "main" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "s3_aws_logging" {
  statement {
    actions   = ["s3:PutObject"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::govuk-${var.govuk_environment}-aws-logging/*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
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
    resources = [aws_s3_bucket.aws_logging.arn]
  }
  statement {
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.aws_logging.arn}/*"]
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

# Create a bucket that allows AWS services to write to it
resource "aws_s3_bucket" "aws_logging" {
  bucket = "govuk-${var.govuk_environment}-aws-logging"
}

resource "aws_s3_bucket_policy" "aws_logging" {
  bucket = aws_s3_bucket.aws_logging.id
  policy = data.aws_iam_policy_document.s3_aws_logging.json
}

resource "aws_s3_bucket_acl" "aws_logging" {
  bucket = aws_s3_bucket.aws_logging.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_lifecycle_configuration" "aws_logging" {
  bucket = aws_s3_bucket.aws_logging.id

  rule {
    id     = "ExpireRule"
    status = "Enabled"

    expiration {
      days = 30
    }
    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
}

resource "aws_s3_bucket_versioning" "aws_logging" {
  bucket = aws_s3_bucket.aws_logging.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_replication_configuration" "aws_logging" {
  bucket = aws_s3_bucket.aws_logging.id
  role   = aws_iam_role.govuk_aws_logging_replication_role.arn

  rule {
    id     = "govuk-aws-logging-elb-govuk-public-ckan-rule"
    status = var.govuk_environment == "production" ? "Enabled" : "Disabled"
    destination {
      bucket        = "arn:aws:s3:::${var.cyber_slunk_s3_bucket_name}"
      storage_class = "STANDARD"
      account       = var.cyber_slunk_aws_account_id

      access_control_translation {
        owner = "Destination"
      }
    }
    filter {
      prefix = "elb/govuk-ckan-public-elb"
    }
    delete_marker_replication {
      status = "Enabled"
    }
  }
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
