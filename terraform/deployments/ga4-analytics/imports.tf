import {
  id = "ga4-analytics-352613"
  to = google_project.project
}

import {
  id = "GDS_BQ_read_access"
  to = google_project_iam_custom_role.gds_bigquery_read_access
}

import {
  id = "GDS_BQ_saved_query_writer"
  to = google_project_iam_custom_role.gds_bigquery_saved_query_writer
}

import {
  id = "GDS_log_alert_writer"
  to = google_project_iam_custom_role.gds_logging_alerts_writer
}

import {
  id = "gds.bigquery.user"
  to = google_project_iam_custom_role.gds_bigquery_user
}

import {
  id = "GDS_BQ_editor"
  to = google_project_iam_custom_role.gds_bigquery_editor
}
