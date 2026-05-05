module "gcp-ga4-analytics" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-ga4-analytics"
  workspace_desc      = "GCP project management for the GA4 production project"
  workspace_tags      = ["production", "ga4-analytics", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/ga4-analytics/"
  trigger_patterns    = ["/terraform/deployments/ga4-analytics/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
    "GOV.UK Non-Production (r/o)"  = "read"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-ga4-aggregate-analytics" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-ga4-aggregate-analytics"
  workspace_desc      = "GCP project management for the ga4-aggregate-analytics production project"
  workspace_tags      = ["production", "ga4-aggregate-analytics", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-ga4-aggregate-analytics/"
  trigger_patterns    = ["/terraform/deployments/gcp-ga4-aggregate-analytics/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-gds-bq-processing" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-gds-bq-processing"
  workspace_desc      = "GCP project management for the gds-bq-processing production project"
  workspace_tags      = ["production", "gds-bq-processing", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-gds-bq-processing/"
  trigger_patterns    = ["/terraform/deployments/gcp-gds-bq-processing/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-gds-bq-processing-dev" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "gcp-gds-bq-processing-dev"
  workspace_desc    = "GCP project management for the gds-bq-processing-dev project"
  workspace_tags    = ["dev", "gds-bq-processing", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/gcp-gds-bq-processing-dev/"
  trigger_patterns = [
    "/terraform/deployments/gcp-gds-bq-processing-dev/**/*",
    "/terraform/shared-modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-govuk-publishing" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-govuk-publishing"
  workspace_desc      = "GCP project management for the govuk-publishing production project"
  workspace_tags      = ["production", "govuk-publishing", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-govuk-publishing/"
  trigger_patterns    = ["/terraform/deployments/gcp-govuk-publishing/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-govuk-s3-mirror" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-govuk-s3-mirror"
  workspace_desc      = "GCP project management for the govuk-s3-mirror production project"
  workspace_tags      = ["production", "govuk-s3-mirror", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-govuk-s3-mirror/"
  trigger_patterns    = ["/terraform/deployments/gcp-govuk-s3-mirror/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-govuk-user-feedback" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-govuk-user-feedback"
  workspace_desc      = "GCP project management for the govuk-user-feedback production project"
  workspace_tags      = ["production", "govuk-user-feedback", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-govuk-user-feedback/"
  trigger_patterns    = ["/terraform/deployments/gcp-govuk-user-feedback/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-sde-analysis" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-sde-analysis"
  workspace_desc      = "GCP project management for the sde-analysis production project"
  workspace_tags      = ["production", "sde-analysis", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-sde-analysis/"
  trigger_patterns    = ["/terraform/deployments/gcp-sde-analysis/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-sde-consent-api-dev" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-sde-consent-api-dev"
  workspace_desc      = "GCP project management for the sde-consent-api-dev production project"
  workspace_tags      = ["production", "sde-consent-api-dev", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-sde-consent-api-dev/"
  trigger_patterns    = ["/terraform/deployments/gcp-sde-consent-api-dev/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-sde-prototype-service" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-sde-prototype-service"
  workspace_desc      = "GCP project management for the sde-prototype-service production project"
  workspace_tags      = ["production", "sde-prototype-service", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-sde-prototype-service/"
  trigger_patterns    = ["/terraform/deployments/gcp-sde-prototype-service/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-sde-sandbox-haas" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-sde-sandbox-haas"
  workspace_desc      = "GCP project management for the sde-sandbox-haas production project"
  workspace_tags      = ["production", "sde-sandbox-haas", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-sde-sandbox-haas/"
  trigger_patterns    = ["/terraform/deployments/gcp-sde-sandbox-haas/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-single-consent-api-dev" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-single-consent-api-dev"
  workspace_desc      = "GCP project management for the single-consent-api-dev production project"
  workspace_tags      = ["production", "single-consent-api-dev", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-single-consent-api-dev/"
  trigger_patterns    = ["/terraform/deployments/gcp-single-consent-api-dev/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-blogs-ga4-analytics" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-blogs-ga4-analytics"
  workspace_desc      = "GCP project management for the blogs-ga4-analytics production project"
  workspace_tags      = ["production", "blogs-ga4-analytics", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-blogs-ga4-analytics/"
  trigger_patterns    = ["/terraform/deployments/gcp-blogs-ga4-analytics/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-ga4-user-admin-tool-dev" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-ga4-user-admin-tool-dev"
  workspace_desc      = "GCP project management for the ga4-user-admin-tool-dev production project"
  workspace_tags      = ["production", "ga4-user-admin-tool-dev", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-ga4-user-admin-tool-dev/"
  trigger_patterns    = ["/terraform/deployments/gcp-ga4-user-admin-tool-dev/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-gds-gcp-admin-di" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-gds-gcp-admin-di"
  workspace_desc      = "GCP project management for the gds-gcp-admin-di production project"
  workspace_tags      = ["production", "gds-gcp-admin-di", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-gds-gcp-admin-di/"
  trigger_patterns    = ["/terraform/deployments/gcp-gds-gcp-admin-di/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-gds-gcp-admin-search" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-gds-gcp-admin-search"
  workspace_desc      = "GCP project management for the gds-gcp-admin-search production project"
  workspace_tags      = ["production", "gds-gcp-admin-search", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-gds-gcp-admin-search/"
  trigger_patterns    = ["/terraform/deployments/gcp-gds-gcp-admin-search/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-govuk-bigquery-analytics" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-govuk-bigquery-analytics"
  workspace_desc      = "GCP project management for the govuk-bigquery-analytics production project"
  workspace_tags      = ["production", "govuk-bigquery-analytics", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-govuk-bigquery-analytics/"
  trigger_patterns    = ["/terraform/deployments/gcp-govuk-bigquery-analytics/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-govuk-polling" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-govuk-polling"
  workspace_desc      = "GCP project management for the govuk-polling production project"
  workspace_tags      = ["production", "govuk-polling", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-govuk-polling/"
  trigger_patterns    = ["/terraform/deployments/gcp-govuk-polling/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-sde-consent-api" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-sde-consent-api"
  workspace_desc      = "GCP project management for the sde-consent-api production project"
  workspace_tags      = ["production", "sde-consent-api", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-sde-consent-api/"
  trigger_patterns    = ["/terraform/deployments/gcp-sde-consent-api/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-cpto-content-metadata" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-cpto-content-metadata"
  workspace_desc      = "GCP project management for the cpto-content-metadata production project"
  workspace_tags      = ["production", "cpto-content-metadata", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-cpto-content-metadata/"
  trigger_patterns    = ["/terraform/deployments/gcp-cpto-content-metadata/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-cpto-spam-classifier" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-cpto-spam-classifier"
  workspace_desc      = "GCP project management for the cpto-spam-classifier production project"
  workspace_tags      = ["production", "cpto-spam-classifier", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-cpto-spam-classifier/"
  trigger_patterns    = ["/terraform/deployments/gcp-cpto-spam-classifier/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-data-insights-experimentation" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-data-insights-experimentation"
  workspace_desc      = "GCP project management for the data-insights-experimentation production project"
  workspace_tags      = ["production", "data-insights-experimentation", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-data-insights-experimentation/"
  trigger_patterns    = ["/terraform/deployments/gcp-data-insights-experimentation/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-disco-journeys" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-disco-journeys"
  workspace_desc      = "GCP project management for the disco-journeys production project"
  workspace_tags      = ["production", "disco-journeys", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-disco-journeys/"
  trigger_patterns    = ["/terraform/deployments/gcp-disco-journeys/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-gds-bq-data" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-gds-bq-data"
  workspace_desc      = "GCP project management for the gds-bq-data production project"
  workspace_tags      = ["production", "gds-bq-data", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-gds-bq-data/"
  trigger_patterns    = ["/terraform/deployments/gcp-gds-bq-data/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-gds-bq-reporting" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-gds-bq-reporting"
  workspace_desc      = "GCP project management for the gds-bq-reporting production project"
  workspace_tags      = ["production", "gds-bq-reporting", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-gds-bq-reporting/"
  trigger_patterns    = ["/terraform/deployments/gcp-gds-bq-reporting/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-gds-ga-archive" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-gds-ga-archive"
  workspace_desc      = "GCP project management for the gds-ga-archive production project"
  workspace_tags      = ["production", "gds-ga-archive", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-gds-ga-archive/"
  trigger_patterns    = ["/terraform/deployments/gcp-gds-ga-archive/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-gds-looker" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-gds-looker"
  workspace_desc      = "GCP project management for the gds-looker production project"
  workspace_tags      = ["production", "gds-looker", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-gds-looker/"
  trigger_patterns    = ["/terraform/deployments/gcp-gds-looker/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-gds-social-data" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-gds-social-data"
  workspace_desc      = "GCP project management for the gds-social-data production project"
  workspace_tags      = ["production", "gds-social-data", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-gds-social-data/"
  trigger_patterns    = ["/terraform/deployments/gcp-gds-social-data/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-govuk-content-data" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-govuk-content-data"
  workspace_desc      = "GCP project management for the govuk-content-data production project"
  workspace_tags      = ["production", "govuk-content-data", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-govuk-content-data/"
  trigger_patterns    = ["/terraform/deployments/gcp-govuk-content-data/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}
