
resource "aws_bedrock_model_invocation_logging_configuration" "bedrock_logging" {
  logging_config {
    embedding_data_delivery_enabled = true
    text_data_delivery_enabled      = true

    cloudwatch_config {
      log_group_name = aws_cloudwatch_log_group.bedrock_log_group.name
      role_arn       = aws_iam_role.bedrock_cloudwatch.arn
    }
  }
}

