resource "aws_s3_bucket" "govuk_mirror" {
  provider = aws.replica
  bucket   = "govuk-${var.govuk_environment}-mirror"

  tags = {
    Name = "govuk-${var.govuk_environment}-mirror"
  }
}

resource "aws_s3_bucket_versioning" "govuk_mirror" {
  provider = aws.replica
  bucket   = aws_s3_bucket.govuk_mirror.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "govuk_mirror" {
  provider = aws.replica
  bucket   = aws_s3_bucket.govuk_mirror.id

  target_bucket = "govuk-${var.govuk_environment}-aws-secondary-logging"
  target_prefix = "s3/govuk-${var.govuk_environment}-mirror/"
}

resource "aws_s3_bucket_cors_configuration" "govuk_mirror" {
  provider = aws.replica
  bucket   = aws_s3_bucket.govuk_mirror.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "govuk_mirror" {
  provider = aws.replica
  bucket   = aws_s3_bucket.govuk_mirror.id

  rule {
    id = "main"

    filter {}

    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 5
    }
  }
}

resource "aws_s3_bucket" "govuk_mirror_replica" {
  bucket = "govuk-${var.govuk_environment}-mirror-replica"

  tags = {
    Name = "govuk-${var.govuk_environment}-mirror-replica"
  }
}

resource "aws_s3_bucket_versioning" "govuk_mirror_replica" {
  bucket = aws_s3_bucket.govuk_mirror_replica.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "govuk_mirror_replica" {
  bucket = aws_s3_bucket.govuk_mirror_replica.id

  target_bucket = "govuk-${var.govuk_environment}-aws-logging"
  target_prefix = "s3/govuk-${var.govuk_environment}-mirror-replica/"
}


resource "aws_s3_bucket_lifecycle_configuration" "govuk_mirror_replica" {
  bucket = aws_s3_bucket.govuk_mirror_replica.id

  rule {
    id = "main"

    filter {}

    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 5
    }
  }
}

data "aws_iam_policy_document" "s3_mirror_read_policy" {
  statement {
    sid     = "S3FastlyReadBucket"
    actions = ["s3:GetObject"]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.govuk_mirror.id}",
      "arn:aws:s3:::${aws_s3_bucket.govuk_mirror.id}/*",
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
      "arn:aws:s3:::${aws_s3_bucket.govuk_mirror.id}",
      "arn:aws:s3:::${aws_s3_bucket.govuk_mirror.id}/*",
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = data.terraform_remote_state.infra_security_groups.outputs.office_ips
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
      "arn:aws:s3:::${aws_s3_bucket.govuk_mirror.id}",
      "arn:aws:s3:::${aws_s3_bucket.govuk_mirror.id}/*",
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
      "arn:aws:s3:::${aws_s3_bucket.govuk_mirror_replica.id}",
      "arn:aws:s3:::${aws_s3_bucket.govuk_mirror_replica.id}/*",
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
      "arn:aws:s3:::${aws_s3_bucket.govuk_mirror_replica.id}",
      "arn:aws:s3:::${aws_s3_bucket.govuk_mirror_replica.id}/*",
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = data.terraform_remote_state.infra_security_groups.outputs.office_ips
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
      "arn:aws:s3:::${aws_s3_bucket.govuk_mirror_replica.id}",
      "arn:aws:s3:::${aws_s3_bucket.govuk_mirror_replica.id}/*",
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

resource "aws_s3_bucket_policy" "govuk_mirror_read_policy" {
  provider = aws.replica
  bucket   = aws_s3_bucket.govuk_mirror.id
  policy   = data.aws_iam_policy_document.s3_mirror_read_policy.json
}

resource "aws_s3_bucket_policy" "govuk_mirror_replica_read_policy" {
  bucket = aws_s3_bucket.govuk_mirror_replica.id
  policy = data.aws_iam_policy_document.s3_mirror_replica_read_policy.json
}

resource "aws_s3_bucket_replication_configuration" "govuk_mirror" {
  provider   = aws.replica
  depends_on = [aws_s3_bucket_versioning.govuk_mirror]

  role   = aws_iam_role.govuk_mirror_replication_role.arn
  bucket = aws_s3_bucket.govuk_mirror.id

  rule {
    id = "govuk-mirror-replication-whole-bucket-rule"

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.govuk_mirror_replica.arn
      storage_class = "STANDARD"
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

    resources = [aws_s3_bucket.govuk_mirror.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${aws_s3_bucket.govuk_mirror.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${aws_s3_bucket.govuk_mirror_replica.arn}/*"]
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

    resources = [aws_s3_bucket.govuk_mirror.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = ["${aws_s3_bucket.govuk_mirror.arn}/*"]
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

      values = ["${data.google_storage_transfer_project_service_account.default.subject_id}"]
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
  source  = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
  version = "~> 5.28"

  role_name        = "govuk-mirror-sync"
  role_description = "Role for govuk-mirror-sync to access S3. Corresponds to govuk-mirror-sync k8s ServiceAccount."

  cluster_service_accounts = {
    "${local.cluster_name}" = ["apps:govuk-mirror-sync"]
  }

  role_policy_arns = {
    govuk_mirror_sync_policy = aws_iam_policy.govuk_mirror_sync.arn
  }
}

data "aws_iam_policy_document" "govuk_mirror_sync" {
  statement {
    sid = "ReadWriteFromS3"
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
}

resource "aws_iam_policy" "govuk_mirror_sync" {
  name        = "govuk-mirror-sync"
  description = "Allows mirror sync process to access S3."

  policy = data.aws_iam_policy_document.govuk_mirror_sync.json
}
