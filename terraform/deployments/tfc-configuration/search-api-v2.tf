resource "tfe_project" "search-api-v2" {
  name = "govuk-search-api-v2"
}


## Moved because the original resource had a generic name, and it should've been more specific
moved {
  from = tfe_project.project
  to   = tfe_project.search-api-v2
}

module "search-api-v2-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "search-api-v2-integration"
  workspace_desc    = "Provisions search-api-v2 Discovery Engine resources for the integration environment"
  workspace_tags    = ["govuk", "search-api-v2", "search-api-v2-environment", "integration"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  auto_apply        = true
  working_directory = "/terraform/deployments/search-api-v2/"
  trigger_patterns = [
    "/terraform/deployments/search-api-v2/**/*",
    "/terraform/deployments/search-api-v2/**/files/**/*",
    "/terraform/variables/integration/search-api-v2.tfvars"
  ]

  project_name = tfe_project.search-api-v2.name
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Non-Production (r/o)" = "write"
    "GOV.UK Production"           = "write"
  }

  envvars = {
    "TFC_GCP_PROVIDER_AUTH"             = true
    "TFC_GCP_WORKLOAD_PROVIDER_NAME"    = "projects/780375417592/locations/global/workloadIdentityPools/terraform-cloud-id-pool/providers/terraform-cloud-provider-oidc"
    "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL" = "tfc-service-account@search-api-v2-integration.iam.gserviceaccount.com"
  }

  tfvars_files = [
    "integration/search-api-v2.tfvars"
  ]

  variable_set_ids = [
    local.gcp_credentials["integration"],
    local.aws_credentials["integration"]
  ]
}

moved {
  from = module.environment_integration.tfe_workspace.environment_workspace
  to   = module.search-api-v2-integration.tfe_workspace.ws
}

moved {
  from = module.environment_integration.tfe_workspace_settings.environment_workspace_settings
  to   = module.search-api-v2-integration.tfe_workspace_settings.ws
}


module "search-api-v2-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "search-api-v2-staging"
  workspace_desc    = "Provisions search-api-v2 Discovery Engine resources for the staging environment"
  workspace_tags    = ["govuk", "search-api-v2", "search-api-v2-environment", "staging"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  auto_apply        = true
  working_directory = "/terraform/deployments/search-api-v2/"
  trigger_patterns = [
    "/terraform/deployments/search-api-v2/**/*",
    "/terraform/deployments/search-api-v2/**/files/**/*",
    "/terraform/variables/staging/search-api-v2.tfvars"
  ]

  project_name = tfe_project.search-api-v2.name
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }

  envvars = {
    "TFC_GCP_PROVIDER_AUTH"             = true
    "TFC_GCP_WORKLOAD_PROVIDER_NAME"    = "projects/773027887517/locations/global/workloadIdentityPools/terraform-cloud-id-pool/providers/terraform-cloud-provider-oidc"
    "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL" = "tfc-service-account@search-api-v2-staging.iam.gserviceaccount.com"
  }

  tfvars_files = [
    "staging/search-api-v2.tfvars"
  ]

  variable_set_ids = [
    local.gcp_credentials["staging"],
    local.aws_credentials["staging"]
  ]
}

moved {
  from = module.environment_staging.tfe_workspace.environment_workspace
  to   = module.search-api-v2-staging.tfe_workspace.ws
}

moved {
  from = module.environment_staging.tfe_workspace_settings.environment_workspace_settings
  to   = module.search-api-v2-staging.tfe_workspace_settings.ws
}


module "search-api-v2-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "search-api-v2-production"
  workspace_desc    = "Provisions search-api-v2 Discovery Engine resources for the production environment"
  workspace_tags    = ["govuk", "search-api-v2", "search-api-v2-environment", "production"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  auto_apply        = false
  working_directory = "/terraform/deployments/search-api-v2/"
  trigger_patterns = [
    "/terraform/deployments/search-api-v2/**/*",
    "/terraform/deployments/search-api-v2/**/files/**/*",
    "/terraform/variables/production/search-api-v2.tfvars"
  ]

  project_name = tfe_project.search-api-v2.name
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }

  envvars = {
    "TFC_GCP_PROVIDER_AUTH"             = true
    "TFC_GCP_WORKLOAD_PROVIDER_NAME"    = "projects/931453572747/locations/global/workloadIdentityPools/terraform-cloud-id-pool/providers/terraform-cloud-provider-oidc"
    "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL" = "tfc-service-account@search-api-v2-production.iam.gserviceaccount.com"
  }

  tfvars_files = [
    "production/search-api-v2.tfvars"
  ]

  variable_set_ids = [
    local.gcp_credentials["production"],
    local.aws_credentials["production"],
  ]
}

moved {
  from = module.environment_production.tfe_workspace.environment_workspace
  to   = module.search-api-v2-production.tfe_workspace.ws
}

moved {
  from = module.environment_production.tfe_workspace_settings.environment_workspace_settings
  to   = module.search-api-v2-production.tfe_workspace_settings.ws
}
