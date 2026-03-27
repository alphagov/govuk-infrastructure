resource "google_iam_workload_identity_pool" "main" {
  project                   = var.project_id
  workload_identity_pool_id = "github-pool"
}

resource "google_iam_workload_identity_pool_provider" "main" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.main.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-pool-provider"
  attribute_mapping = {
    # https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
  }

  # This is the numeric immutable ID of the 'alphagov' GitHub org.
  attribute_condition = "assertion.repository_owner_id == '596977'"

  oidc {
    allowed_audiences = []
    issuer_uri        = "https://token.actions.githubusercontent.com"
  }
}
