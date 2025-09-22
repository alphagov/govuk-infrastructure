resource "aws_cloudwatch_event_rule" "aws_service_health_alert" {
  name        = "chat-aws-service-health-alert"
  description = "Rule to monitor AWS Service Health Events for Chat application"
  event_pattern = jsonencode({
    "source" : ["aws.health"],
    "detail-type" : ["AWS Health Event"],
    "detail" : {
      "service" : ["BEDROCK", "EKS", "ELASTICACHE", "ES", "RDS"],
      "eventTypeCategory" : ["issue"]
    }
  })
}

resource "aws_cloudwatch_event_target" "aws_service_health_alert" {
  rule      = aws_cloudwatch_event_rule.aws_service_health_alert.name
  arn       = aws_sns_topic.chat_alerts.arn
  target_id = "chat-aws-service-health-alert-target"
}
