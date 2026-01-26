resource "tfe_project" "project" {
  name = "govuk-search-api-v2"
}

# Main integration module
module "environment_integration" {
  source = "./modules/search-api-v2"

  name                          = "integration"
  google_project_id             = "search-api-v2-integration"
  google_project_number         = "780375417592"
  google_workload_provider_name = "projects/780375417592/locations/global/workloadIdentityPools/terraform-cloud-id-pool/providers/terraform-cloud-provider-oidc"
  google_service_account_email  = "tfc-service-account@search-api-v2-integration.iam.gserviceaccount.com"
  tfc_project                   = tfe_project.project
  vcs_repo_branch               = "main"
}

# Main staging module
module "environment_staging" {
  source = "./modules/search-api-v2"

  name                          = "staging"
  google_project_id             = "search-api-v2-staging"
  google_project_number         = "773027887517"
  google_workload_provider_name = "projects/773027887517/locations/global/workloadIdentityPools/terraform-cloud-id-pool/providers/terraform-cloud-provider-oidc"
  google_service_account_email  = "tfc-service-account@search-api-v2-staging.iam.gserviceaccount.com"
  tfc_project                   = tfe_project.project
  vcs_repo_branch               = "main"
}

# Main production module
module "environment_production" {
  source = "./modules/search-api-v2"

  name                          = "production"
  google_project_id             = "search-api-v2-production"
  google_project_number         = "931453572747"
  google_workload_provider_name = "projects/931453572747/locations/global/workloadIdentityPools/terraform-cloud-id-pool/providers/terraform-cloud-provider-oidc"
  google_service_account_email  = "tfc-service-account@search-api-v2-production.iam.gserviceaccount.com"
  tfc_project                   = tfe_project.project
  vcs_repo_branch               = "main"
}
