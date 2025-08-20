resource "aws_cloudwatch_log_group" "www_distribution_cloudfront_log_group" {
  name              = "/aws/cloudfront/www-${var.govuk_environment}"
  provider          = aws.global
  region            = var.aws_region_global
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "assets_distribution_cloudfront_log_group" {
  name              = "/aws/cloudfront/assets-${var.govuk_environment}"
  provider          = aws.global
  region            = var.aws_region_global
  retention_in_days = 30
}

resource "aws_cloudwatch_log_delivery_source" "www_distribution_cloudfront_log_delivery_source" {
  name         = "www_distribution_cloudfront"
  log_type     = "ACCESS_LOGS"
  provider     = aws.global
  resource_arn = aws_cloudfront_distribution.www_distribution.arn
}

resource "aws_cloudwatch_log_delivery_source" "assets_distribution_cloudfront_log_delivery_source" {
  name         = "assets_distribution_cloudfront"
  log_type     = "ACCESS_LOGS"
  provider     = aws.global
  resource_arn = aws_cloudfront_distribution.assets_distribution.arn
}

resource "aws_cloudwatch_log_delivery_destination" "www_distribution_cloudfront_log_delivery_destination" {
  name     = "www_distribution_cloudfront_log_group"
  provider = aws.global

  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.www_distribution_cloudfront_log_group.arn
  }
}

resource "aws_cloudwatch_log_delivery_destination" "assets_distribution_cloudfront_log_delivery_destination" {
  name     = "assets_distribution_cloudfront_log_group"
  provider = aws.global

  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.assets_distribution_cloudfront_log_group.arn
  }
}

resource "aws_cloudwatch_log_delivery" "www_distribution_cloudfront_log_delivery" {
  provider                 = aws.global
  delivery_source_name     = aws_cloudwatch_log_delivery_source.www_distribution_cloudfront_log_delivery_source.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.www_distribution_cloudfront_log_delivery_destination.arn
}

resource "aws_cloudwatch_log_delivery" "assets_distribution_cloudfront_log_delivery" {
  provider                 = aws.global
  delivery_source_name     = aws_cloudwatch_log_delivery_source.assets_distribution_cloudfront_log_delivery_source.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.assets_distribution_cloudfront_log_delivery_destination.arn
}