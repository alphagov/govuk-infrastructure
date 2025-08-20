resource "aws_iam_role" "cloudfront_cloudwatch" {
  name               = "${var.govuk_environment}-cloudfront-cloudwatch-role"
  assume_role_policy = data.aws_iam_policy_document.cloudfront_cloudwatch_assume_role.json
}

data "aws_region" "current" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "cloudfront_cloudwatch_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "cloudfront_cloudwatch" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.www_distribution_cloudfront_log_group.name}:*"
    ]
  }
}

resource "aws_iam_policy" "cloudfront_cloudwatch" {
  name   = "${var.govuk_environment}-cloudfront-cloudwatch-policy"
  policy = data.aws_iam_policy_document.cloudfront_cloudwatch.json
}

resource "aws_iam_role_policy_attachment" "cloudfront_cloudwatch" {
  role       = aws_iam_role.cloudfront_cloudwatch.name
  policy_arn = aws_iam_policy.cloudfront_cloudwatch.arn
}

resource "aws_cloudwatch_log_group" "www_distribution_cloudfront_log_group" {
  name              = "/aws/cloudfront/www-${var.govuk_environment}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_delivery_source" "www_distribution_cloudfront_log_delivery_source" {
  name         = "www_distribution_cloudfront"
  log_type     = "ACCESS_LOGS"
  provider     = aws.global
  resource_arn = aws_cloudfront_distribution.www_distribution.arn
}

resource "aws_cloudwatch_log_delivery_destination" "www_distribution_cloudfront_log_delivery_destination" {
  name     = "www_distribution_cloudfront_log_group"
  provider = aws.global

  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.www_distribution_cloudfront_log_group.arn
  }
}

resource "aws_cloudwatch_log_delivery" "www_distribution_cloudfront_log_delivery" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.www_distribution_cloudfront_log_delivery_source.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.www_distribution_cloudfront_log_delivery_destination.arn
}