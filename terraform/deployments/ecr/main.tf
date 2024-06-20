terraform {
  required_version = "~> 1.5"
  cloud {
    organization = "govuk"
    workspaces { tags = ["ecr", "eks", "aws"] }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Product              = "GOV.UK"
      System               = "Elastic Container Registry"
      Environment          = var.govuk_environment
      Owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      repository           = "govuk-infrastructure"
      terraform_deployment = basename(abspath(path.root))
    }
  }
}

locals {
  # ecr_repos_by_github_repo is a map of GitHub repo name to a list of ECR
  # repos where the GitHub repo has permission to push images.
  #
  # TODO: rename the oddball images like "licensify-frontend" so that they are
  # prefixed with their Git repo name, for example "licensify/frontend", then
  # turn this back into a simple list. Or, even better, stop pushing images to
  # ECR from GitHub Actions altogether and just configure ECR to be a
  # pull-through cache for ghcr.io.
  ecr_repos_by_github_repo = {
    "account-api" : ["account-api"]
    "asset-manager" : ["asset-manager"]
    "authenticating-proxy" : ["authenticating-proxy"]
    "bouncer" : ["bouncer"]
    "collections" : ["collections"]
    "collections-publisher" : ["collections-publisher"]
    "contacts-admin" : ["contacts-admin"]
    "content-data-admin" : ["content-data-admin"]
    "content-data-api" : ["content-data-api"]
    "content-publisher" : ["content-publisher"]
    "content-store" : ["content-store"]
    "content-tagger" : ["content-tagger"]
    "email-alert-api" : ["email-alert-api"]
    "email-alert-frontend" : ["email-alert-frontend"]
    "email-alert-service" : ["email-alert-service"]
    "feedback" : ["feedback"]
    "finder-frontend" : ["finder-frontend"]
    "frontend" : ["frontend"]
    "government-frontend" : ["government-frontend"]
    "govuk-chat" : ["govuk-chat"]
    "govuk-dependency-checker" : ["govuk-dependency-checker"]
    "govuk-developer-docs" : ["govuk-developer-docs"]
    "govuk-exporter" : ["govuk-exporter"]
    "govuk-fastly" : ["govuk-fastly"]
    "govuk-infrastructure" : ["govuk-infrastructure", "clamav", "mongodb", "toolbox"]
    "govuk-mirror" : ["govuk-mirror"]
    "govuk-replatform-test-app" : ["govuk-replatform-test-app"]
    "govuk-ruby-images" : ["govuk-ruby-images"]
    "govuk-sli-collector" : ["govuk-sli-collector"]
    "hmrc-manuals-api" : ["hmrc-manuals-api"]
    "licensify" : ["licensify", "licensify-backend", "licensify-feed", "licensify-frontend"]
    "link-checker-api" : ["link-checker-api"]
    "local-links-manager" : ["local-links-manager"]
    "locations-api" : ["locations-api"]
    "manuals-publisher" : ["manuals-publisher"]
    "maslow" : ["maslow"]
    "places-manager" : ["places-manager"]
    "publisher" : ["publisher"]
    "publishing-api" : ["publishing-api"]
    "release" : ["release"]
    "router" : ["router"]
    "router-api" : ["router-api"]
    "search-admin" : ["search-admin"]
    "search-api" : ["search-api"]
    "search-api-learn-to-rank" : ["search-api-learn-to-rank"]
    "search-api-v2" : ["search-api-v2"]
    "search-v2-evaluator" : ["search-v2-evaluator"]
    "service-manual-publisher" : ["service-manual-publisher"]
    "short-url-manager" : ["short-url-manager"]
    "signon" : ["signon"]
    "smart-answers" : ["smart-answers"]
    "smokey" : ["smokey"]
    "special-route-publisher" : ["special-route-publisher"]
    "specialist-publisher" : ["specialist-publisher"]
    "static" : ["static"]
    "support" : ["support"]
    "support-api" : ["support-api"]
    "transition" : ["transition"]
    "travel-advice-publisher" : ["travel-advice-publisher"]
    "whitehall" : ["whitehall"]
  }
  repositories = keys(local.ecr_repos_by_github_repo)
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_ecr_repository" "repositories" {
  for_each             = toset(local.repositories)
  name                 = each.key
  image_tag_mutability = "MUTABLE" # To support a movable `latest` for developer convenience.
  image_scanning_configuration { scan_on_push = true }
}

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  for_each   = toset([for repo in local.repositories : aws_ecr_repository.repositories[repo].name])
  repository = each.key

  policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Keep last 20 images with tag prefix deployed-to",
        "selection" : {
          "tagStatus" : "tagged",
          "tagPrefixList" : ["deployed-to"],
          "countType" : "imageCountMoreThan",
          "countNumber" : 20
        },
        "action" : { "type" : "expire" }
      },
      {
        "rulePriority" : 2,
        "description" : "Expire untagged images older than 1 day",
        "selection" : {
          "tagStatus" : "untagged",
          "countType" : "sinceImagePushed",
          "countUnit" : "days",
          "countNumber" : 1
        },
        "action" : { "type" : "expire" }
      },
      {
        "rulePriority" : 4,
        "description" : "Keep last 20 images with tag prefix v",
        "selection" : {
          "tagStatus" : "tagged",
          "tagPrefixList" : ["v"],
          "countType" : "imageCountMoreThan",
          "countNumber" : 20
        },
        "action" : { "type" : "expire" }
      },
      {
        "rulePriority" : 5,
        "description" : "Expire images older than 30 days",
        "selection" : {
          "tagStatus" : "any",
          "countType" : "sinceImagePushed",
          "countUnit" : "days",
          "countNumber" : 30
        },
        "action" : { "type" : "expire" }
      }
    ]
  })
}
