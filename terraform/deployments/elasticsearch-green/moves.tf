moved {
  from = module.secure_s3_bucket_manual_snapshots
  to   = module.opensearch.module.snapshot_bucket
}

moved {
  from = data.aws_iam_policy_document.manual_snapshots_cross_account_access
  to   = module.opensearch.data.aws_iam_policy_docuemnt.snapshot_bucket_policy
}

moved {
  from = aws_iam_role.manual_snapshot_role
  to   = module.opensearch.aws_iam_role.opensearch_snapshot
}

moved {
  from = data.aws_iam_policy_document.es_can_assume_role
  to   = module.opensearch.data.aws_iam_policy_document.opensearch_snapshot_assume_role
}

moved {
  from = aws_iam_policy.manual_snapshot_bucket_policy
  to   = module.opensearch.aws_iam_policy.opensearch_snapshot
}

moved {
  from = data.aws_iam_policy_document.manual_snapshot_bucket_policy
  to   = module.opensearch.data.aws_iam_policy_document.opensearch_snapshot
}

moved {
  from = aws_iam_role_policy_attachment.manual_snapshot_role_policy
  to   = module.opensearch.aws_iam_role_policy_attachment.opensearch_snapshot
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
  from = data.aws_iam_policy_document.opensearch_log_publishing_policy
  to   = module.opensearch.module.green_domain[0].data.aws_iam_policy_document.opensearch_logs
}

moved {
  from = aws_route53_record.service_record
  to   = module.opensearch.aws_route53_record.service_record
}

moved {
  from = aws_elasticsearch_domain.opensearch
  to   = module.opensearch.module.green_domain[0].aws_elasticsearch_domain.elasticsearch
}

moved {
  from = data.aws_iam_policy_document.domain_access_policy
  to   = module.opensearch.module.green_domain[0].aws_iam_policy_document.opensearch_domain
}
