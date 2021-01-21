terraform {
  backend "s3" {
    key     = "projects/smokey.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = var.assume_role_arn
  }
}

data "aws_region" "current" {}

data "aws_secretsmanager_secret" "auth_username" {
  name = "smokey_AUTH_USERNAME"
}
data "aws_secretsmanager_secret" "auth_password" {
  name = "smokey_AUTH_PASSWORD"
}

data "terraform_remote_state" "govuk" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket   = "govuk-terraform-${var.govuk_environment}"
    key      = "projects/govuk.tfstate"
    region   = data.aws_region.current.name
    role_arn = var.assume_role_arn
  }
}

module "network_config" {
  source          = "../../../modules/task-network-config"
  subnets         = data.terraform_remote_state.govuk.outputs.private_subnets
  security_groups = data.terraform_remote_state.govuk.outputs.smokey_security_groups
}

module "container_definition" {
  source = "../../../modules/app-container-definition"
  name   = "smokey"
  image  = "govuk/smokey:${var.image_tag}"
  environment_variables = {
    ENVIRONMENT = var.govuk_environment
  }
  log_group = data.terraform_remote_state.govuk.outputs.log_group
  secrets_from_arns = {
    AUTH_USERNAME = data.aws_secretsmanager_secret.auth_username.arn
    AUTH_PASSWORD = data.aws_secretsmanager_secret.auth_password.arn
  }
  aws_region = data.aws_region.current.name
}

resource "aws_ecs_task_definition" "smokey" {
  family                   = "smokey"
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    module.container_definition.value,
  ])

  network_mode       = "awsvpc"
  cpu                = 512
  memory             = 1024
  task_role_arn      = data.terraform_remote_state.govuk.outputs.fargate_task_iam_role_arn
  execution_role_arn = data.terraform_remote_state.govuk.outputs.fargate_execution_iam_role_arn
}
