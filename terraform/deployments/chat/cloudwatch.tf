resource "aws_cloudwatch_log_group" "bedrock_log_group" {
  name              = "/aws/bedrock"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "chat_distribution_cloudfront_log_group" {
  count = var.cloudfront_create ? 1 : 0

  name              = "/aws/cloudfront/govuk-chat-${var.govuk_environment}"
  provider          = aws.global
  region            = var.aws_region_global
  retention_in_days = 30
}

resource "aws_cloudwatch_log_delivery_source" "chat_distribution_cloudfront_log_delivery_source" {
  count = var.cloudfront_create ? 1 : 0

  name         = "chat_distribution_cloudfront"
  log_type     = "ACCESS_LOGS"
  provider     = aws.global
  resource_arn = aws_cloudfront_distribution.chat_distribution[count.index].arn
}

resource "aws_cloudwatch_log_delivery_destination" "chat_distribution_cloudfront_log_delivery_destination" {
  count = var.cloudfront_create ? 1 : 0

  name     = "chat_distribution_cloudfront_log_group"
  provider = aws.global

  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.chat_distribution_cloudfront_log_group[count.index].arn
  }
}

resource "aws_cloudwatch_log_delivery" "chat_distribution_cloudfront_log_delivery" {
  count = var.cloudfront_create ? 1 : 0

  provider                 = aws.global
  delivery_source_name     = aws_cloudwatch_log_delivery_source.chat_distribution_cloudfront_log_delivery_source[count.index].name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.chat_distribution_cloudfront_log_delivery_destination[count.index].arn
}
