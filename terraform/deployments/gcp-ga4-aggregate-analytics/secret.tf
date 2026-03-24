locals {
  slack_alert_channel_email_address_secret_id = "slack-alert-channel-email-address"
}

resource "google_secret_manager_secret" "slack_alert_channel_email_address" {
  secret_id = local.slack_alert_channel_email_address_secret_id
  replication {
    auto {}
  }
}

data "google_secret_manager_secret_version" "slack_alert_channel_email_address_secret_value" {
  secret = local.slack_alert_channel_email_address_secret_id

  depends_on = [google_secret_manager_secret.slack_alert_channel_email_address]
}
