terraform {
  #backend "s3" {}

  cloud {
    organization = "govuk"
    workspaces {
      tags = ["ecr", "eks", "aws"]
    }
  }

  required_version = "~> 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
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

data "aws_secretsmanager_secret" "github-token" {
  name = "govuk/terraform-cloud/github-token"
}

data "aws_secretsmanager_secret_version" "github-token" {
  secret_id = data.aws_secretsmanager_secret.github-token.id
}

provider "github" {
  owner = "alphagov"
  token = data.aws_secretsmanager_secret_version.github-token.secret_string
}

data "github_repositories" "govuk" {
  query = "org:alphagov topic:container topic:govuk fork:false archived:false"
}

locals {
  repositories = concat(
    local.extra_repositories,
    data.github_repositories.govuk.names
  )

  extra_repositories = [
    "github-cli",
    "mongodb",
    "toolbox",
    "clamav",
    "statsd",
    "govuk-terraform",
    "search-api-learn-to-rank",
    "licensify-backend",
    "licensify-feed",
    "licensify-frontend",
  ]
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
        "description" : "Keep last 100 images with tag prefix deployed-to",
        "selection" : {
          "tagStatus" : "tagged",
          "tagPrefixList" : ["deployed-to"],
          "countType" : "imageCountMoreThan",
          "countNumber" : 100
        },
        "action" : {
          "type" : "expire"
        }
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
        "action" : {
          "type" : "expire"
        }
      },
      {
        "rulePriority" : 3,
        "description" : "Keep last 20 images with tag prefix release-",
        "selection" : {
          "tagStatus" : "tagged",
          "tagPrefixList" : ["release-"],
          "countType" : "imageCountMoreThan",
          "countNumber" : 20
        },
        "action" : {
          "type" : "expire"
        }
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
        "action" : {
          "type" : "expire"
        }
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
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })
}
