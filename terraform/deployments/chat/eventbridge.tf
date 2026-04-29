resource "aws_cloudwatch_event_rule" "aws_service_health_alert_dublin" {
  region      = "eu-west-1"
  name        = "chat-aws-service-health-alert"
  description = "Rule to monitor AWS Service Health Events for Chat application in eu-west-1"
  event_pattern = jsonencode({
    "source" : ["aws.health"],
    "detail-type" : ["AWS Health Event"],
    "detail" : {
      "service" : ["BEDROCK", "EKS", "ELASTICACHE", "ES", "RDS"],
      "eventTypeCategory" : ["issue", "scheduledChange"]
    }
  })
  role_arn = aws_iam_role.aws_service_health_alert.arn
}

moved {
  from = aws_cloudwatch_event_rule.aws_service_health_alert
  to   = aws_cloudwatch_event_rule.aws_service_health_alert_dublin
}

resource "aws_cloudwatch_event_rule" "aws_service_health_alert_london" {
  region      = "eu-west-2"
  name        = "chat-aws-service-health-alert"
  description = "Rule to monitor AWS Service Health Events for Chat application in eu-west-2"
  event_pattern = jsonencode({
    "source" : ["aws.health"],
    "detail-type" : ["AWS Health Event"],
    "detail" : {
      "service" : ["BEDROCK", "EKS", "ELASTICACHE", "ES", "RDS"],
      "eventTypeCategory" : ["issue", "scheduledChange"]
    }
  })
  role_arn = aws_iam_role.aws_service_health_alert.arn
}

resource "aws_cloudwatch_event_target" "aws_service_health_alert_dublin" {
  region    = "eu-west-1"
  rule      = aws_cloudwatch_event_rule.aws_service_health_alert_dublin.name
  arn       = aws_sns_topic.chat_alerts_dublin.arn
  target_id = "chat-aws-service-health-alert-target-dublin"
  role_arn  = aws_iam_role.aws_service_health_alert.arn
}

resource "aws_cloudwatch_event_target" "aws_service_health_alert_london" {
  region    = "eu-west-2"
  rule      = aws_cloudwatch_event_rule.aws_service_health_alert_london.name
  arn       = aws_sns_topic.chat_alerts_london.arn
  target_id = "chat-aws-service-health-alert-target-london"
  role_arn  = aws_iam_role.aws_service_health_alert.arn
}

resource "aws_iam_role" "aws_service_health_alert" {
  name               = "govuk-chat-eventbridge-health-alert"
  assume_role_policy = data.aws_iam_policy_document.aws_service_health_alert_assume_role.json
}

data "aws_iam_policy_document" "aws_service_health_alert_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "aws_service_health_alert" {
  statement {
    actions = ["sns:Publish"]
    effect  = "Allow"
    resources = [
      aws_sns_topic.chat_alerts_dublin.arn,
      aws_sns_topic.chat_alerts_london.arn
    ]
  }
}

resource "aws_iam_policy" "aws_service_health_alert" {
  name   = "govuk-chat-eventbridge-health-alert"
  policy = data.aws_iam_policy_document.aws_service_health_alert.json
}

resource "aws_iam_role_policy_attachment" "aws_service_health_alert" {
  role       = aws_iam_role.aws_service_health_alert.name
  policy_arn = aws_iam_policy.aws_service_health_alert.arn
}
