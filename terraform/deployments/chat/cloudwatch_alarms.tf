locals {
  period                     = 300
  stat                       = "Sum"
  unit                       = "Count"
  claude_sonnet_model_id     = "eu.anthropic.claude-sonnet-4-202505"
  claude_sonnet_token_limit  = var.chat_token_limits_per_minute["claude_sonnet"]
  openai_gpt_oss_model_id    = "openai.gpt-oss-120b-1:0"
  openai_gpt_oss_token_limit = var.chat_token_limits_per_minute["openai_gpt_oss"]
  titan_embed_model_id       = "amazon.titan-embed-text-v2:0"
  titan_embed_token_limit    = var.chat_token_limits_per_minute["titan_embed"]
}

resource "aws_cloudwatch_metric_alarm" "bedrock_token_threshold_50_percent_claude_sonnet" {
  alarm_name          = "govuk-chat-${var.govuk_environment}-bedrock-token-threshold-50-claude-sonnet"
  alarm_description   = <<-EOF
  WARNING - The current ${var.govuk_environment} Bedrock token usage > 50% for Claude Sonnet

  Runbook:
  https://docs.publishing.service.gov.uk/manual/alerts/chat-ai-alerts.html#bedrock-token-threshold-alerts
  EOF
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
      dimensions = {
        ModelId = local.claude_sonnet_model_id
      }
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
      dimensions = {
        ModelId = local.claude_sonnet_model_id
      }
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
      dimensions = {
        ModelId = local.claude_sonnet_model_id
      }
    }
    return_data = false
  }

  # e1: Percentage Calculation
  metric_query {
    id          = "e1"
    expression  = "((m1 + m2 + (m3 * 5)) / ${local.claude_sonnet_token_limit}) * 100"
    label       = "Expression1"
    return_data = true
  }

  alarm_actions             = [aws_sns_topic.chat_alerts.arn]
  ok_actions                = [aws_sns_topic.chat_alerts.arn]
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "bedrock_token_threshold_100_percent_claude_sonnet" {
  alarm_name          = "govuk-chat-${var.govuk_environment}-bedrock-token-threshold-100-claude-sonnet"
  alarm_description   = <<-EOF
  CRITICAL - The current ${var.govuk_environment} Bedrock token usage > 100% for Claude Sonnet

  Runbook:
  https://docs.publishing.service.gov.uk/manual/alerts/chat-ai-alerts.html#bedrock-token-threshold-alerts
  EOF
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
      dimensions = {
        ModelId = local.claude_sonnet_model_id
      }
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
      dimensions = {
        ModelId = local.claude_sonnet_model_id
      }
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
      dimensions = {
        ModelId = local.claude_sonnet_model_id
      }
    }
    return_data = false
  }

  # e1: Percentage Calculation
  metric_query {
    id          = "e1"
    expression  = "((m1 + m2 + (m3 * 5)) / ${local.claude_sonnet_token_limit}) * 100"
    label       = "Expression1"
    return_data = true
  }

  alarm_actions             = [aws_sns_topic.chat_alerts.arn]
  ok_actions                = [aws_sns_topic.chat_alerts.arn]
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "bedrock_token_threshold_50_percent_gpt_oss" {
  alarm_name          = "govuk-chat-${var.govuk_environment}-bedrock-token-threshold-50-gpt-oss"
  alarm_description   = <<-EOF
  WARNING - The current ${var.govuk_environment} Bedrock token usage > 50% for OpenAI GPT-OSS

  Runbook:
  https://docs.publishing.service.gov.uk/manual/alerts/chat-ai-alerts.html#bedrock-token-threshold-alerts
  EOF
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
      dimensions = {
        ModelId = local.openai_gpt_oss_model_id
      }
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
      dimensions = {
        ModelId = local.openai_gpt_oss_model_id
      }
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
      dimensions = {
        ModelId = local.openai_gpt_oss_model_id
      }
    }
    return_data = false
  }

  # e1: Percentage Calculation
  metric_query {
    id          = "e1"
    expression  = "((m1 + m2 + (m3 * 5)) / ${local.openai_gpt_oss_token_limit}) * 100"
    label       = "Expression1"
    return_data = true
  }

  alarm_actions             = [aws_sns_topic.chat_alerts.arn]
  ok_actions                = [aws_sns_topic.chat_alerts.arn]
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "bedrock_token_threshold_100_percent_gpt_oss" {
  alarm_name          = "govuk-chat-${var.govuk_environment}-bedrock-token-threshold-100-gpt-oss"
  alarm_description   = <<-EOF
  CRITICAL - The current ${var.govuk_environment} Bedrock token usage > 100% for OpenAI GPT-OSS

  Runbook:
  https://docs.publishing.service.gov.uk/manual/alerts/chat-ai-alerts.html#bedrock-token-threshold-alerts
  EOF
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
      dimensions = {
        ModelId = local.openai_gpt_oss_model_id
      }
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
      dimensions = {
        ModelId = local.openai_gpt_oss_model_id
      }
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
      dimensions = {
        ModelId = local.openai_gpt_oss_model_id
      }
    }
    return_data = false
  }

  # e1: Percentage Calculation
  metric_query {
    id          = "e1"
    expression  = "((m1 + m2 + (m3 * 5)) / ${local.openai_gpt_oss_token_limit}) * 100"
    label       = "Expression1"
    return_data = true
  }

  alarm_actions             = [aws_sns_topic.chat_alerts.arn]
  ok_actions                = [aws_sns_topic.chat_alerts.arn]
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "bedrock_token_threshold_50_percent_titan_embed" {
  alarm_name          = "govuk-chat-${var.govuk_environment}-bedrock-token-threshold-50-titan-embed"
  alarm_description   = <<-EOF
  WARNING - The current ${var.govuk_environment} Bedrock token usage > 50% for Titan Embed

  Runbook:
  https://docs.publishing.service.gov.uk/manual/alerts/chat-ai-alerts.html#bedrock-token-threshold-alerts
  EOF
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 50
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"

  # m1: InputTokenCount
  metric_query {
    id = "m1"
    metric {
      namespace   = "AWS/Bedrock"
      metric_name = "InputTokenCount"
      period      = local.period
      stat        = local.stat
      unit        = local.unit
      dimensions = {
        ModelId = local.titan_embed_model_id
      }
    }
    return_data = false
  }

  # e1: Percentage Calculation
  metric_query {
    id          = "e1"
    expression  = "m1 / ${local.titan_embed_token_limit} * 100"
    label       = "Expression1"
    return_data = true
  }

  alarm_actions             = [aws_sns_topic.chat_alerts.arn]
  ok_actions                = [aws_sns_topic.chat_alerts.arn]
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "bedrock_token_threshold_100_percent_titan_embed" {
  alarm_name          = "govuk-chat-${var.govuk_environment}-bedrock-token-threshold-100-titan-embed"
  alarm_description   = <<-EOF
  CRITICAL - The current ${var.govuk_environment} Bedrock token usage > 100% for Titan Embed

  Runbook:
  https://docs.publishing.service.gov.uk/manual/alerts/chat-ai-alerts.html#bedrock-token-threshold-alerts
  EOF
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 100
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"

  # m1: InputTokenCount
  metric_query {
    id = "m1"
    metric {
      namespace   = "AWS/Bedrock"
      metric_name = "InputTokenCount"
      period      = local.period
      stat        = local.stat
      unit        = local.unit
      dimensions = {
        ModelId = local.titan_embed_model_id
      }
    }
    return_data = false
  }

  # e1: Percentage Calculation
  metric_query {
    id          = "e1"
    expression  = "m1 / ${local.titan_embed_token_limit} * 100"
    label       = "Expression1"
    return_data = true
  }

  alarm_actions             = [aws_sns_topic.chat_alerts.arn]
  ok_actions                = [aws_sns_topic.chat_alerts.arn]
  insufficient_data_actions = []
}
