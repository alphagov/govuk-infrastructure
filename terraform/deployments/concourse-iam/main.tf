# We use a concourse instance maintained by the reliability engineering team.
# This concourse needs permission to apply the deployments/apps/* terraform.
#
# The concourse worker has an instance role, which we can allow to assume a
# role within GOV.UK's account. We then attach the necessary IAM Policies to
# the role in our account, which allows concourse to do the things it needs to
# do.

terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/concourse-iam.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.13"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_iam_role" "govuk_concourse_deployer" {
  name        = "govuk-concourse-deployer"
  description = "Deploys applications to ECS from Concourse"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "AWS" : "arn:aws:iam::047969882937:role/cd-govuk-${var.govuk_environment}-concourse-worker"
        }
      }
    ]
  })
}

# TODO - this policy is overly permissive - concourse doesn't need to be able
# to administer our entire AWS account. It just needs enough permission to
# deploy GOV.UK.
resource "aws_iam_role_policy_attachment" "concourse_admin" {
  role       = aws_iam_role.govuk_concourse_deployer.id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "govuk_concourse_terraform_planner" {
  name        = "govuk-ci-concourse"
  description = "Runs Terraform plan from Concourse"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "AWS" : "arn:aws:iam::047969882937:role/cd-govuk-ci-concourse-worker"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "concourse_readonly" {
  role       = aws_iam_role.govuk_concourse_terraform_planner.id
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy" "concourse_terraform_planner_test" {
  # HACK: In order to run terraform plan (as a pre-merge check), the read-only
  # Concourse role needs to be able to read certain secrets in the test
  # account. This is intended for the test account only.
  # TODO: Consider whether we can run pre-merge checks with the deployer role,
  # and what controls we should have in place re secrets in the test account.
  name = "concourse_terraform_planner_test"
  role = aws_iam_role.govuk_concourse_terraform_planner.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "TerraformPlannerReadsNonSensitiveTestSecrets",
        "Effect" : "Allow",
        "Action" : "secretsmanager:GetSecretValue",
        "Resource" : "arn:aws:secretsmanager:eu-west-1:430354129336:secret:signon_admin_password_ecs-*"
      }
    ]
  })
}

resource "aws_iam_user" "concourse_ecr_readonly_user" {
  name = "concourse_ecr_readonly_user"
}

resource "aws_iam_user_policy" "concourse_ecr_readonly_user_policy" {
  name = "concourse_ecr_readonly_user_policy"
  user = aws_iam_user.concourse_ecr_readonly_user.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Resource" : "arn:aws:iam::172025368201:role/pull_images_from_ecr_role"
      }
    ]
  })
}
