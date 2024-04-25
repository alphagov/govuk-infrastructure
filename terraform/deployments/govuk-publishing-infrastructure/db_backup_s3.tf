locals {
  timelock_enabled = var.govuk_environment == "production"
  timelock_days    = 120
}

resource "aws_s3_bucket" "backup_main" {
  bucket              = "govuk-${var.govuk_environment}-database-backups"
  object_lock_enabled = local.timelock_enabled
  tags                = { Name = "govuk-${var.govuk_environment}-database-backups" }
}

resource "aws_s3_bucket" "backup_replica" {
  bucket              = "govuk-${var.govuk_environment}-database-backups-replica"
  provider            = aws.replica
  object_lock_enabled = local.timelock_enabled
  tags                = { Name = "govuk-${var.govuk_environment}-database-backups-replica" }
}

resource "aws_s3_bucket_object_lock_configuration" "backup_main" {
  count = local.timelock_enabled ? 1 : 0

  bucket = aws_s3_bucket.backup_main.id
  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = local.timelock_days
    }
  }
}

resource "aws_s3_bucket_object_lock_configuration" "backup_replica" {
  count = local.timelock_enabled ? 1 : 0

  bucket   = aws_s3_bucket.backup_replica.id
  provider = aws.replica
  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = local.timelock_days
    }
  }
}

resource "aws_s3_bucket_public_access_block" "backup_main" {
  bucket                  = aws_s3_bucket.backup_main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "backup_replica" {
  bucket                  = aws_s3_bucket.backup_replica.id
  provider                = aws.replica
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "backup_main" {
  bucket        = aws_s3_bucket.backup_main.id
  target_bucket = "govuk-${var.govuk_environment}-aws-logging"
  target_prefix = "s3/govuk-${var.govuk_environment}-database-backups/"
}

resource "aws_s3_bucket_logging" "backup_replica" {
  bucket        = aws_s3_bucket.backup_replica.id
  provider      = aws.replica
  target_bucket = "govuk-${var.govuk_environment}-aws-secondary-logging"
  target_prefix = "s3/govuk-${var.govuk_environment}-database-backups-replica/"
}

resource "aws_s3_bucket_versioning" "backup_main" {
  bucket = aws_s3_bucket.backup_main.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_versioning" "backup_replica" {
  bucket   = aws_s3_bucket.backup_replica.id
  provider = aws.replica
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_lifecycle_configuration" "backup_main" {
  bucket = aws_s3_bucket.backup_main.id
  rule {
    id     = "production"
    status = var.govuk_environment == "production" ? "Enabled" : "Disabled"
    filter {}
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 60
      storage_class = "GLACIER"
    }
    expiration { days = 120 }
    noncurrent_version_expiration { noncurrent_days = 1 }
  }
  rule {
    id     = "non-production"
    status = var.govuk_environment != "production" ? "Enabled" : "Disabled"
    filter {}
    expiration { days = 2 }
    noncurrent_version_expiration { noncurrent_days = 1 }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backup_replica" {
  bucket   = aws_s3_bucket.backup_replica.id
  provider = aws.replica
  rule {
    id     = "production"
    status = var.govuk_environment == "production" ? "Enabled" : "Disabled"
    filter {}
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 60
      storage_class = "GLACIER"
    }
    expiration { days = 120 }
    noncurrent_version_expiration { noncurrent_days = 1 }
  }
  rule {
    id     = "non-production"
    status = var.govuk_environment != "production" ? "Enabled" : "Disabled"
    filter {}
    expiration { days = 2 }
    noncurrent_version_expiration { noncurrent_days = 1 }
  }
}

resource "aws_s3_bucket_replication_configuration" "backup_main" {
  depends_on = [aws_s3_bucket_versioning.backup_main] # TF doesn't infer this :(

  bucket = aws_s3_bucket.backup_main.id
  role   = aws_iam_role.backup_replication.arn

  rule {
    id       = "replicate-db-backups-out-of-region"
    priority = 10
    status   = var.govuk_environment == "production" ? "Enabled" : "Disabled"
    delete_marker_replication { status = "Disabled" }
    destination {
      bucket        = aws_s3_bucket.backup_replica.arn
      storage_class = "STANDARD_IA"
    }
    filter {}
  }
}

data "aws_iam_policy_document" "backup_s3_can_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backup_replication" {
  name               = "database-backups-s3-replication"
  assume_role_policy = data.aws_iam_policy_document.backup_s3_can_assume_role.json
}

data "aws_iam_policy_document" "backup_replication" {
  statement {
    sid = "ReplicateFromSourceBucket"
    actions = [
      "s3:ListBucket",
      "s3:GetObject*",
      "s3:GetReplicationConfiguration",
    ]
    resources = [aws_s3_bucket.backup_main.arn, "${aws_s3_bucket.backup_main.arn}/*"]
  }
  statement {
    sid       = "ReplicateToDestinationBuckets"
    actions   = ["s3:ObjectOwnerOverrideToBucketOwner", "s3:Replicate*"]
    resources = ["${aws_s3_bucket.backup_replica.arn}/*"]
  }
}

resource "aws_iam_policy" "backup_replication" {
  name        = "db-backup-s3-replication"
  policy      = data.aws_iam_policy_document.backup_replication.json
  description = "Allow S3 to replicate the database backup bucket out-of-region."
}

resource "aws_iam_role_policy_attachment" "backup_replication" {
  role       = aws_iam_role.backup_replication.name
  policy_arn = aws_iam_policy.backup_replication.arn
}
