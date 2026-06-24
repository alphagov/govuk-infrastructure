/**********************************************************************************/
/* Import the s3 bucket which is currently in terraform/deployments/elasticsearch */
/**********************************************************************************/
import {
  id = "govuk-${var.govuk_environment}-elasticsearch6-manual-snapshots"
  to = module.opensearch.module.snapshot_bucket.aws_s3_bucket.this
}

import {
  id = "govuk-${var.govuk_environment}-elasticsearch6-manual-snapshots"
  to = module.opensearch.module.snapshot_bucket.aws_s3_bucket_public_access_block.this[0]
}

import {
  id = "govuk-${var.govuk_environment}-elasticsearch6-manual-snapshots"
  to = module.opensearch.module.snapshot_bucket.aws_s3_bucket_server_side_encryption_configuration.this
}

import {
  id = "govuk-${var.govuk_environment}-elasticsearch6-manual-snapshots"
  to = module.opensearch.module.snapshot_bucket.aws_s3_bucket_policy.bucket_policy
}

import {
  id = "govuk-${var.govuk_environment}-elasticsearch6-manual-snapshots"
  to = module.opensearch.module.snapshot_bucket.aws_s3_bucket_versioning.this
}

import {
  id = "govuk-${var.govuk_environment}-elasticsearch6-manual-snapshots"
  to = module.opensearch.module.snapshot_bucket.aws_s3_bucket_ownership_controls.owner
}

import {
  id = "govuk-${var.govuk_environment}-elasticsearch6-manual-snapshots"
  to = module.opensearch.module.snapshot_bucket.aws_s3_bucket_logging.this[0]
}
/**************************************************************************************/
/* END Import the s3 bucket which is currently in terraform/deployments/elasticsearch */
/**************************************************************************************/

moved {
  from = aws_iam_role.manual_snapshot_role
  to   = module.opensearch.aws_iam_role.elasticsearch_snapshot[0]
}

moved {
  from = aws_iam_policy.manual_snapshot_bucket_policy
  to   = module.opensearch.aws_iam_policy.opensearch_snapshot
}

moved {
  from = aws_iam_role_policy_attachment.manual_snapshot_role_policy
  to   = module.opensearch.aws_iam_role_policy_attachment.elasticsearch_snapshot[0]
}

moved {
  from = aws_cloudwatch_log_group.opensearch_search_slow_logs
  to   = module.opensearch.module.green_domain[0].aws_cloudwatch_log_group.search_slow_logs
}

moved {
  from = aws_cloudwatch_log_group.opensearch_index_slow_logs
  to   = module.opensearch.module.green_domain[0].aws_cloudwatch_log_group.index_slow_logs
}

moved {
  from = aws_cloudwatch_log_group.opensearch_error_logs
  to   = module.opensearch.module.green_domain[0].aws_cloudwatch_log_group.error_logs
}

moved {
  from = aws_cloudwatch_log_resource_policy.opensearch_log_publishing_policy
  to   = module.opensearch.module.green_domain[0].aws_cloudwatch_log_resource_policy.opensearch_log_resource_policy
}

moved {
  from = aws_elasticsearch_domain.opensearch
  to   = module.opensearch.module.green_domain[0].aws_elasticsearch_domain.elasticsearch[0]
}
