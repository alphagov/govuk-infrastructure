resource "google_project_iam_custom_role" "roles--GDS_BQ_read_access" {
  description = "Created on: 2023-10-27"
  permissions = [
    "bigquery.datasets.get", 
    "bigquery.tables.get", 
    "bigquery.tables.getData"
    ]
  project     = google_project.project.project_id
  role_id     = "GDS_BQ_read_access"
  stage       = "GA"
  title       = "GDS BQ read access"
}

resource "google_project_iam_custom_role" "roles--GDS_BQ_saved_query_writer" {
  description = "Created on: 2023-11-23"
  permissions = [
    "bigquery.savedqueries.create", 
    "bigquery.savedqueries.delete", 
    "bigquery.savedqueries.update"
    ]
  project     = google_project.project.project_id
  role_id     = "GDS_BQ_saved_query_writer"
  stage       = "GA"
  title       = "GDS BQ saved query writer"
}

resource "google_project_iam_custom_role" "roles--GDS_BQ_user" {
  description = "Adds transfers update to the standard BigQuery User role"
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
  project     = google_project.project.project_id
  role_id     = "gds.bigquery.user"
  stage       = "GA"
  title       = "GDS BQ user"
}

resource "google_project_iam_custom_role" "roles--GDS_BQ_editor" {
  description = "Edit access to BQ"
  permissions = [
    "bigquery.capacityCommitments.get",
    "bigquery.capacityCommitments.list",
    "bigquery.config.get",
    "bigquery.datasets.create",
    "bigquery.datasets.get",
    "bigquery.datasets.getIamPolicy",
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
  project     = google_project.project.project_id
  role_id     = "GDS_BQ_editor"
  stage       = "GA"
  title       = "GDS BQ editor"
}