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

import {
  to = google_dataform_repository.fastly_processing
  id = "projects/${google_project.project.project_id}/locations/europe-west2/repositories/fastly_processing"
}

import {
  to = google_dataform_repository_release_config.production
  id = "projects/${google_project.project.project_id}/locations/europe-west2/repositories/fastly_processing/releaseConfigs/production"
}

import {
  to = google_dataform_repository_workflow_config.config
  id = "projects/${google_project.project.project_id}/locations/europe-west2/repositories/fastly_processing/workflowConfigs/daily"
}

import {
  to = google_service_account.data_processing
  id = "projects/${google_project.project.project_id}/serviceAccounts/data-processing@${google_project.project.project_id}.iam.gserviceaccount.com"
}

import {
  to = google_service_account_iam_member.dataform_agent_impersonation["roles/iam.serviceAccountUser"]
  id = "projects/${google_project.project.project_id}/serviceAccounts/data-processing@${google_project.project.project_id}.iam.gserviceaccount.com roles/iam.serviceAccountUser serviceAccount:service-578894245899@gcp-sa-dataform.iam.gserviceaccount.com"
}
import {
  to = google_service_account_iam_member.dataform_agent_impersonation["roles/iam.serviceAccountTokenCreator"]
  id = "projects/${google_project.project.project_id}/serviceAccounts/data-processing@${google_project.project.project_id}.iam.gserviceaccount.com roles/iam.serviceAccountTokenCreator serviceAccount:service-578894245899@gcp-sa-dataform.iam.gserviceaccount.com"
}

import {
  to = google_project_iam_member.data_processing_permissions["roles/bigquery.admin"]
  id = "${google_project.project.project_id} roles/bigquery.admin serviceAccount:${google_service_account.data_processing.email}"
}

import {
  to = google_project_iam_member.data_processing_permissions["roles/bigquery.jobUser"]
  id = "${google_project.project.project_id} roles/bigquery.jobUser serviceAccount:${google_service_account.data_processing.email}"
}

import {
  to = google_project_iam_member.data_processing_permissions["roles/secretmanager.secretAccessor"]
  id = "${google_project.project.project_id} roles/secretmanager.secretAccessor serviceAccount:${google_service_account.data_processing.email}"
}
