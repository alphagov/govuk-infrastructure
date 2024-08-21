output "google_project_id" {
  value = data.google_project.project.id
}

output "google_service_account_name" {
  value = google_service_account.fastly_writer.name
}

output "bigquery_dataset_id" {
  value = google_bigquery_dataset.fastly_logs.id
}

output "bigquery_table_id" {
  value = google_bigquery_table.fastly_logs.id
}
