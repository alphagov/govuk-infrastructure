locals {
  provider_arn               = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn
  mirror_bucket_name         = "govuk-${var.govuk_environment}-mirror"
  mirror_replica_bucket_name = "govuk-${var.govuk_environment}-mirror-replica"
}

module "mirror_bucket" {
  # The main mirror bucket lives in the region selected for replicas
  providers = {
    aws = aws.replica
  }

  source            = "../../shared-modules/s3"
  name              = local.mirror_bucket_name
  govuk_environment = var.govuk_environment

  access_logging_config = {
    target_bucket = "govuk-${var.govuk_environment}-aws-secondary-logging"
    target_prefix = "s3/govuk-${var.govuk_environment}-mirror/"
  }

  cors_rules = {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  lifecycle_rules = [{
    id     = "main"
    status = "Enabled"
    noncurrent_version_expiration = {
      noncurrent_days = 5
    }
  }]

  extra_bucket_policies = [
    data.aws_iam_policy_document.s3_mirror_read_policy.json
  ]

  replication_config = {
    role = aws_iam_role.govuk_mirror_replication_role.arn
    rules = [{
      id = "govuk-mirror-replication-whole-bucket-rule"

      status = "Enabled"
      destination = {
        bucket        = module.mirror_replica_bucket.arn
        storage_class = "STANDARD"
      }
    }]
  }
}

moved {
  from = aws_s3_bucket.govuk_mirror
  to   = module.mirror_bucket.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_versioning.govuk_mirror
  to   = module.mirror_bucket.aws_s3_bucket_versioning.this
}

moved {
  from = aws_s3_bucket_logging.govuk_mirror
  to   = module.mirror_bucket.aws_s3_bucket_logging.this
}

moved {
  from = aws_s3_bucket_cors_configuration.govuk_mirror
  to   = module.mirror_bucket.aws_s3_bucket_cors_configuration.this[0]
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.govuk_mirror
  to   = module.mirror_bucket.aws_s3_bucket_lifecycle_configuration.this[0]
}

moved {
  from = aws_s3_bucket_replication_configuration.govuk_mirror
  to   = module.mirror_bucket.aws_s3_bucket_replication_configuration.this[0]
}

moved {
  from = aws_s3_bucket_policy.govuk_mirror_read_policy
  to   = module.mirror_bucket.aws_s3_bucket_policy.bucket_policy
}

module "mirror_replica_bucket" {
  source = "../../shared-modules/s3"

  name              = local.mirror_replica_bucket_name
  govuk_environment = var.govuk_environment

  access_logging_config = {
    target_bucket = "govuk-${var.govuk_environment}-aws-logging"
    target_prefix = "s3/govuk-${var.govuk_environment}-mirror-replica/"
  }

  lifecycle_rules = [{
    id     = "main"
    status = "Enabled"
    noncurrent_version_expiration = {
      noncurrent_days = 5
    }
  }]

