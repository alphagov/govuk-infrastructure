resource "aws_sns_topic" "rds_alerts" {
  name         = "govuk-rds-alerts"
  display_name = "GOV.UK RDS Alerts"
}

resource "aws_sns_topic_subscription" "rds_alerts" {
  topic_arn = aws_sns_topic.rds_alerts.arn
  protocol  = "email"
  endpoint  = var.zendesk_2nd_line_email_address
}
