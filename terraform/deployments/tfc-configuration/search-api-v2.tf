# Import resource tfe_project.project from search-v2-infrastructure/terraform/meta/main.tf

import {
  to = tfe_project.project
  id = "prj-yufbkwoTkNMxibBF"
}

resource "tfe_project" "project" {
  name = "govuk-search-api-v2"
}

# Start of importing of all integration module components:
import {
  to = module.environment_integration.tfe_workspace.environment_workspace
  id = "ws-W1w2WqqJTUgUANQk"
}

import {
  to = module.environment_integration.tfe_workspace_settings.environment_workspace_settings
  id = "ws-W1w2WqqJTUgUANQk"
}

import {
  to = module.environment_integration.tfe_variable.gcp_project_id
  id = "govuk/search-api-v2-integration/var-qjn2CZNVCi3TfsNK"
}

import {
  to = module.environment_integration.tfe_variable.gcp_project_number
  id = "govuk/search-api-v2-integration/var-6DsTGzoksKdz2JYa"
}

import {
  to = module.environment_integration.tfe_variable.tfc_gcp_workload_provider_name
  id = "govuk/search-api-v2-integration/var-vuG2JaRMjM5dKt7E"
}

import {
  to = module.environment_integration.tfe_variable.tfc_gcp_service_account_email
  id = "govuk/search-api-v2-integration/var-h5BGU7G7p1bZGc6h"
}

import {
  to = module.environment_integration.tfe_variable.enable_gcp_provider_auth
  id = "govuk/search-api-v2-integration/var-bDjR8sGVpSHABWDL"
}

import {
  to = module.environment_integration.tfe_workspace_variable_set.aws_workspace_credentials
  id = "govuk/search-api-v2-integration/aws-credentials-integration"
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
}

# Start of importing of all staging module components:
import {
  to = module.environment_staging.tfe_workspace.environment_workspace
  id = "ws-2DJbN6rFF1GiQ2s7"
}

import {
  to = module.environment_staging.tfe_workspace_settings.environment_workspace_settings
  id = "ws-2DJbN6rFF1GiQ2s7"
}

import {
  to = module.environment_staging.tfe_variable.gcp_project_id
  id = "govuk/search-api-v2-staging/var-ZmvL1uXqHArMxPw3"
}

import {
  to = module.environment_staging.tfe_variable.gcp_project_number
  id = "govuk/search-api-v2-staging/var-aetSjjum4DHzhGmu"
}

import {
  to = module.environment_staging.tfe_variable.tfc_gcp_workload_provider_name
  id = "govuk/search-api-v2-staging/var-UfY6Uy72VEXPo2rs"
}

import {
  to = module.environment_staging.tfe_variable.tfc_gcp_service_account_email
  id = "govuk/search-api-v2-staging/var-XMYzyrTAGcp5utGo"
}

import {
  to = module.environment_staging.tfe_variable.enable_gcp_provider_auth
  id = "govuk/search-api-v2-staging/var-t39cxvLdqxU5m9sK"
}

import {
  to = module.environment_staging.tfe_workspace_variable_set.aws_workspace_credentials
  id = "govuk/search-api-v2-staging/aws-credentials-staging"
}

import {
  to = module.environment_staging.tfe_run_trigger.apply_after_upstream_workspace[0]
  id = "rt-MrZrhrnX5Ui29A49"
}

# Main staging module
module "environment_staging" {
  source = "./modules/search-api-v2"

  name                          = "staging"
  upstream_environment_name     = "integration"
  google_project_id             = "search-api-v2-staging"
  google_project_number         = "773027887517"
  google_workload_provider_name = "projects/773027887517/locations/global/workloadIdentityPools/terraform-cloud-id-pool/providers/terraform-cloud-provider-oidc"
  google_service_account_email  = "tfc-service-account@search-api-v2-staging.iam.gserviceaccount.com"
  tfc_project                   = tfe_project.project
}

# Start of importing of all production module components:
import {
  to = module.environment_production.tfe_workspace.environment_workspace
  id = "ws-7Asw8cAriLJZoBd7"
}

import {
  to = module.environment_production.tfe_workspace_settings.environment_workspace_settings
  id = "ws-7Asw8cAriLJZoBd7"
}

import {
  to = module.environment_production.tfe_variable.gcp_project_id
  id = "govuk/search-api-v2-production/var-YwH1fj9uqGThY3cN"
}

import {
  to = module.environment_production.tfe_variable.gcp_project_number
  id = "govuk/search-api-v2-production/var-WZx1xngdtrtxGBWF"
}

import {
  to = module.environment_production.tfe_variable.tfc_gcp_workload_provider_name
  id = "govuk/search-api-v2-production/var-LZURSLZMqbRtT7nU"
}

import {
  to = module.environment_production.tfe_variable.tfc_gcp_service_account_email
  id = "govuk/search-api-v2-production/var-z1PcdEQR4rKccKb9"
}

import {
  to = module.environment_production.tfe_variable.enable_gcp_provider_auth
  id = "govuk/search-api-v2-production/var-fQVEseaF1ByPjLDJ"
}

import {
  to = module.environment_production.tfe_workspace_variable_set.aws_workspace_credentials
  id = "govuk/search-api-v2-production/aws-credentials-production"
}

import {
  to = module.environment_production.tfe_run_trigger.apply_after_upstream_workspace[0]
  id = "rt-uR7ws5qAzQovR8v1"
}

# Main production module
module "environment_production" {
  source = "./modules/search-api-v2"

  name                          = "production"
  upstream_environment_name     = "staging"
  google_project_id             = "search-api-v2-production"
  google_project_number         = "931453572747"
  google_workload_provider_name = "projects/931453572747/locations/global/workloadIdentityPools/terraform-cloud-id-pool/providers/terraform-cloud-provider-oidc"
  google_service_account_email  = "tfc-service-account@search-api-v2-production.iam.gserviceaccount.com"
  tfc_project                   = tfe_project.project
}
