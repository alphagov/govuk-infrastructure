resource "google_monitoring_notification_channel" "slack_alerts_channel" {
  display_name = "Insights & Analytics Slack Alerts Channel"
  type         = "email"
  labels = {
    email_address = data.google_secret_manager_secret_version.slack_alert_channel_email_address_secret_value.secret_data
  }
}

resource "google_monitoring_alert_policy" "tables_metadata" {
  display_name = "Tables metadata"
  combiner     = "OR"
  conditions {
    display_name = "Error condition"
    condition_matched_log {
      filter = "resource.type=\"bigquery_resource\" severity=\"ERROR\" protoPayload.methodName=\"jobservice.jobcompleted\" SEARCH(protoPayload.status.message, \"${var.alerts_error_message_old_data}\") OR SEARCH(protoPayload.status.message, \"${var.alerts_error_message_no_data}\")"
    }
  }

  severity = "ERROR"

  notification_channels = [google_monitoring_notification_channel.slack_alerts_channel.name]
  alert_strategy {
    // One day
    auto_close = "86400s"
    notification_rate_limit {
      // One day
      period = "86400s"
    }
  }

  documentation {
    content   = "This alert triggers when GovGraph data is late or something has gone wrong with processing. Please refer to the [runbook](https://gov-uk.atlassian.net/wiki/x/AgBcKQE) to resolve."
    mime_type = "text/markdown"
    subject   = "Late or missing data in GovGraph BigQuery tables"
    links {
      display_name = "GovGraph Runbook"
      url          = "https://gov-uk.atlassian.net/wiki/x/AgBcKQE"
    }
  }
}
