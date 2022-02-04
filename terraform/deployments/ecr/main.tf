terraform {
  backend "s3" {}

  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      project              = "replatforming"
      repository           = "govuk-infrastructure"
      terraform_deployment = basename(abspath(path.root))
    }
  }
}

# TODO: Get rid of this list and just give CI permission to create repos, e.g.
# with https://github.com/byu-oit/github-action-create-ecr-repo-if-missing
locals {
  repositories = [
    "content-store",
    "frontend",
    "infra-concourse-task",
    "publisher",
    "publishing-api",
    "router",
    "router-api",
    "signon",
    "smokey",
    "static",
    "statsd",
    "authenticating-proxy",
    "govuk-terraform",
    "govuk-ruby-2.7.2",
    "govuk-ruby-2.7.3",
    "govuk-ruby-2.6.6",
    "asset-manager",
    "whitehall",
    "info-frontend",
    "collections",
    "finder-frontend",
    "government-frontend"
  ]
}

resource "aws_ecr_repository" "repositories" {
  for_each             = toset(local.repositories)
  name                 = each.key
  image_tag_mutability = "MUTABLE" # TODO: consider not allowing mutable tags.

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_user" "concourse_ecr_user" {
  name = "concourse_ecr_user"
}

resource "aws_iam_user" "github_ecr_user" {
  name = "github_ecr_user"
  tags = { "Description" = "GitHub Actions publishes images to ECR." }
}

resource "aws_iam_role" "push_to_ecr" {
  name = "push_to_ecr"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "AWS" : aws_iam_user.concourse_ecr_user.arn
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "push_to_ecr" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]
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
    resources = [for repo in local.repositories : aws_ecr_repository.repositories[repo].arn]
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

resource "aws_ecr_repository_policy" "pull_from_ecr" {
  for_each   = toset([for repo in local.repositories : aws_ecr_repository.repositories[repo].name])
  repository = each.key
  policy = jsonencode({
    "Version" : "2008-10-17",
    "Statement" : [
      {
        "Sid" : "AllowCrossAccountPull",
        "Effect" : "Allow",
        "Principal" : { "AWS" : var.puller_arns },
        "Action" : [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "pull_from_ecr" {
  name = "pull_from_ecr"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "AWS" : var.puller_arns
        }
      }
    ]
  })
}

resource "aws_iam_policy" "pull_from_ecr" {
  name = "pull_from_ecr"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowECRPull",
        "Effect" : "Allow",
        "Resource" : ["*"],
        "Action" : [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:List*",
          "ecr:Describe*"
        ]
      },
      {
        "Sid" : "AllowECRToken",
        "Effect" : "Allow",
        "Resource" : ["*"],
        "Action" : ["ecr:GetAuthorizationToken"]
      }
    ]
  })
}

resource "aws_iam_user_policy" "github_ecr_user_policy" {
  name = "github_ecr_user_policy"
  user = aws_iam_user.github_ecr_user.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowPush",
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:GetAuthorizationToken",
          "ecr:CompleteLayerUpload"
        ],
        "Resource" : ["*"],
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "pull_from_ecr" {
  role       = aws_iam_role.pull_from_ecr.name
  policy_arn = aws_iam_policy.pull_from_ecr.arn
}
