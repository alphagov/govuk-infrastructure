locals {
  timelock_enabled = var.govuk_environment == "production"
  timelock_days    = 120
}

data "aws_iam_policy_document" "db_backup_bucket_policy" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        "210287912431", # integration
        "696911096973", # staging
        "172025368201", # production
      ]
    }
    actions = ["s3:Get*", "s3:List*"]
    resources = [
      "arn:aws:s3:::govuk-${var.govuk_environment}-database-backups",
      "arn:aws:s3:::govuk-${var.govuk_environment}-database-backups/*"
    ]
  }
}

module "secure_s3_bucket_db_backup_main" {
  source = "../../shared-modules/s3"

  govuk_environment = var.govuk_environment
  name              = "govuk-${var.govuk_environment}-database-backups"

  extra_bucket_policies = [data.aws_iam_policy_document.db_backup_bucket_policy.json]

  lifecycle_rules = [
    {
      id     = "production"
      status = var.govuk_environment == "production" ? "Enabled" : "Disabled"
      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "GLACIER"
        }
      ]
      expiration                    = { days = 120 }
      noncurrent_version_expiration = { noncurrent_days = 1 }
    },
    {
      id                            = "non-production"
      status                        = var.govuk_environment != "production" ? "Enabled" : "Disabled"
      expiration                    = { days = 8 }
      noncurrent_version_expiration = { noncurrent_days = 1 }
    }
  ]

  object_lock_config = var.govuk_environment == "production" ? [
    {
      rule = {
        default_retention = {
          mode = "COMPLIANCE"
          days = local.timelock_days
        }
      }
    }
  ] : []
}

module "secure_s3_bucket_db_backup_replica" {
  source = "../../shared-modules/s3"
  providers = {
    aws = aws.replica
  }

  govuk_environment = var.govuk_environment
  name              = "govuk-${var.govuk_environment}-database-backups-replica"

  access_logging_config = {
    target_bucket = "govuk-${var.govuk_environment}-aws-secondary-logging"
  }

  lifecycle_rules = [
    {
      id     = "production"
      status = var.govuk_environment == "production" ? "Enabled" : "Disabled"
      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "GLACIER"
        }
      ]
      expiration                    = { days = 120 }
      noncurrent_version_expiration = { noncurrent_days = 1 }
    },
    {
      id                            = "non-production"
      status                        = var.govuk_environment != "production" ? "Enabled" : "Disabled"
      expiration                    = { days = 2 }
      noncurrent_version_expiration = { noncurrent_days = 1 }
    }
  ]

  object_lock_config = var.govuk_environment == "production" ? [
    {
      rule = {
        default_retention = {
          mode = "COMPLIANCE"
          days = local.timelock_days
        }
      }
    }
  ] : []
}

resource "aws_s3_bucket_replication_configuration" "backup_main" {
  depends_on = [module.secure_s3_bucket_db_backup_main] # TF doesn't infer this :(

  bucket = module.secure_s3_bucket_db_backup_main.name
  role   = aws_iam_role.backup_replication.arn

  rule {
    id       = "replicate-db-backups-out-of-region"
    priority = 10
    status   = var.govuk_environment == "production" ? "Enabled" : "Disabled"
    delete_marker_replication { status = "Disabled" }
    destination {
      bucket        = module.secure_s3_bucket_db_backup_replica.arn
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
    resources = [module.secure_s3_bucket_db_backup_main.arn, "${module.secure_s3_bucket_db_backup_main.arn}/*"]
  }
  statement {
    sid       = "ReplicateToDestinationBuckets"
    actions   = ["s3:ObjectOwnerOverrideToBucketOwner", "s3:Replicate*"]
    resources = ["${module.secure_s3_bucket_db_backup_replica.arn}/*"]
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
