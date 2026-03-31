import {
  id = "gds-bq-processing"
  to = google_project.project
}

import {
  to = google_project_iam_binding.project_owners
  id = "gds-bq-processing roles/owner"
}

import {
  to = google_project_iam_binding.project_editors
  id = "gds-bq-processing roles/editor"
}

import {
  to = google_bigquery_dataset.fastly_processing
  id = "projects/${google_project.project.project_id}/datasets/fastly_processing"
}

import {
  to = google_bigquery_dataset.govuk_ga4_processing
  id = "projects/${google_project.project.project_id}/datasets/govuk_ga4_processing"
}
