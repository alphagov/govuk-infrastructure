terraform {
  cloud {
    organization = "govuk"
    workspaces {
      name = "GitHub"
    }
  }

  required_version = "~> 1.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

# NOTE: Uses GITHUB_TOKEN env var, an OAuth / Personal Access Token, for auth
provider "github" {
  owner = "alphagov"
}

#
# Gives repositories access to push OCI images to GOV.UK Production AWS ECR
# NOTE: AWS_GOVUK_ECR_ACCESS_KEY_ID and AWS_GOVUK_ECR_SECRET_ACCESS_KEY are
# manually created.
#

data "github_repositories" "govuk" {
  query = "topic:govuk topic:container org:alphagov fork:false archived:false"
}

data "github_repository" "govuk" {
  for_each  = toset(data.github_repositories.govuk.full_names)
  full_name = each.key
}

#
# Only the list of repositories which will have access to a secret is created/modified
# here, the secret should have been created in the GitHub UI in advance by a
# GitHub Admin.
#

resource "github_actions_organization_secret_repositories" "aws_govuk_ecr_access_key_id" {
  secret_name             = "AWS_GOVUK_ECR_ACCESS_KEY_ID"
  selected_repository_ids = [for repo in data.github_repository.govuk : repo.repo_id]
}

resource "github_actions_organization_secret_repositories" "aws_govuk_ecr_secret_access_key" {
  secret_name             = "AWS_GOVUK_ECR_SECRET_ACCESS_KEY"
  selected_repository_ids = [for repo in data.github_repository.govuk : repo.repo_id]
}

resource "github_actions_organization_secret_repositories" "ci_user_github_api_token" {
  secret_name             = "GOVUK_CI_GITHUB_API_TOKEN"
  selected_repository_ids = [for repo in data.github_repository.govuk : repo.repo_id]
}

resource "github_actions_organization_secret_repositories" "argo_events_webhook_token" {
  secret_name             = "GOVUK_ARGO_EVENTS_WEBHOOK_TOKEN"
  selected_repository_ids = [for repo in data.github_repository.govuk : repo.repo_id]
}

resource "github_actions_organization_secret_repositories" "argo_events_webhook_url" {
  secret_name             = "GOVUK_ARGO_EVENTS_WEBHOOK_URL"
  selected_repository_ids = [for repo in data.github_repository.govuk : repo.repo_id]
}
