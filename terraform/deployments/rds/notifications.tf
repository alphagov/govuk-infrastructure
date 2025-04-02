data "aws_secretsmanager_secret" "slack_channel" {
  name = "govuk/slack/platform-support-email"
}

data "aws_secretsmanager_secret_version" "slack_channel" {
  secret_id = data.aws_secretsmanager_secret.slack_channel.id
}

resource "aws_sns_topic" "rds_alerts" {
  name         = "${var.govuk_environment}-rds-alerts"
  display_name = "RDS Alerts (${var.govuk_environment})"
}

resource "aws_sns_topic_subscription" "rds_alerts" {
  topic_arn = aws_sns_topic.rds_alerts.arn
  protocol  = "email"
  endpoint  = data.aws_secretsmanager_secret_version.slack_channel.secret_string
}
