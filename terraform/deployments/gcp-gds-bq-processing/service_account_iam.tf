locals {
  dataform_sa_impersonation_roles = [
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountTokenCreator"
  ]
}

resource "google_service_account_iam_member" "dataform_agent_impersonation" {
  for_each           = toset(local.dataform_sa_impersonation_roles)
  service_account_id = google_service_account.data_processing.name
  role               = each.key
  member             = "serviceAccount:service-${google_project.project.number}@gcp-sa-dataform.iam.gserviceaccount.com"
}
