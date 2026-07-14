import {
  to = module.aws_logging_bucket.aws_s3_bucket.this
  id = "govuk-test-aws-logging"
}

import {
  to = module.aws_logging_bucket.aws_s3_bucket_versioning.this
  id = "govuk-test-aws-logging"
}

import {
  to = module.aws_logging_bucket.aws_s3_bucket_server_side_encryption_configuration.this
  id = "govuk-test-aws-logging"
}

import {
  to = module.aws_logging_bucket.aws_s3_bucket_replication_configuration.this[0]
  id = "govuk-test-aws-logging"
}

import {
  to = module.aws_logging_bucket.aws_s3_bucket_policy.bucket_policy
  id = "govuk-test-aws-logging"
}

import {
  to = module.aws_logging_bucket.aws_s3_bucket_lifecycle_configuration.this[0]
  id = "govuk-test-aws-logging"
}

import {
  to = aws_iam_policy.govuk_aws_logging_replication_policy
  id = "arn:aws:iam::430354129336:policy/govuk-test-aws-logging-bucket-replication-policy"
}

import {
  to = aws_iam_role.rds_enhanced_monitoring
  id = "rds-monitoring-role"
}

import {
  to = aws_iam_role.govuk_aws_logging_replication_role
  id = "govuk-aws-logging-replication-role"
}