  extra_bucket_policies = [
    data.aws_iam_policy_document.s3_mirror_replica_read_policy.json
  ]
}

moved {
  from = aws_s3_bucket.govuk_mirror_replica
  to   = module.mirror_replica_bucket.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_versioning.govuk_mirror_replica
  to   = module.mirror_replica_bucket.aws_s3_bucket_versioning.this
}

moved {
  from = aws_s3_bucket_logging.govuk_mirror_replica
  to   = module.mirror_replica_bucket.aws_s3_bucket_logging.this
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.govuk_mirror_replica
  to   = module.mirror_replica_bucket.aws_s3_bucket_lifecycle_configuration.this
}

moved {
  from = aws_s3_bucket_policy.govuk_mirror_replica_read_policy
  to   = module.mirror_replica_bucket.aws_s3_bucket_policy.bucket_policy
}

data "aws_iam_policy_document" "s3_mirror_read_policy" {
  statement {
    sid     = "S3FastlyReadBucket"
    actions = ["s3:GetObject"]

    resources = [
      "arn:aws:s3:::${local.mirror_bucket_name}",
      "arn:aws:s3:::${local.mirror_bucket_name}/*",
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = data.fastly_ip_ranges.fastly.cidr_blocks
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    sid     = "S3OfficeReadBucket"
    actions = ["s3:GetObject"]

    resources = [
      "arn:aws:s3:::${local.mirror_bucket_name}",
      "arn:aws:s3:::${local.mirror_bucket_name}/*",
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.office_ips
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    sid     = "S3NATInternalReadBucket"
    actions = ["s3:GetObject"]

    resources = [
      "arn:aws:s3:::${local.mirror_bucket_name}",
      "arn:aws:s3:::${local.mirror_bucket_name}/*",
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.public_nat_gateway_ips
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

data "aws_iam_policy_document" "s3_mirror_replica_read_policy" {
  statement {
    sid     = "S3FastlyReadBucket"
    actions = ["s3:GetObject"]

    resources = [
      "arn:aws:s3:::${local.mirror_replica_bucket_name}",
      "arn:aws:s3:::${local.mirror_replica_bucket_name}/*",
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = data.fastly_ip_ranges.fastly.cidr_blocks
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    sid     = "S3OfficeReadBucket"
    actions = ["s3:GetObject"]

    resources = [
      "arn:aws:s3:::${local.mirror_replica_bucket_name}",
      "arn:aws:s3:::${local.mirror_replica_bucket_name}/*",
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.office_ips
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    sid     = "S3NATInternalReadBucket"
    actions = ["s3:GetObject"]

    resources = [
      "arn:aws:s3:::${local.mirror_replica_bucket_name}",
      "arn:aws:s3:::${local.mirror_replica_bucket_name}/*",
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.public_nat_gateway_ips
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [module.mirror_bucket.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${module.mirror_bucket.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${module.mirror_replica_bucket.arn}/*"]
  }
}

resource "aws_iam_role" "govuk_mirror_replication_role" {
  name               = "govuk-mirror-replication-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "govuk_mirror_replication_policy" {
  name        = "govuk-${var.govuk_environment}-mirror-buckets-replication-policy"
  policy      = data.aws_iam_policy_document.replication.json
  description = "Allows replication of the mirror buckets"
}

resource "aws_iam_policy_attachment" "govuk_mirror_replication_policy_attachment" {
  name       = "s3-govuk-mirror-replication-policy-attachment"
  roles      = [aws_iam_role.govuk_mirror_replication_role.name]
  policy_arn = aws_iam_policy.govuk_mirror_replication_policy.arn
}

data "aws_iam_policy_document" "google_replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"

    ]

    resources = [module.mirror_bucket.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = ["${module.mirror_bucket.arn}/*"]
  }
}

data "google_storage_transfer_project_service_account" "default" {
}

data "aws_iam_policy_document" "google_federated" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["accounts.google.com"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "accounts.google.com:sub"

      values = [data.google_storage_transfer_project_service_account.default.subject_id]
    }
  }
}

resource "aws_iam_role" "govuk_mirror_gcp_storage_transfer" {
  name               = "govuk-mirror-gcp-storage-transfer"
  assume_role_policy = data.aws_iam_policy_document.google_federated.json
}

resource "aws_iam_policy" "govuk_mirror_gcp_storage_transfer" {
  name        = "govuk-${var.govuk_environment}-mirror-read-policy"
  policy      = data.aws_iam_policy_document.google_replication.json
  description = "Allow the listing and reading of the primary govuk mirror bucket"
}

resource "aws_iam_policy_attachment" "govuk_mirror_gcp_storage_transfer" {
  name       = "s3-govuk-mirror-replication-policy-attachment"
  roles      = [aws_iam_role.govuk_mirror_gcp_storage_transfer.name]
  policy_arn = aws_iam_policy.govuk_mirror_gcp_storage_transfer.arn
}

module "govuk_mirror_sync_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.0"

  name            = "govuk-mirror-sync"
  use_name_prefix = false
  description     = "Role for govuk-mirror-sync to access S3. Corresponds to govuk-mirror-sync k8s ServiceAccount."

  oidc_providers = {
    "${local.cluster_name}" = {
      provider_arn               = local.provider_arn
      namespace_service_accounts = ["apps:mirror"]
    }
  }

  policies = {
    govuk_mirror_sync_policy = aws_iam_policy.govuk_mirror_sync.arn
  }
}

data "aws_iam_policy_document" "govuk_mirror_sync" {
  statement {
    sid = "ReadWriteFromMirrorBucket"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionTagging",
      "s3:HeadObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
      "s3:ListMultipartUploadParts",
      "s3:PutAccelerateConfiguration",
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionTagging"
    ]
    resources = [
      "arn:aws:s3:::govuk-${var.govuk_environment}-mirror/*",
      "arn:aws:s3:::govuk-${var.govuk_environment}-mirror"
    ]
  }

  statement {
    sid = "MakeAthenaQueries"
    actions = [
      "athena:GetQueryExecution",
      "athena:StartQueryExecution"
    ]
    resources = [
      "arn:aws:athena:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:workgroup/*",
    ]
  }

  statement {
    sid = "AthenaS3PermissionsInResults"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListMultipartUploadParts",
      "s3:*Object"
    ]
    resources = [
      aws_s3_bucket.athena_query_results.arn,
      "${aws_s3_bucket.athena_query_results.arn}/*",
    ]
    condition {
      test     = "ForAnyValue:StringEquals"
      values   = ["athena.amazonaws.com"]
      variable = "aws:CalledVia"
    }
  }

  statement {
    sid = "AthenaS3PermissionsInDataSource"
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    resources = [
      data.tfe_outputs.fastly_logs.nonsensitive_values.govuk_fastly_logs_s3_bucket_arn,
      "${data.tfe_outputs.fastly_logs.nonsensitive_values.govuk_fastly_logs_s3_bucket_arn}/*",
    ]
    condition {
      test     = "ForAnyValue:StringEquals"
      values   = ["athena.amazonaws.com"]
      variable = "aws:CalledVia"
    }
  }

  statement {
    sid = "AthenaGluePermissions"
    actions = [
      "glue:BatchGetTable",
      "glue:GetDatabase",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
    ]
    resources = [
      "arn:aws:glue:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:catalog",
      "arn:aws:glue:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:database/fastly_logs",
      "arn:aws:glue:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:table/fastly_logs/govuk_www",
    ]
    condition {
      test     = "ForAnyValue:StringEquals"
      values   = ["athena.amazonaws.com"]
      variable = "aws:CalledVia"
    }
  }

  statement {
    sid = "RetrieveAthenaQueryResults"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.athena_query_results.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "govuk_mirror_sync" {
  name        = "govuk-mirror-sync"
  description = "Allows mirror sync process to access S3."

  policy = data.aws_iam_policy_document.govuk_mirror_sync.json
}

resource "aws_secretsmanager_secret" "mirror_slack_webhook" {
  name        = "govuk/mirror/slack-webhook"
  description = "The Slack incoming webhook URL used by the mirror drift detector"
}