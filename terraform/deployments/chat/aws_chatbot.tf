# AWS Chatbot, now known as 'Amazon Q Developer in chat applications'

data "aws_chatbot_slack_workspace" "gds" {
  slack_team_name = "GDS"
}

data "aws_iam_policy_document" "chatbot_assume" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["chatbot.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "chatbot" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "chatbot" {
  name   = "govuk-chat-chatbot-${var.govuk_environment}"
  policy = data.aws_iam_policy_document.chatbot.json
}

resource "aws_iam_role" "chatbot" {
  name               = "govuk-chat-chatbot-${var.govuk_environment}"
  assume_role_policy = data.aws_iam_policy_document.chatbot_assume.json
}

resource "aws_iam_role_policy_attachment" "chatbot_q" {
  role       = aws_iam_role.chatbot.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonQDeveloperAccess"
}

resource "aws_iam_role_policy_attachment" "chatbot" {
  role       = aws_iam_role.chatbot.name
  policy_arn = aws_iam_policy.chatbot.arn
}

resource "aws_chatbot_slack_channel_configuration" "chat" {
  configuration_name = "chat-notifications"
  slack_team_id      = data.aws_chatbot_slack_workspace.gds.slack_team_id
  slack_channel_id   = var.chat_slack_channel_id
  iam_role_arn       = aws_iam_role.chatbot.arn
  sns_topic_arns     = [aws_sns_topic.chat_alerts.arn]
}

resource "aws_sns_topic" "chat_alerts" {
  name         = "chat-alerts-${var.govuk_environment}"
  display_name = "Chat Alerts (${var.govuk_environment})"
}
