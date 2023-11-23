module "cluster-infrastructure-integration" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.9.0"

  organization      = var.organization
  workspace_name    = "cluster-infrastructure-integration"
  workspace_desc    = "The cluster-infrastructure module is responsible for the AWS resources which constitute the EKS cluster."
  workspace_tags    = ["integration", "cluster-infrastructure", "eks", "aws"]
  terraform_version = "1.5.2"
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/cluster-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/cluster-infrastructure/**/*"]

  project_name = "govuk-infrastructure"

  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  tfvars = {
    govuk_aws_state_bucket        = "govuk-terraform-steppingstone-integration"
    cluster_version               = 1.27
    cluster_log_retention_in_days = 7
    eks_control_plane_subnets = {
      a = { az = "eu-west-1a", cidr = "10.1.19.0/28" }
      b = { az = "eu-west-1b", cidr = "10.1.19.16/28" }
      c = { az = "eu-west-1c", cidr = "10.1.19.32/28" }
    }
    eks_public_subnets = {
      a = { az = "eu-west-1a", cidr = "10.1.20.0/24" }
      b = { az = "eu-west-1b", cidr = "10.1.21.0/24" }
      c = { az = "eu-west-1c", cidr = "10.1.22.0/24" }
    }
    eks_private_subnets = {
      a = { az = "eu-west-1a", cidr = "10.1.24.0/22" }
      b = { az = "eu-west-1b", cidr = "10.1.28.0/22" }
      c = { az = "eu-west-1c", cidr = "10.1.32.0/22" }
    }
    force_destroy                   = true
    publishing_service_domain       = "integration.publishing.service.gov.uk"
    grafana_db_auto_pause           = true
    rds_apply_immediately           = true
    rds_backup_retention_period     = 1
    rds_skip_final_snapshot         = true
    secrets_recovery_window_in_days = 0
  }

  # Variable Sets must already exist
  variable_set_names = [
    "aws-credentials-integration"
  ]

}
module "cluster-infrastructure-staging" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.9.0"

  organization      = var.organization
  workspace_name    = "cluster-infrastructure-staging"
  workspace_desc    = "The cluster-infrastructure module is responsible for the AWS resources which constitute the EKS cluster."
  workspace_tags    = ["staging", "cluster-infrastructure", "eks", "aws"]
  terraform_version = "1.5.2"
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/cluster-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/cluster-infrastructure/**/*"]

  project_name = "govuk-infrastructure"

  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  tfvars = {
    govuk_aws_state_bucket        = "govuk-terraform-steppingstone-staging"
    cluster_version               = 1.27
    cluster_log_retention_in_days = 7
    eks_control_plane_subnets = {
      a = { az = "eu-west-1a", cidr = "10.12.19.0/28" }
      b = { az = "eu-west-1b", cidr = "10.12.19.16/28" }
      c = { az = "eu-west-1c", cidr = "10.12.19.32/28" }
    }

    eks_public_subnets = {
      a = { az = "eu-west-1a", cidr = "10.12.20.0/24" }
      b = { az = "eu-west-1b", cidr = "10.12.21.0/24" }
      c = { az = "eu-west-1c", cidr = "10.12.22.0/24" }
    }

    eks_private_subnets = {
      a = { az = "eu-west-1a", cidr = "10.12.24.0/22" }
      b = { az = "eu-west-1b", cidr = "10.12.28.0/22" }
      c = { az = "eu-west-1c", cidr = "10.12.32.0/22" }
    }
    publishing_service_domain   = "staging.publishing.service.gov.uk"
    rds_backup_retention_period = 1
  }

  # Variable Sets must already exist
  variable_set_names = [
    "aws-credentials-staging"
  ]

}
module "cluster-infrastructure-production" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.9.0"

  organization      = var.organization
  workspace_name    = "cluster-infrastructure-production"
  workspace_desc    = "The cluster-infrastructure module is responsible for the AWS resources which constitute the EKS cluster."
  workspace_tags    = ["production", "cluster-infrastructure", "eks", "aws"]
  terraform_version = "1.5.2"
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/cluster-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/cluster-infrastructure/**/*"]

  project_name = "govuk-infrastructure"

  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  tfvars = {
    govuk_aws_state_bucket        = "govuk-terraform-steppingstone-production"
    cluster_version               = 1.27
    cluster_log_retention_in_days = 7
    eks_control_plane_subnets = {
      a = { az = "eu-west-1a", cidr = "10.13.19.0/28" }
      b = { az = "eu-west-1b", cidr = "10.13.19.16/28" }
      c = { az = "eu-west-1c", cidr = "10.13.19.32/28" }
    }

    eks_public_subnets = {
      a = { az = "eu-west-1a", cidr = "10.13.20.0/24" }
      b = { az = "eu-west-1b", cidr = "10.13.21.0/24" }
      c = { az = "eu-west-1c", cidr = "10.13.22.0/24" }
    }

    eks_private_subnets = {
      a = { az = "eu-west-1a", cidr = "10.13.24.0/22" }
      b = { az = "eu-west-1b", cidr = "10.13.28.0/22" }
      c = { az = "eu-west-1c", cidr = "10.13.32.0/22" }
    }
    publishing_service_domain = "publishing.service.gov.uk"
    workers_instance_types    = ["m6i.8xlarge", "m6a.8xlarge"]
  }

  # Variable Sets must already exist
  variable_set_names = [
    "aws-credentials-production"
  ]

}
