import {
  to = aws_s3_bucket.backup_main
  id = "govuk-${var.govuk_environment}-database-backups"
}

import {
  to = aws_s3_bucket.backup_replica
  id = "govuk-${var.govuk_environment}-database-backups-replica"
}

/*import {
  to = aws_s3_bucket_object_lock_configuration.backup_main
  id = "govuk-${var.govuk_environment}-database-backups"
}

import {
  to = aws_s3_bucket_object_lock_configuration.backup_replica
  id = "govuk-${var.govuk_environment}-database-backups-replica"
}*/

import {
  to = aws_s3_bucket_public_access_block.backup_main
  id = "govuk-${var.govuk_environment}-database-backups"
}

import {
  to = aws_s3_bucket_public_access_block.backup_replica
  id = "govuk-${var.govuk_environment}-database-backups-replica"
}

import {
  to = aws_s3_bucket_logging.backup_main
  id = "govuk-${var.govuk_environment}-database-backups"
}

import {
  to = aws_s3_bucket_logging.backup_replica
  id = "govuk-${var.govuk_environment}-database-backups-replica"
}

import {
  to = aws_s3_bucket_versioning.backup_main
  id = "govuk-${var.govuk_environment}-database-backups"
}

import {
  to = aws_s3_bucket_versioning.backup_replica
  id = "govuk-${var.govuk_environment}-database-backups-replica"
}

import {
  to = aws_s3_bucket_lifecycle_configuration.backup_main
  id = "govuk-${var.govuk_environment}-database-backups"
}

import {
  to = aws_s3_bucket_lifecycle_configuration.backup_replica
  id = "govuk-${var.govuk_environment}-database-backups-replica"
}

import {
  to = aws_s3_bucket_replication_configuration.backup_main
  id = "govuk-${var.govuk_environment}-database-backups"
}

import {
  to = aws_iam_role.backup_replication
  id = "database-backups-s3-replication"
}

import {
  to = aws_iam_policy.backup_replication
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/db-backup-s3-replication"
}
