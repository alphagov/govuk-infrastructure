locals {
  period      = 300
  stat        = "Sum"
  unit        = "Count"
  token_limit = 3000000
}

# Bedrock token usage over 50% alarm
resource "aws_cloudwatch_metric_alarm" "bedrock_token_threshold_50" {
  alarm_name          = "govuk-chat-${var.govuk_environment}-bedrock-token-threshold-50"
  alarm_description   = "WARNING - The current ${var.govuk_environment} Bedrock token usage > 50%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 50
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"

  # m1: CacheWriteInputTokenCount
  metric_query {
    id = "m1"
    metric {
      namespace   = "AWS/Bedrock"
      metric_name = "CacheWriteInputTokenCount"
      period      = local.period
      stat        = local.stat
      unit        = local.unit
    }
    return_data = false
  }

  # m2: InputTokenCount
  metric_query {
    id = "m2"
    metric {
      namespace   = "AWS/Bedrock"
      metric_name = "InputTokenCount"
      period      = local.period
      stat        = local.stat
      unit        = local.unit
    }
    return_data = false
  }

  # m3: OutputTokenCount
  metric_query {
    id = "m3"
    metric {
      namespace   = "AWS/Bedrock"
      metric_name = "OutputTokenCount"
      period      = local.period
      stat        = local.stat
      unit        = local.unit
    }
    return_data = false
  }

  # e1: Percentage Calculation
  metric_query {
    id          = "e1"
    expression  = "((m1 + m2 + (m3 * 5)) / ${local.token_limit}) * 100"
    label       = "Expression1"
    return_data = true
  }

  alarm_actions             = [aws_sns_topic.chat_alerts.arn]
  ok_actions                = [aws_sns_topic.chat_alerts.arn]
  insufficient_data_actions = []
}

# Bedrock token usage over 100% alarm
resource "aws_cloudwatch_metric_alarm" "bedrock_token_threshold_100" {
  alarm_name          = "govuk-chat-${var.govuk_environment}-bedrock-token-threshold-100"
  alarm_description   = "CRITICAL - The current ${var.govuk_environment} Bedrock token usage > 100%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 100
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"

  # m1: CacheWriteInputTokenCount
  metric_query {
    id = "m1"
    metric {
      namespace   = "AWS/Bedrock"
      metric_name = "CacheWriteInputTokenCount"
      period      = local.period
      stat        = local.stat
      unit        = local.unit
    }
    return_data = false
  }

  # m2: InputTokenCount
  metric_query {
    id = "m2"
    metric {
      namespace   = "AWS/Bedrock"
      metric_name = "InputTokenCount"
      period      = local.period
      stat        = local.stat
      unit        = local.unit
    }
    return_data = false
  }

  # m3: OutputTokenCount
  metric_query {
    id = "m3"
    metric {
      namespace   = "AWS/Bedrock"
      metric_name = "OutputTokenCount"
      period      = local.period
      stat        = local.stat
      unit        = local.unit
    }
    return_data = false
  }

  # e1: Percentage Calculation
  metric_query {
    id          = "e1"
    expression  = "((m1 + m2 + (m3 * 5)) / ${local.token_limit}) * 100"
    label       = "Expression1"
    return_data = true
  }

  alarm_actions             = [aws_sns_topic.chat_alerts.arn]
  ok_actions                = [aws_sns_topic.chat_alerts.arn]
  insufficient_data_actions = []
}
