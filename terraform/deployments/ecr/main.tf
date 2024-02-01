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

resource "aws_ecr_repository" "repositories" {
  for_each             = toset(local.repositories)
  name                 = each.key
  image_tag_mutability = "MUTABLE" # To support a movable `latest` for developer convenience.
  image_scanning_configuration { scan_on_push = true }
}

resource "aws_iam_user" "concourse_ecr_user" {
  name = "concourse_ecr_user"
}

resource "aws_iam_user" "github_ecr_user" {
  name = "github_ecr_user"
  tags = { "Description" = "GitHub Actions publishes images to ECR." }
}

data "aws_iam_policy_document" "concourse_ecr_user_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = [aws_iam_user.concourse_ecr_user.arn]
      type        = "AWS"
    }
  }
}

resource "aws_iam_role" "push_to_ecr" {
  name               = "push_to_ecr"
  assume_role_policy = data.aws_iam_policy_document.concourse_ecr_user_assume_role.json
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "push_to_ecr" {
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = ["arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/*"]
  }
}

resource "aws_iam_policy" "push_to_ecr" {
  name   = "push_to_ecr"
  policy = data.aws_iam_policy_document.push_to_ecr.json
}

resource "aws_iam_role_policy_attachment" "push_to_ecr" {
  role       = aws_iam_role.push_to_ecr.name
  policy_arn = aws_iam_policy.push_to_ecr.arn
}

data "aws_iam_policy_document" "allow_cross_account_pull_from_ecr" {
  statement {
    sid    = "AllowCrossAccountPull"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage"
    ]
    principals {
      identifiers = var.puller_arns
      type        = "AWS"
    }
  }
}

resource "aws_ecr_repository_policy" "pull_from_ecr" {
  for_each   = toset([for repo in local.repositories : aws_ecr_repository.repositories[repo].name])
  repository = each.key
  policy     = data.aws_iam_policy_document.allow_cross_account_pull_from_ecr.json
}

data "aws_iam_policy_document" "assume_pull_from_ecr_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = var.puller_arns
      type        = "AWS"
    }
  }
}

resource "aws_iam_role" "pull_from_ecr" {
  name               = "pull_from_ecr"
  assume_role_policy = data.aws_iam_policy_document.assume_pull_from_ecr_role.json
}

data "aws_iam_policy_document" "pull_from_ecr" {
  statement {
    sid    = "AllowECRPull"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:List*",
      "ecr:Describe*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowECRToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "pull_from_ecr" {
  name   = "pull_from_ecr"
  policy = data.aws_iam_policy_document.pull_from_ecr.json
}

data "aws_iam_policy_document" "github_ecr_user_policy" {
  statement {
    sid    = "AllowPush"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeImages",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:GetAuthorizationToken",
      "ecr:CompleteLayerUpload"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ContainerSigningKey"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GetPublicKey",
      "kms:Sign"
    ]
    resources = [aws_kms_key.container_signing_key.arn]
  }
}

resource "aws_iam_user_policy" "github_ecr_user_policy" {
  name   = "github_ecr_user_policy"
  user   = aws_iam_user.github_ecr_user.name
  policy = data.aws_iam_policy_document.github_ecr_user_policy.json
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

resource "aws_iam_role_policy_attachment" "pull_from_ecr" {
  role       = aws_iam_role.pull_from_ecr.name
  policy_arn = aws_iam_policy.pull_from_ecr.arn
}
