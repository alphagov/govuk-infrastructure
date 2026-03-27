locals {
  # Automatically extracts the UUID from the resource name string
  # Pattern: projects/PRJ/locations/LOC/transferConfigs/UUID
  detection_query_uuid = basename(google_bigquery_data_transfer_config.detection_query.name)
}

resource "google_monitoring_notification_channel" "notification_email" {
  project      = var.project_id
  display_name = "Notification Email Channel"
  type         = "email"
  labels = {
    email_address = var.notification_email_address
  }
}

# Alert Policy for Scheduled Query run failures
resource "google_monitoring_alert_policy" "dts_failure_alert" {
  project      = var.project_id
  display_name = "CRITICAL: Unauthorised Access Detection Query unable to run"
  combiner     = "OR"
  severity     = "CRITICAL"

  conditions {
    display_name = "Detection Query Failed"
    condition_threshold {
      filter          = "resource.type=\"bigquery_dts_config\" AND metric.type=\"bigquerydatatransfer.googleapis.com/transfer_config/completed_runs\""
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0

      trigger {
        count = 1
      }

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_COUNT"
      }
    }
  }

  documentation {
    content   = "The query used to detect unauthorised access is not running. Review the Scheduled Query '${google_bigquery_data_transfer_config.detection_query.display_name}' for details."
    mime_type = "text/markdown"
    subject   = "GA4 Aggregate Analytics Unauthorised Access Detection Query Failed"
    links {
      display_name = "GA4 Aggregate Analytics - Technical Documentation"
      url          = "https://gov-uk.atlassian.net/wiki/x/AYADMAE"
    }
  }

  notification_channels = [google_monitoring_notification_channel.notification_email.name]
}

resource "google_monitoring_alert_policy" "unauthorised_bq_access_alert" {
  project      = var.project_id
  display_name = "CRITICAL: Unauthorised BigQuery Access Detected"
  combiner     = "OR"
  severity     = "CRITICAL"

  conditions {
    display_name = "New rows detected in unauthorised_access table"
    condition_matched_log {
      filter = <<-EOT
        resource.type = "bigquery_resource"
        AND protoPayload.serviceData.jobCompletedEvent.job.jobConfiguration.query.destinationTable.tableId = "${google_bigquery_table.unauthorised_access.table_id}"
        AND protoPayload.serviceData.jobCompletedEvent.job.jobStatistics.queryOutputRowCount > 0
      EOT
    }
  }

  alert_strategy {
    notification_rate_limit {
      period = "3600s"
    }
  }

  notification_channels = [google_monitoring_notification_channel.notification_email.name]

  documentation {
    content   = "Unauthorised BigQuery access was detected. Review the 'unauthorised_access' table in dataset '${google_bigquery_dataset.audit_logs.dataset_id}' for details."
    mime_type = "text/markdown"
    subject   = "Unauthorised Access to GA4 Aggregate Data"
    links {
      display_name = "GA4 Aggregate Analytics - Technical Documentation"
      url          = "https://gov-uk.atlassian.net/wiki/x/AYADMAE"
    }
  }
}
