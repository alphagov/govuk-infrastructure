# For GitHub Actions to push the repository to GCP

resource "google_sourcerepo_repository" "alphagov_govuk_knowledge_graph_gcp" {
  name = "alphagov/govuk-knowledge-graph-gcp"
}

resource "google_service_account" "source_repositories_github" {
  account_id   = "source-repositories-github"
  display_name = "Source Repositories Service Account for GitHub"
  description  = "Service account for pushing git repositories from GitHub Actions"
}

data "google_iam_policy" "source_repositories_alphagov_govuk_knowledge_graph_gcp" {
  binding {
    role = "roles/writer"
    members = [
      google_service_account.source_repositories_github.member,
    ]
  }
}

resource "google_sourcerepo_repository_iam_policy" "alphagov_govuk_knowledge_graph_gcp" {
  project     = google_sourcerepo_repository.alphagov_govuk_knowledge_graph_gcp.project
  repository  = google_sourcerepo_repository.alphagov_govuk_knowledge_graph_gcp.name
  policy_data = data.google_iam_policy.source_repositories_alphagov_govuk_knowledge_graph_gcp.policy_data
}

data "google_iam_policy" "service_account_source_repositories_github" {
  binding {
    role = "roles/iam.workloadIdentityUser"
    members = [
      "principalSet://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/github-pool/attribute.repository/alphagov/govuk-knowledge-graph-gcp"
    ]
  }
}

resource "google_service_account_iam_policy" "source_repositories_github" {
  service_account_id = google_service_account.source_repositories_github.name
  policy_data        = data.google_iam_policy.service_account_source_repositories_github.policy_data
}
