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

resource "aws_iam_role_policy_attachment" "concourse_ecs_admin" {
  role       = aws_iam_role.govuk_concourse_deployer.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

# TODO - this policy is overly permissive - concourse doesn't need to be able
# to administer every S3 bucket. Currently it only needs to be able to read and
# write the terraform state files.
resource "aws_iam_role_policy_attachment" "concourse_s3_admin" {
  role       = aws_iam_role.govuk_concourse_deployer.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


# TODO - this policy is overly permissive - concourse doesn't need to be able
# to read every secret, or write any (yet). Currently it only needs to be able to
# describe secrets, and it's ECS which actually reads them.
resource "aws_iam_role_policy_attachment" "concourse_secrets_manager_read_write" {
  role       = aws_iam_role.govuk_concourse_deployer.id
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# TODO - this policy is overly permissive - concourse doesn't need to be able
# to read all of IAM. Currently it only needs to be able to
# get the fargate_task_role / fargate_execution_role so it can create the right
# ECS task definitions.
resource "aws_iam_role_policy_attachment" "concourse_iam_read" {
  role       = aws_iam_role.govuk_concourse_deployer.id
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}
