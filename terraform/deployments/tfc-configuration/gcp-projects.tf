module "gcp-ga4-analytics" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-ga4-analytics"
  workspace_desc      = "GCP project management for the GA4 production project"
  workspace_tags      = ["production", "ga4-analytics", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/ga4-analytics/"
  trigger_patterns    = ["/ga4-analytics/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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
  working_directory   = "/gcp-ga4-aggregate-analytics/"
  trigger_patterns    = ["/gcp-ga4-aggregate-analytics/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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
  working_directory   = "/gcp-gds-bq-processing/"
  trigger_patterns    = ["/gcp-gds-bq-processing/**/*"]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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
  working_directory = "/gcp-gds-bq-processing-dev/"
  trigger_patterns = [
    "/gcp-gds-bq-processing-dev/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-blogs-ga4-analytics"
  workspace_desc    = "GCP project management for the blogs-ga4-analytics production project"
  workspace_tags    = ["production", "blogs-ga4-analytics", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-blogs-ga4-analytics/"
  trigger_patterns = [
    "/gcp-blogs-ga4-analytics/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-ga4-user-admin-tool-dev"
  workspace_desc    = "GCP project management for the ga4-user-admin-tool-dev project"
  workspace_tags    = ["dev", "ga4-user-admin-tool", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-ga4-user-admin-tool-dev/"
  trigger_patterns = [
    "/gcp-ga4-user-admin-tool-dev/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-gds-gcp-admin-di"
  workspace_desc    = "GCP project management for the gds-gcp-admin-di production project"
  workspace_tags    = ["production", "gds-gcp-admin-di", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-gds-gcp-admin-di/"
  trigger_patterns = [
    "/gcp-gds-gcp-admin-di/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-gds-gcp-admin-search"
  workspace_desc    = "GCP project management for the gds-gcp-admin-search production project"
  workspace_tags    = ["production", "gds-gcp-admin-search", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-gds-gcp-admin-search/"
  trigger_patterns = [
    "/gcp-gds-gcp-admin-search/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-govuk-bigquery-analytics"
  workspace_desc    = "GCP project management for the govuk-bigquery-analytics production project"
  workspace_tags    = ["production", "govuk-bigquery-analytics", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-govuk-bigquery-analytics/"
  trigger_patterns = [
    "/gcp-govuk-bigquery-analytics/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-govuk-polling"
  workspace_desc    = "GCP project management for the govuk-polling production project"
  workspace_tags    = ["production", "govuk-polling", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-govuk-polling/"
  trigger_patterns = [
    "/gcp-govuk-polling/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-sde-consent-api"
  workspace_desc    = "GCP project management for the sde-consent-api production project"
  workspace_tags    = ["production", "sde-consent-api", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-sde-consent-api/"
  trigger_patterns = [
    "/gcp-sde-consent-api/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-cpto-content-metadata"
  workspace_desc    = "GCP project management for the cpto-content-metadata production project"
  workspace_tags    = ["production", "cpto-content-metadata", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-cpto-content-metadata/"
  trigger_patterns = [
    "/gcp-cpto-content-metadata/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-cpto-spam-classifier"
  workspace_desc    = "GCP project management for the cpto-spam-classifier production project"
  workspace_tags    = ["production", "cpto-spam-classifier", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-cpto-spam-classifier/"
  trigger_patterns = [
    "/gcp-cpto-spam-classifier/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-data-insights-experimentation"
  workspace_desc    = "GCP project management for the data-insights-experimentation production project"
  workspace_tags    = ["production", "data-insights-experimentation", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-data-insights-experimentation/"
  trigger_patterns = [
    "/gcp-data-insights-experimentation/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-disco-journeys"
  workspace_desc    = "GCP project management for the disco-journeys production project"
  workspace_tags    = ["production", "disco-journeys", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-disco-journeys/"
  trigger_patterns = [
    "/gcp-disco-journeys/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-gds-bq-data"
  workspace_desc    = "GCP project management for the gds-bq-data production project"
  workspace_tags    = ["production", "gds-bq-data", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-gds-bq-data/"
  trigger_patterns = [
    "/gcp-gds-bq-data/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-gds-bq-reporting"
  workspace_desc    = "GCP project management for the gds-bq-reporting production project"
  workspace_tags    = ["production", "gds-bq-reporting", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-gds-bq-reporting/"
  trigger_patterns = [
    "/gcp-gds-bq-reporting/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-gds-ga-archive"
  workspace_desc    = "GCP project management for the gds-ga-archive production project"
  workspace_tags    = ["production", "gds-ga-archive", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-gds-ga-archive/"
  trigger_patterns = [
    "/gcp-gds-ga-archive/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-gds-looker"
  workspace_desc    = "GCP project management for the gds-looker production project"
  workspace_tags    = ["production", "gds-looker", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-gds-looker/"
  trigger_patterns = [
    "/gcp-gds-looker/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-gds-social-data"
  workspace_desc    = "GCP project management for the gds-social-data production project"
  workspace_tags    = ["production", "gds-social-data", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-gds-social-data/"
  trigger_patterns = [
    "/gcp-gds-social-data/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-govuk-content-data"
  workspace_desc    = "GCP project management for the govuk-content-data production project"
  workspace_tags    = ["production", "govuk-content-data", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-govuk-content-data/"
  trigger_patterns = [
    "/gcp-govuk-content-data/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

module "gcp-govuk-govsearch" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "gcp-govuk-govsearch"
  workspace_desc    = "GCP project management for the govuk-govsearch production project"
  workspace_tags    = ["production", "govuk-govsearch", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-govuk-govsearch/"
  trigger_patterns = [
    "/gcp-govuk-govsearch/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-govuk-publishing"
  workspace_desc    = "GCP project management for the govuk-publishing production project"
  workspace_tags    = ["production", "govuk-publishing", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-govuk-publishing/"
  trigger_patterns = [
    "/gcp-govuk-publishing/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-govuk-s3-mirror"
  workspace_desc    = "GCP project management for the govuk-s3-mirror production project"
  workspace_tags    = ["production", "govuk-s3-mirror", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-govuk-s3-mirror/"
  trigger_patterns = [
    "/gcp-govuk-s3-mirror/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-govuk-user-feedback"
  workspace_desc    = "GCP project management for the govuk-user-feedback production project"
  workspace_tags    = ["production", "govuk-user-feedback", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-govuk-user-feedback/"
  trigger_patterns = [
    "/gcp-govuk-user-feedback/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-sde-analysis"
  workspace_desc    = "GCP project management for the sde-analysis production project"
  workspace_tags    = ["production", "sde-analysis", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-sde-analysis/"
  trigger_patterns = [
    "/gcp-sde-analysis/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-sde-consent-api-dev"
  workspace_desc    = "GCP project management for the sde-consent-api-dev project"
  workspace_tags    = ["dev", "sde-consent-api", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-sde-consent-api-dev/"
  trigger_patterns = [
    "/gcp-sde-consent-api-dev/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-sde-prototype-service"
  workspace_desc    = "GCP project management for the sde-prototype-service production project"
  workspace_tags    = ["production", "sde-prototype-service", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-sde-prototype-service/"
  trigger_patterns = [
    "/gcp-sde-prototype-service/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-sde-sandbox-haas"
  workspace_desc    = "GCP project management for the sde-sandbox-haas production project"
  workspace_tags    = ["production", "sde-sandbox-haas", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-sde-sandbox-haas/"
  trigger_patterns = [
    "/gcp-sde-sandbox-haas/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

  organization      = var.organization
  workspace_name    = "gcp-single-consent-api-dev"
  workspace_desc    = "GCP project management for the single-consent-api-dev project"
  workspace_tags    = ["dev", "single-consent-api", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-single-consent-api-dev/"
  trigger_patterns = [
    "/gcp-single-consent-api-dev/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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

module "gcp-govuk-user-feedback-dev" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "gcp-govuk-user-feedback-dev"
  workspace_desc    = "GCP project management for the govuk-user-feedback development project"
  workspace_tags    = ["dev", "govuk-user-feedback", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/gcp-govuk-user-feedback-dev/"
  trigger_patterns = [
    "/gcp-govuk-user-feedback-dev/**/*",
    "/modules/gcp-project-init/**/*",
  ]
  global_remote_state = true
  assessments_enabled = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-data-infrastructure"
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
