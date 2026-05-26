resource "aws_cloudwatch_log_group" "bedrock_log_group_dublin" {
  name              = "/aws/bedrock"
  retention_in_days = 30
  region            = "eu-west-1"
}

resource "aws_cloudwatch_log_group" "bedrock_log_group_london" {
  name              = "/aws/bedrock"
  retention_in_days = 30
  region            = "eu-west-2"
}
