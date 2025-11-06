terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["elasticsearch", "aws"]
    }
  }
  required_version = "~> 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      aws_environment      = var.govuk_environment
      project              = "GOV.UK - Search"
      terraform_deployment = "app-elasticsearch6"
    }
  }
}

locals {
  domain = "${var.stackname}-elasticsearch6-domain"
  subnet_ids = [
    data.tfe_outputs.vpc.nonsensitive_values.private_subnet_ids["elasticsearch_a"],
    data.tfe_outputs.vpc.nonsensitive_values.private_subnet_ids["elasticsearch_b"],
    data.tfe_outputs.vpc.nonsensitive_values.private_subnet_ids["elasticsearch_c"],
  ]
}

resource "aws_cloudwatch_log_group" "opensearch_search_slow_logs" {
  name              = "/aws/aes/domains/${local.domain}/es6-search-logs"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_group" "opensearch_index_slow_logs" {
  name              = "/aws/aes/domains/${local.domain}/es6-index-logs"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_group" "opensearch_error_logs" {
  name              = "/aws/aes/domains/${local.domain}/es6-application-logs"
  retention_in_days = 3
}

data "aws_iam_policy_document" "opensearch_log_publishing_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/aes/domains/${local.domain}/*"
    ]
  }
}

resource "aws_cloudwatch_log_resource_policy" "opensearch_log_publishing_policy" {
  policy_name = "elasticsearch6_log_resource_policy"

  policy_document = data.aws_iam_policy_document.opensearch_log_publishing_policy.json
}

resource "aws_iam_service_linked_role" "es_role" {
  aws_service_name = "es.amazonaws.com"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_elasticsearch_domain" "opensearch" {
  depends_on = [aws_iam_service_linked_role.es_role]

  domain_name           = local.domain
  elasticsearch_version = var.engine_version

  cluster_config {
    dedicated_master_enabled = var.dedicated_master != null
    dedicated_master_count   = var.dedicated_master == null ? 0 : var.dedicated_master.instance_count
    dedicated_master_type    = var.dedicated_master == null ? null : var.dedicated_master.instance_type
    instance_count           = var.instance_count
    instance_type            = var.instance_type
    zone_awareness_enabled   = var.zone_awareness_enabled
    zone_awareness_config {
      availability_zone_count = var.zone_awareness_enabled ? length(local.subnet_ids) : null
    }
  }

  advanced_security_options {
    enabled = false
  }

  encrypt_at_rest {
    enabled = var.encryption_at_rest
  }

  domain_endpoint_options {
    enforce_https                   = false
    tls_security_policy             = var.tls_security_policy
    custom_endpoint_enabled         = true
    custom_endpoint                 = "elasticsearch6.${var.govuk_environment}.govuk-internal.digital"
    custom_endpoint_certificate_arn = data.aws_acm_certificate.govuk_internal.arn
  }

  dynamic "ebs_options" {
    for_each = var.ebs[*]

    content {
      ebs_enabled = true
      volume_size = ebs_options.value.volume_size
      volume_type = ebs_options.value.volume_type
      throughput  = ebs_options.value.throughput
      iops        = ebs_options.value.provisioned_iops
    }
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_index_slow_logs.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }
  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_search_slow_logs.arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }
  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_error_logs.arn
    log_type                 = "ES_APPLICATION_LOGS"
  }

  node_to_node_encryption {
    enabled = false
  }

  vpc_options {
    subnet_ids         = local.subnet_ids
    security_group_ids = [data.tfe_outputs.security.nonsensitive_values.govuk_elasticsearch6_access_sg_id]
  }

  access_policies = data.aws_iam_policy_document.domain_access_policy.json

  tags = {
    Name          = "${var.stackname}-elasticsearch6"
    Project       = "${var.stackname}"
    aws_stackname = "${var.stackname}"
  }
}

data "aws_iam_policy_document" "domain_access_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["es:*"]
    resources = ["arn:aws:es:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:domain/${local.domain}/*"]
  }
}

resource "aws_route53_record" "service_record" {
  zone_id = data.tfe_outputs.root_dns.nonsensitive_values.internal_root_zone_id
  name    = "elasticsearch6.${var.stackname}.${data.tfe_outputs.root_dns.nonsensitive_values.internal_root_zone_name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_elasticsearch_domain.opensearch.endpoint]
}
