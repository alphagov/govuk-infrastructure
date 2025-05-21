data "aws_secretsmanager_secret" "slack_channel" {
  count = startswith(var.govuk_environment, "eph-") ? 0 : 1

  name = "govuk/slack/platform-support-email"
}

data "aws_secretsmanager_secret_version" "slack_channel" {
  count = startswith(var.govuk_environment, "eph-") ? 0 : 1

  secret_id = data.aws_secretsmanager_secret.slack_channel[count.index].id
}

resource "aws_sns_topic" "rds_alerts" {
  name         = "${var.govuk_environment}-rds-alerts"
  display_name = "RDS Alerts (${var.govuk_environment})"
}

resource "aws_sns_topic_subscription" "rds_alerts" {
  count = startswith(var.govuk_environment, "eph-") ? 0 : 1

  topic_arn = aws_sns_topic.rds_alerts.arn
  protocol  = "email"
  endpoint  = data.aws_secretsmanager_secret_version.slack_channel[count.index].secret_string
}
