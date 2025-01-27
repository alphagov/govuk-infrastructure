locals {
  # these are not discoverable via data sources
  import_api_mappings = {
    integration = "o3b6ck"
    staging     = "lqtahj"
    production  = "vqlx71"
  }
  import_integrations = {
    integration = "tok8ond"
    staging     = "885lm3d"
    production  = "xw9ey84"
  }
  import_routes = {
    integration = "6hjdbjb"
    staging     = "3c5tubv"
    production  = "s625fpl"
  }
  import_permissions = {
    integration = "terraform-20221208131051168500000003"
    staging     = "terraform-20221208164339170300000003"
    production  = "terraform-20221208164806868900000003"
  }
}

# api_gateway.tf

data "aws_apigatewayv2_apis" "csp_reporter" {
  name = "CSP reporter"
}

import {
  to = aws_apigatewayv2_api.csp_reporter
  id = one(data.aws_apigatewayv2_apis.csp_reporter.ids)
}

import {
  to = aws_apigatewayv2_domain_name.csp_reporter
  id = "csp-reporter.${local.publishing_domain}"
}

import {
  to = aws_apigatewayv2_api_mapping.csp_reporter
  id = "${local.import_api_mappings[var.govuk_environment]}/csp-reporter.${local.publishing_domain}"
}

import {
  to = aws_apigatewayv2_integration.csp_reporter
  id = "${one(data.aws_apigatewayv2_apis.csp_reporter.ids)}/${local.import_integrations[var.govuk_environment]}"
}

import {
  to = aws_apigatewayv2_route.report_route
  id = "${one(data.aws_apigatewayv2_apis.csp_reporter.ids)}/${local.import_routes[var.govuk_environment]}"
}

import {
  to = aws_apigatewayv2_stage.default
  id = "${one(data.aws_apigatewayv2_apis.csp_reporter.ids)}/$default"
}

import {
  to = aws_cloudwatch_log_group.csp_reporter_log_group
  id = "/aws/apigateway/csp-reporter"
}

import {
  to = aws_lambda_permission.gateway_invoke_csp_reports_to_firehose_function
  id = "${aws_lambda_function.lambda.function_name}/${local.import_permissions[var.govuk_environment]}"
}

import {
  to = aws_route53_record.csp_reporter
  id = "${data.tfe_outputs.vpc.nonsensitive_values.external_root_zone_id}_csp-reporter.${data.tfe_outputs.vpc.nonsensitive_values.external_root_zone_name}_A"
}

# buckets.tf

import {
  to = aws_s3_bucket.csp_reports
  id = "govuk-${var.govuk_environment}-csp-reports"
}

import {
  to = aws_s3_bucket_lifecycle_configuration.csp_reports_lifecycle
  id = "govuk-${var.govuk_environment}-csp-reports"
}

# firehose.tf

import {
  to = aws_kinesis_firehose_delivery_stream.delivery_stream
  id = "arn:aws:firehose:eu-west-1:${data.aws_caller_identity.current.account_id}:deliverystream/govuk-${var.govuk_environment}-csp-reports-stream"
}

import {
  to = aws_iam_role.firehose_role
  id = "govuk-${var.govuk_environment}-csp-reports-firehose-role"
}

import {
  to = aws_iam_role_policy.firehose_glue_policy
  id = "${aws_iam_role.firehose_role.name}:govuk-${var.govuk_environment}-csp-reports-firehose-glue-policy"
}

import {
  to = aws_iam_role_policy.firehose_bucket_policy
  id = "${aws_iam_role.firehose_role.name}:govuk-${var.govuk_environment}-csp-reports-firehose-bucket-policy"
}

import {
  to = aws_iam_role_policy.firehose_kinesis_policy
  id = "${aws_iam_role.firehose_role.name}:govuk-${var.govuk_environment}-csp-reports-firehose-kinesis-policy"
}

# glue.tf

import {
  to = aws_glue_catalog_database.csp_reports
  id = "${data.aws_caller_identity.current.account_id}:csp_reports"
}

import {
  to = aws_iam_role.glue_role
  id = "govuk-${var.govuk_environment}-csp-reports-glue-role"
}

import {
  to = aws_iam_role_policy_attachment.glue_service
  id = "${aws_iam_role.glue_role.name}/arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

import {
  to = aws_iam_role_policy.glue_policy
  id = "${aws_iam_role.glue_role.name}:govuk-${var.govuk_environment}-csp-reports-glue-policy"
}

import {
  to = aws_glue_crawler.csp_reports
  id = "Content Security Policy reports"
}

import {
  to = aws_glue_catalog_table.reports
  id = "${data.aws_caller_identity.current.account_id}:csp_reports:reports"
}

# lambda.tf

import {
  to = aws_lambda_function.lambda
  id = "CspReportsToFirehose"
}

import {
  to = aws_iam_role.lambda_role
  id = "govuk-${var.govuk_environment}-csp-reports-lambda-role"
}

#import {
#  to = aws_iam_role_policy_attachment.lambda_service
#  id = "${aws_iam_role.lambda_role.name}/arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
#}

import {
  to = aws_iam_role_policy.lambda_policy
  id = "${aws_iam_role.lambda_role.name}:govuk-${var.govuk_environment}-csp-reports-lambda-policy"
}

import {
  to = aws_cloudwatch_log_group.lambda_log_group
  id = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
}
