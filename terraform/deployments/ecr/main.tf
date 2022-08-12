terraform {
  backend "s3" {}

  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
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

# NOTE: Uses GITHUB_TOKEN env var, an OAuth / Personal Access Token, for auth
provider "github" {
  owner = "alphagov"
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
    "clamav",
    "github-cli",
    "signon-resources",
    "statsd",
    "govuk-terraform",
    "govuk-ruby-2.7.2",
    "govuk-ruby-2.7.3",
    "govuk-ruby-2.6.6",
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

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

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

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  for_each   = toset([for repo in local.repositories : aws_ecr_repository.repositories[repo].name])
  repository = each.key

  policy = <<EOF
  {
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 30 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            },
            "rulePriority": 1,
            "description": "Keep last 20 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"],
                "countType": "imageCountMoreThan",
                "countNumber": 20
            },
            "action": {
                "type": "expire"
            }
        }
    ]
  }
EOF
}

resource "aws_iam_role_policy_attachment" "pull_from_ecr" {
  role       = aws_iam_role.pull_from_ecr.name
  policy_arn = aws_iam_policy.pull_from_ecr.arn
}
