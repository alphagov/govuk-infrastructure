terraform {
  backend "s3" {}

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

resource "github_actions_organization_secret_repositories" "aws_govuk_ecr_access_key_id" {
  secret_name             = "AWS_GOVUK_ECR_ACCESS_KEY_ID"
  selected_repository_ids = [for repo in data.github_repository.govuk : repo.repo_id]
}

resource "github_actions_organization_secret_repositories" "aws_govuk_ecr_secret_access_key" {
  secret_name             = "AWS_GOVUK_ECR_SECRET_ACCESS_KEY"
  selected_repository_ids = [for repo in data.github_repository.govuk : repo.repo_id]
}
