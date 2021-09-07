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
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "terraform-lock"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    chargeable_entity    = "terraform-lock"
    project              = "replatforming"
    repository           = "govuk-infrastructure"
    terraform_deployment = "terraform-lock"
    terraform_workspace  = terraform.workspace
  }
}
