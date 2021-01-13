terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/grafana-app-config.tfstate"
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

  assume_role {
    role_arn = var.assume_role_arn
  }
}

data "terraform_remote_state" "monitoring" {
  backend = "s3"
  config = {
    bucket   = "govuk-terraform-test"
    key      = "projects/monitoring.tfstate"
    region   = "eu-west-1"
    role_arn = var.assume_role_arn
  }
}

data "aws_secretsmanager_secret" "grafana_password" {
  name = "grafana_password"
}

data "aws_secretsmanager_secret_version" "grafana_password" {
  secret_id = data.aws_secretsmanager_secret.grafana_password.id
}

module "grafana-app-config" {
  source = "../../../../modules/monitoring-apps/grafana"
  url    = "https://${data.terraform_remote_state.monitoring.outputs.grafana_fqdn}"
  auth   = "admin:${data.aws_secretsmanager_secret_version.grafana_password.secret_string}"
}
