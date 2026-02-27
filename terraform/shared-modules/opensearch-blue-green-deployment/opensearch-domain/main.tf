resource "aws_opensearch_domain" "opensearch" {
  domain_name    = var.opensearch_domain_name
  engine_version = "${var.engine}_${var.engine_version}"

  cluster_config {
    dedicated_master_count   = var.dedicated_master != null ? var.dedicated_master.instance_count : null
    dedicated_master_type    = var.dedicated_master != null ? var.dedicated_master.instance_type : null
    dedicated_master_enabled = var.dedicated_master != null ? true : false
    instance_type            = var.instance_type
    instance_count           = var.instance_count
    zone_awareness_enabled   = var.zone_awareness_enabled
    zone_awareness_config {
      availability_zone_count = var.zone_awareness_enabled ? length(var.subnet_ids) : null
    }
    multi_az_with_standby_enabled = var.multi_az_with_standby_enabled
  }

  advanced_security_options {
    enabled                        = true
    anonymous_auth_enabled         = var.advanced_security_options.anonymous_auth_enabled
    internal_user_database_enabled = var.advanced_security_options.internal_user_database_enabled
    master_user_options {
      master_user_name     = var.advanced_security_options.master_user_options.master_user_name
      master_user_password = var.advanced_security_options.master_user_options.master_user_password
    }
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https                   = true
    tls_security_policy             = "Policy-Min-TLS-1-2-2019-07"
    custom_endpoint_enabled         = true
    custom_endpoint                 = var.custom_endpoint
    custom_endpoint_certificate_arn = data.aws_acm_certificate.govuk_internal.arn
  }

  ebs_options {
    ebs_enabled = var.ebs_options != null
    volume_size = var.ebs_options == null ? null : var.ebs_options.volume_size
    volume_type = var.ebs_options == null ? null : var.ebs_options.volume_type
    throughput  = var.ebs_options == null ? null : var.ebs_options.throughput
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.index_slow_logs.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.search_slow_logs.arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.error_logs.arn
    log_type                 = "ES_APPLICATION_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.audit_logs.arn
    log_type                 = "AUDIT_LOGS"
  }

  node_to_node_encryption {
    enabled = true
  }

  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
}

resource "aws_opensearch_domain_policy" "main" {
  domain_name     = aws_opensearch_domain.opensearch.domain_name
  access_policies = data.aws_iam_policy_document.opensearch_domain.json
}

data "aws_iam_policy_document" "opensearch_domain" {
  statement {
    sid = "AllowOpenSearchAccessFromThisAccount"

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }

    actions = ["es:*"]

    resources = ["${aws_opensearch_domain.opensearch.arn}/*"]
  }
}
