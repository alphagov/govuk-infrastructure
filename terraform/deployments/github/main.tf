terraform {
  cloud {
    organization = "govuk"
    workspaces { name = "GitHub" }
  }

  required_version = "~> 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.23"
    }
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Product              = "GOV.UK"
      System               = "GitHub"
      Owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      repository           = "govuk-infrastructure"
      terraform_deployment = basename(abspath(path.root))
    }
  }
}

provider "github" {
  owner = "alphagov"

  app_auth {
    id              = var.github_app_id              # or `GITHUB_APP_ID`
    installation_id = var.github_app_installation_id # or `GITHUB_APP_INSTALLATION_ID`
    pem_file        = var.github_app_pem_file        # or `GITHUB_APP_PEM_FILE`
  }
}

#
# Gives repositories access to push OCI images to GOV.UK Production AWS ECR
# NOTE: AWS_GOVUK_ECR_ACCESS_KEY_ID and AWS_GOVUK_ECR_SECRET_ACCESS_KEY are
# manually created.
#

data "github_repositories" "govuk" {
  query = "topic:govuk org:alphagov archived:false"
}

data "github_repository" "govuk" {
  for_each  = toset(data.github_repositories.govuk.full_names)
  full_name = each.key
}

data "github_repository" "govuk_repo_names" {
  for_each = toset(data.github_repositories.govuk.names)
  name     = each.key
}

locals {
  deployable_repos = [
    for r in data.github_repository.govuk : r
    if !r.fork && contains(r.topics, "container")
  ]

  auto_configurable_repos = [
    for r in data.github_repository.govuk_repo_names : r
    if !r.fork && !contains(r.topics, "govuk-sensitive-access")
  ]
}

resource "github_team" "govuk_ci_bots" {
  name        = "GOV.UK CI Bots"
  privacy     = "closed"
  description = "Contains the `govuk-ci` user and grants it admin access to all GOV.UK repos"
}

resource "github_team" "govuk_production_admin" {
  name        = "GOV.UK Production Admin"
  privacy     = "closed"
  description = "https://docs.publishing.service.gov.uk/manual/rules-for-getting-production-access.html"
}

resource "github_team" "govuk" {
  name    = "GOV.UK"
  privacy = "closed"
}

resource "github_team_repository" "govuk_production_admin_repos" {
  for_each   = { for repo in local.auto_configurable_repos : repo.name => repo }
  repository = each.value.name
  team_id    = github_team.govuk_production_admin.id
  permission = "admin"
}

resource "github_team_repository" "govuk_ci_bots_repos" {
  for_each   = { for repo in local.auto_configurable_repos : repo.name => repo }
  repository = each.value.name
  team_id    = github_team.govuk_ci_bots.id
  permission = "admin"
}

resource "github_team_repository" "govuk_repos" {
  for_each   = { for repo in local.auto_configurable_repos : repo.name => repo }
  repository = each.value.name
  team_id    = github_team.govuk.id
  permission = "push"
}

#
# Only the list of repositories which will have access to a secret is created/modified
# here, the secret should have been created in the GitHub UI in advance by a
# GitHub Admin.
#

resource "github_actions_organization_secret_repositories" "aws_govuk_ecr_access_key_id" {
  secret_name             = "AWS_GOVUK_ECR_ACCESS_KEY_ID"
  selected_repository_ids = [for repo in local.deployable_repos : repo.repo_id]
}

resource "github_actions_organization_secret_repositories" "aws_govuk_ecr_secret_access_key" {
  secret_name             = "AWS_GOVUK_ECR_SECRET_ACCESS_KEY"
  selected_repository_ids = [for repo in local.deployable_repos : repo.repo_id]
}

resource "github_actions_organization_secret_repositories" "ci_user_github_api_token" {
  secret_name             = "GOVUK_CI_GITHUB_API_TOKEN"
  selected_repository_ids = [for repo in local.deployable_repos : repo.repo_id]
}

resource "github_actions_organization_secret_repositories" "argo_events_webhook_token" {
  secret_name             = "GOVUK_ARGO_EVENTS_WEBHOOK_TOKEN"
  selected_repository_ids = [for repo in local.deployable_repos : repo.repo_id]
}

resource "github_actions_organization_secret_repositories" "argo_events_webhook_url" {
  secret_name             = "GOVUK_ARGO_EVENTS_WEBHOOK_URL"
  selected_repository_ids = [for repo in local.deployable_repos : repo.repo_id]
}
