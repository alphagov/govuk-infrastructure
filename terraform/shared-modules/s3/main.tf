resource "aws_s3_bucket" "this" {
  bucket = var.name

  tags = {
    Name = var.name
  }
}

resource "aws_s3_bucket_object_lock_configuration" "this" {
  count  = length(var.object_lock_config) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.object_lock_config
    content {
      dynamic "default_retention" {
        for_each = try(rule.value.rule, null)[*]
        content {
          mode  = default_retention.value.default_retention.mode
          days  = try(default_retention.value.default_retention.days, null)
          years = try(default_retention.value.default_retention.years, null)
        }
      }
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      status = rule.value.status
      id     = rule.value.id

      dynamic "abort_incomplete_multipart_upload" {
        for_each = try(rule.value.abort_incomplete_multipart_upload, null)[*]
        content {
          days_after_initiation = lookup(abort_incomplete_multipart_upload.value, "days_after_initiation", null)
        }
      }

      dynamic "expiration" {
        for_each = try(rule.value.expiration, null)[*]
        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      dynamic "filter" {
        for_each = try(rule.value.filter, null)[*]
        content {

          dynamic "and" {
            for_each = try(filter.value.and, null)[*]
            content {
              object_size_greater_than = lookup(and.value, "object_size_greater_than", null)
              object_size_less_than    = lookup(and.value, "object_size_less_than", null)
              prefix                   = lookup(and.value, "prefix", null)
              tags                     = lookup(and.value, "tag", null)
            }
          }

          dynamic "tag" {
            for_each = try(filter.value.tag, null)[*]
            content {
              key   = lookup(tag.value, "key", null)
              value = lookup(tag.value, "value", null)
            }
          }
          object_size_greater_than = lookup(filter.value, "object_size_greater_than", null)
          object_size_less_than    = lookup(filter.value, "object_size_less_than", null)
          prefix                   = lookup(filter.value, "prefix", null)
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = try(rule.value.noncurrent_version_expiration, null)[*]
        content {
          noncurrent_days           = lookup(noncurrent_version_expiration.value, "noncurrent_days", null)
          newer_noncurrent_versions = lookup(noncurrent_version_expiration.value, "newer_noncurrent_versions", null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = try(rule.value.noncurrent_version_transition, null)[*]
        content {
          noncurrent_days           = lookup(noncurrent_version_transition.value, "noncurrent_days", null)
          storage_class             = lookup(noncurrent_version_transition.value.storage_class, "storage_class", null)
          newer_noncurrent_versions = lookup(noncurrent_version_transition.value, "newer_noncurrent_versions", null)
        }
      }

      dynamic "transition" {
        for_each = try(rule.value.transition, null)[*]
        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.enable_public_access_block ? 1 : 0

  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "https_only" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    sid     = "httpsOnly"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
}

data "aws_iam_policy_document" "s3_combined_policy" {
  source_policy_documents = flatten([
    data.aws_iam_policy_document.https_only.json,
  var.extra_bucket_policies])
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3_combined_policy.json
}

resource "aws_s3_bucket_ownership_controls" "owner" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_logging" "this" {
  bucket = aws_s3_bucket.this.id

  target_bucket = var.access_logging_config.target_bucket == null ? "govuk-${var.govuk_environment}-aws-logging" : var.access_logging_config.target_bucket
  target_prefix = var.access_logging_config.target_prefix == null ? "s3/${aws_s3_bucket.this.name}/" : var.access_logging_config.target_prefix

  dynamic "target_object_key_format" {
    for_each = try(var.access_logging_config, null)[*]
    content {
      dynamic "simple_prefix" {
        for_each = try(target_object_key_format.value.target_object_key_format.simple_prefix, null)[*]
        content {
        }
      }
      dynamic "partitioned_prefix" {
        for_each = try(target_object_key_format.value.target_object_key_format.partitioned_prefix, null)[*]
        content {
          partition_date_source = partitioned_prefix.value.partition_date_source
        }
      }
    }
  }
}
