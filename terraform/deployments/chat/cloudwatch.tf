resource "aws_cloudwatch_log_group" "bedrock_log_group" {
  name              = "/aws/bedrock"
  retention_in_days = 30
}
