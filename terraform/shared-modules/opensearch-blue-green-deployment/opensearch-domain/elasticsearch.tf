locals {
  elasticsearch_domain_name = var.override_aws_elasticsearch_domain_name != null ? var.override_aws_elasticsearch_domain_name : var.opensearch_domain_name
}

resource "aws_elasticsearch_domain" "elasticsearch" {
  count = var.use_aws_elasticsearch_domain_resource ? 1 : 0

  domain_name           = local.elasticsearch_domain_name
  elasticsearch_version = var.engine_version

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
  }

  dynamic "advanced_security_options" {
    for_each = var.advanced_security_options == null ? [] : [var.advanced_security_options]

    content {
      enabled                        = true
      internal_user_database_enabled = advanced_security_options.value.internal_user_database_enabled

      dynamic "master_user_options" {
        for_each = advanced_security_options.value.master_user_options == null ? [] : [advanced_security_options.value.master_user_options]

        content {
          master_user_name     = master_user_options.value.master_user_name
          master_user_password = master_user_options.value.master_user_password
        }
      }
    }
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https                   = !var.disable_enforced_https
    tls_security_policy             = var.endpoint_tls_security_policy
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

  dynamic "log_publishing_options" {
    for_each = var.disable_audit_logs ? [] : [true]

    content {
      cloudwatch_log_group_arn = aws_cloudwatch_log_group.audit_logs[0].arn
      log_type                 = "AUDIT_LOGS"
    }
  }

  node_to_node_encryption {
    enabled = !var.disable_node_to_node_encryption
  }

  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  access_policies = var.inline_access_policy_declaration ? data.aws_iam_policy_document.elasticsearch_domain.json : null
}

resource "aws_elasticsearch_domain_policy" "main" {
  count = var.use_aws_elasticsearch_domain_resource && !var.inline_access_policy_declaration ? 1 : 0

  domain_name     = aws_elasticsearch_domain.elasticsearch[0].domain_name
  access_policies = data.aws_iam_policy_document.elasticsearch_domain.json
}

data "aws_iam_policy_document" "elasticsearch_domain" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["es:*"]

    resources = ["arn:aws:es:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:domain/${local.elasticsearch_domain_name}/*"]
  }
}
