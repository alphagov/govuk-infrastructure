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
      version = "~> 6.0"
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

data "github_repositories" "govuk" {
  query = "topic:govuk org:alphagov archived:false"
}

data "github_repository" "govuk" {
  for_each  = toset(data.github_repositories.govuk.full_names)
  full_name = each.key
}

locals {
  repositories = yamldecode(file("repos.yml"))["repos"]

  deployable_repos = [
    for r in data.github_repository.govuk : r
    if !r.fork && contains(r.topics, "container")
  ]

  gems = [
    for r in data.github_repository.govuk : r
    if !r.fork && contains(r.topics, "gem")
  ]

  pact_publishers = [
    for r in data.github_repository.govuk : r
    if !r.fork && contains(r.topics, "pact-publisher")
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
  for_each   = local.repositories
  repository = each.key
  team_id    = github_team.govuk_production_admin.id
  permission = try(each.value.teams["govuk_production_admin"], "admin")
}

resource "github_team_repository" "govuk_ci_bots_repos" {
  for_each   = local.repositories
  repository = each.key
  team_id    = github_team.govuk_ci_bots.id
  permission = try(each.value.teams["govuk_ci_bots"], "admin")
}

resource "github_team_repository" "govuk_repos" {
  for_each   = local.repositories
  repository = each.key
  team_id    = github_team.govuk.id
  permission = try(each.value.teams["govuk"], "push")
}

resource "github_repository" "govuk_repos" {
  for_each = local.repositories

  name = each.key

  allow_squash_merge = true
  allow_merge_commit = false

  has_downloads        = true
  vulnerability_alerts = true

  delete_branch_on_merge = true

  homepage_url = try(each.value.homepage_url, null)

  lifecycle {
    ignore_changes = [
      description,
      allow_auto_merge,
      allow_merge_commit,
      allow_rebase_merge,
      allow_squash_merge,
      allow_update_branch,
      has_issues,
      has_projects,
      has_wiki,
      squash_merge_commit_title,
      squash_merge_commit_message,
      pages
    ]
  }
}

resource "github_branch_protection" "govuk_repos" {
  for_each = { for repo_name, repo_details in local.repositories : repo_name => repo_details if try(repo_details["branch_protection"], true) }

  repository_id    = github_repository.govuk_repos[each.key].node_id
  pattern          = "main"
  enforce_admins   = true
  allows_deletions = false

  required_pull_request_reviews {
    required_approving_review_count = 1

    pull_request_bypassers = try(each.value.required_pull_request_reviews.pull_request_bypassers, null)
  }

  restrict_pushes {
    blocks_creations = false

    push_allowances = try(
      each.value["push_allowances"],
      ["alphagov/gov-uk-production-admin", "alphagov/gov-uk-production-deploy"]
    )
  }

  required_status_checks {
    strict = try(each.value.strict, false)

    contexts = concat(
      try(each.value["required_status_checks"]["standard_contexts"], []),
      try(each.value["required_status_checks"]["additional_contexts"], [])
    )
  }

  lifecycle {
    ignore_changes = [
      require_conversation_resolution
    ]
  }
}

#
# Only the list of repositories which will have access to a secret is created/modified
# here, the secret should have been created in the GitHub UI in advance by a
# GitHub Admin.
#

resource "github_actions_organization_secret_repositories" "ci_user_github_api_token" {
  secret_name             = "GOVUK_CI_GITHUB_API_TOKEN"
  selected_repository_ids = [for repo in concat(local.deployable_repos, local.gems) : repo.repo_id]
}

resource "github_actions_organization_secret_repositories" "argo_events_webhook_token" {
  secret_name             = "GOVUK_ARGO_EVENTS_WEBHOOK_TOKEN"
  selected_repository_ids = [for repo in local.deployable_repos : repo.repo_id]
}

resource "github_actions_organization_secret_repositories" "argo_events_webhook_url" {
  secret_name             = "GOVUK_ARGO_EVENTS_WEBHOOK_URL"
  selected_repository_ids = [for repo in local.deployable_repos : repo.repo_id]
}

resource "github_actions_organization_secret_repositories" "pact_broker_password" {
  secret_name             = "GOVUK_PACT_BROKER_PASSWORD"
  selected_repository_ids = [for repo in local.pact_publishers : repo.repo_id]
}

resource "github_actions_organization_secret_repositories" "pact_broker_username" {
  secret_name             = "GOVUK_PACT_BROKER_USERNAME"
  selected_repository_ids = [for repo in local.pact_publishers : repo.repo_id]
}
