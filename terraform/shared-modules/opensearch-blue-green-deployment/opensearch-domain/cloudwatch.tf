locals {
  audit_logs_enabled = var.advanced_security_options != null
}

resource "aws_cloudwatch_log_group" "index_slow_logs" {
  name              = "/aws/opensearch/${var.opensearch_domain_name}/index-slow"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_group" "search_slow_logs" {
  name              = "/aws/opensearch/${var.opensearch_domain_name}/search-slow"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_group" "error_logs" {
  name              = "/aws/opensearch/${var.opensearch_domain_name}/error-logs"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_group" "audit_logs" {
  count = local.audit_logs_enabled ? 1 : 0

  name              = "/aws/opensearch/${var.opensearch_domain_name}/audit-logs"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_resource_policy" "opensearch_log_resource_policy" {
  policy_name     = "${var.opensearch_domain_name}-domain-write"
  policy_document = data.aws_iam_policy_document.opensearch_logs.json
}

data "aws_iam_policy_document" "opensearch_logs" {
  statement {
    sid = "ElasticSearchWriteLogs"

    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]

    resources = concat(
      [
        "${aws_cloudwatch_log_group.index_slow_logs.arn}:*",
        "${aws_cloudwatch_log_group.search_slow_logs.arn}:*",
        "${aws_cloudwatch_log_group.error_logs.arn}:*",
      ],
      local.audit_logs_enabled ? ["${aws_cloudwatch_log_group.audit_logs[0].arn}:*"] : []
    )

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      // Cannot use the resource directly to set this since it must exist before the OpenSearch domain
      values = [
        "arn:aws:es:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:domain/${var.opensearch_domain_name}"
      ]
    }
  }
}
