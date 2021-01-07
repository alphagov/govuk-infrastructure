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

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {
              "AWS": "arn:aws:iam::047969882937:role/cd-govuk-tools-concourse-worker"
            }
        }
    ]
}
EOF
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

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {
              "AWS": "arn:aws:iam::047969882937:role/cd-govuk-ci-concourse-worker"
            }
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "concourse_readonly" {
  role       = aws_iam_role.govuk_concourse_terraform_planner.id
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
