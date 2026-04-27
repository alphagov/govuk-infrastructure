locals {
  period = 300
  stat   = "Sum"
  unit   = "Count"

  models = {
    claude_sonnet = {
      model_id    = "eu.anthropic.claude-sonnet-4-202505"
      token_limit = var.chat_token_limits_per_minute["claude_sonnet"]
      expression  = "((m1 + m2 + (m3 * 5)) / TOKEN_LIMIT) * 100"
      sns_topic   = aws_sns_topic.chat_alerts_dublin.arn
    }
    claude_sonnet_4_5 = {
      model_id    = "eu.anthropic.claude-sonnet-4-5-20250929-v1:0"
      token_limit = var.chat_token_limits_per_minute["claude_sonnet_4_5"]
      expression  = "((m1 + m2 + (m3 * 5)) / TOKEN_LIMIT) * 100"
      sns_topic   = aws_sns_topic.chat_alerts_dublin.arn
    }
    haiku_4_5 = {
      model_id    = "eu.anthropic.claude-haiku-4-5-20251001-v1:0"
      token_limit = var.chat_token_limits_per_minute["haiku_4_5"]
      expression  = "((m1 + m2 + (m3 * 5)) / TOKEN_LIMIT) * 100"
      sns_topic   = aws_sns_topic.chat_alerts_dublin.arn
    }
    openai_gpt_oss = {
      model_id    = "openai.gpt-oss-120b-1:0"
      token_limit = var.chat_token_limits_per_minute["openai_gpt_oss"]
      expression  = "((m1 + m2 + (m3 * 5)) / TOKEN_LIMIT) * 100"
      sns_topic   = aws_sns_topic.chat_alerts_dublin.arn
    }
    titan_embed_dublin = {
      model_id    = "amazon.titan-embed-text-v2:0"
      token_limit = var.chat_token_limits_per_minute["titan_embed"]
      expression  = "m2 / TOKEN_LIMIT * 100"
      region      = "eu-west-1"
      sns_topic   = aws_sns_topic.chat_alerts_dublin.arn
    }
    titan_embed_london = {
      model_id    = "amazon.titan-embed-text-v2:0"
      token_limit = var.chat_token_limits_per_minute["titan_embed"]
      expression  = "m2 / TOKEN_LIMIT * 100"
      region      = "eu-west-2"
      sns_topic   = aws_sns_topic.chat_alerts_london.arn
    }
  }

  alarms = {
    "bedrock_token_threshold_50_percent_claude_sonnet" = {
      model_key          = "claude_sonnet",
      threshold          = 50,
      "description_name" = "Claude Sonnet 4"
    }
    "bedrock_token_threshold_100_percent_claude_sonnet" = {
      model_key          = "claude_sonnet",
      threshold          = 100,
      "description_name" = "Claude Sonnet 4"
    }
    "bedrock_token_threshold_50_percent_claude_sonnet_4_5" = {
      model_key          = "claude_sonnet_4_5",
      threshold          = 50,
      "description_name" = "Claude Sonnet 4.5"
    }
    "bedrock_token_threshold_100_percent_claude_sonnet_4_5" = {
      model_key          = "claude_sonnet_4_5",
      threshold          = 100,
      "description_name" = "Claude Sonnet 4.5"
    }
    "bedrock_token_threshold_50_percent_haiku_4_5" = {
      model_key          = "haiku_4_5",
      threshold          = 50,
      "description_name" = "Haiku 4.5"
    }
    "bedrock_token_threshold_100_percent_haiku_4_5" = {
      model_key          = "haiku_4_5",
      threshold          = 100,
      "description_name" = "Haiku 4.5"
    }
    "bedrock_token_threshold_50_percent_gpt_oss" = {
      model_key          = "openai_gpt_oss",
      threshold          = 50,
      "description_name" = "OpenAI GPT-OSS"
    }
    "bedrock_token_threshold_100_percent_gpt_oss" = {
      model_key          = "openai_gpt_oss",
      threshold          = 100,
      "description_name" = "OpenAI GPT-OSS"
    }
    "bedrock_token_threshold_50_percent_titan_embed_dublin" = {
      model_key          = "titan_embed_dublin",
      threshold          = 50,
      "description_name" = "Titan Embed in eu-west-1 (User questions)"
    }
    "bedrock_token_threshold_100_percent_titan_embed_dublin" = {
      model_key          = "titan_embed_dublin",
      threshold          = 100,
      "description_name" = "Titan Embed in eu-west-1 (User questions)"
    }
    "bedrock_token_threshold_50_percent_titan_embed_london" = {
      model_key          = "titan_embed_london",
      threshold          = 50,
      "description_name" = "Titan Embed in eu-west-2 (Document indexing)"
    }
    "bedrock_token_threshold_100_percent_titan_embed_london" = {
      model_key          = "titan_embed_london",
      threshold          = 100,
      "description_name" = "Titan Embed in eu-west-2 (Document indexing)"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "bedrock_token_threshold" {
  for_each = local.alarms

  region              = lookup(local.models[each.value.model_key], "region", null)
  alarm_name          = "govuk-chat-${var.govuk_environment}-${replace(each.key, "_", "-")}"
  alarm_description   = <<-EOF
  ${each.value.threshold == 50 ? "WARNING" : "CRITICAL"} - The current ${var.govuk_environment} Bedrock token usage > ${each.value.threshold}% for ${each.value.description_name}

  Runbook:
  https://docs.publishing.service.gov.uk/manual/alerts/chat-ai-alerts.html#bedrock-token-threshold-alerts
  EOF
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = each.value.threshold
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"

  # m1: CacheWriteInputTokenCount
  dynamic "metric_query" {
    for_each = strcontains(local.models[each.value.model_key].expression, "m1") ? [1] : []
    content {
      id = "m1"
      metric {
        namespace   = "AWS/Bedrock"
        metric_name = "CacheWriteInputTokenCount"
        period      = local.period
        stat        = local.stat
        unit        = local.unit
        dimensions  = { ModelId = local.models[each.value.model_key].model_id }
      }
      return_data = false
    }
  }

  # m2: InputTokenCount
  dynamic "metric_query" {
    for_each = strcontains(local.models[each.value.model_key].expression, "m2") ? [1] : []
    content {
      id = "m2"
      metric {
        namespace   = "AWS/Bedrock"
        metric_name = "InputTokenCount"
        period      = local.period
        stat        = local.stat
        unit        = local.unit
        dimensions  = { ModelId = local.models[each.value.model_key].model_id }
      }
      return_data = false
    }
  }

  # m3: OutputTokenCount
  dynamic "metric_query" {
    for_each = strcontains(local.models[each.value.model_key].expression, "m3") ? [1] : []
    content {
      id = "m3"
      metric {
        namespace   = "AWS/Bedrock"
        metric_name = "OutputTokenCount"
        period      = local.period
        stat        = local.stat
        unit        = local.unit
        dimensions  = { ModelId = local.models[each.value.model_key].model_id }
      }
      return_data = false
    }
  }

  # e1: Percentage Calculation
  metric_query {
    id = "e1"
    expression = replace(
      local.models[each.value.model_key].expression,
      "TOKEN_LIMIT",
      local.models[each.value.model_key].token_limit
    )
    label       = "Expression1"
    return_data = true
  }

  alarm_actions             = [local.models[each.value.model_key].sns_topic]
  ok_actions                = [local.models[each.value.model_key].sns_topic]
  insufficient_data_actions = []
}
