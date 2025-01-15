resource "google_project_iam_custom_role" "gds_bigquery_read_access" {
  description = "Permissions to read BigQuery datasets and tables"
  permissions = [
    "bigquery.datasets.get",
    "bigquery.tables.get",
    "bigquery.tables.getData"
  ]
  role_id = "GDS_BQ_read_access"
  title   = "GDS BQ read access"
}

resource "google_project_iam_custom_role" "gds_bigquery_saved_query_writer" {
  description = "Permissions to create, update and delete BigQuery saved queries"
  permissions = [
    "bigquery.savedqueries.create",
    "bigquery.savedqueries.delete",
    "bigquery.savedqueries.update",
    "dataform.repositories.create",
    "dataform.repositories.get",
    "dataform.repositories.list"
  ]
  role_id = "GDS_BQ_saved_query_writer"
  title   = "GDS BQ saved query writer"
}

resource "google_project_iam_custom_role" "gds_logging_alerts_writer" {
  description = "Permissions to create, update and delete logging alerting policies"
  permissions = [
    "logging.logEntries.create",
    "logging.logEntries.list",
    "logging.logMetrics.create",
    "logging.logMetrics.delete",
    "logging.logMetrics.get",
    "logging.logMetrics.list",
    "logging.logMetrics.update",
    "logging.notificationRules.create",
    "logging.notificationRules.get",
    "logging.notificationRules.list",
    "logging.notificationRules.update",
    "monitoring.alertPolicies.create",
    "monitoring.alertPolicies.delete",
    "monitoring.alertPolicies.get",
    "monitoring.alertPolicies.list",
    "monitoring.alertPolicies.update"
  ]
  role_id = "GDS_log_alert_writer"
  title   = "GDS log alert writer"
}

resource "google_project_iam_custom_role" "gds_bigquery_user" {
  description = "Permissions to read and execute BigQuery jobs and queries"
  permissions = [
    "bigquery.bireservations.get",
    "bigquery.capacityCommitments.get",
    "bigquery.capacityCommitments.list",
    "bigquery.datasets.get",
    "bigquery.datasets.getIamPolicy",
    "bigquery.jobs.create",
    "bigquery.jobs.get",
    "bigquery.jobs.list",
    "bigquery.jobs.listAll",
    "bigquery.jobs.listExecutionMetadata",
    "bigquery.models.list",
    "bigquery.readsessions.create",
    "bigquery.readsessions.getData",
    "bigquery.reservationAssignments.list",
    "bigquery.reservationAssignments.search",
    "bigquery.reservations.get",
    "bigquery.reservations.list",
    "bigquery.savedqueries.get",
    "bigquery.savedqueries.list",
    "bigquery.tables.get",
    "bigquery.tables.getData",
    "bigquery.tables.list",
    "bigquery.transfers.get",
    "bigquery.transfers.update",
    "bigquerymigration.translation.translate",
    "resourcemanager.projects.get",
  ]
  role_id = "gds.bigquery.user"
  title   = "GDS BQ user"
}

resource "google_project_iam_custom_role" "gds_bigquery_editor" {
  description = "Permissions to create, update and delete BigQuery datasets, tables, models, routines and saved queries"
  permissions = [
    "bigquery.capacityCommitments.get",
    "bigquery.capacityCommitments.list",
    "bigquery.config.get",
    "bigquery.datasets.create",
    "bigquery.datasets.get",
    "bigquery.datasets.getIamPolicy",
    "bigquery.datasets.update",
    "bigquery.datasets.updateTag",
    "bigquery.jobs.create",
    "bigquery.jobs.get",
    "bigquery.models.create",
    "bigquery.models.delete",
    "bigquery.models.export",
    "bigquery.models.getData",
    "bigquery.models.getMetadata",
    "bigquery.models.list",
    "bigquery.models.updateData",
    "bigquery.models.updateMetadata",
    "bigquery.models.updateTag",
    "bigquery.readsessions.create",
    "bigquery.readsessions.getData",
    "bigquery.routines.create",
    "bigquery.routines.delete",
    "bigquery.routines.get",
    "bigquery.routines.list",
    "bigquery.routines.update",
    "bigquery.routines.updateTag",
    "bigquery.savedqueries.create",
    "bigquery.savedqueries.delete",
    "bigquery.savedqueries.get",
    "bigquery.savedqueries.list",
    "bigquery.savedqueries.update",
    "bigquery.tables.create",
    "bigquery.tables.createIndex",
    "bigquery.tables.createSnapshot",
    "bigquery.tables.delete",
    "bigquery.tables.deleteIndex",
    "bigquery.tables.export",
    "bigquery.tables.get",
    "bigquery.tables.getData",
    "bigquery.tables.getIamPolicy",
    "bigquery.tables.list",
    "bigquery.tables.replicateData",
    "bigquery.tables.restoreSnapshot",
    "bigquery.tables.update",
    "bigquery.tables.updateData",
    "bigquery.tables.updateTag",
    "bigquery.transfers.get",
    "bigquery.transfers.update",
    "bigquerymigration.translation.translate",
    "dataform.locations.get",
    "dataform.locations.list",
    "dataform.repositories.create",
    "resourcemanager.projects.get"
  ]
  role_id = "GDS_BQ_editor"
  title   = "GDS BQ editor"
}
