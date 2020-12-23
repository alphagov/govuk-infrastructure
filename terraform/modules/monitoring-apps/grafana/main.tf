terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }

    grafana = {
      source  = "grafana/grafana"
      version = "1.8.0"
    }
  }
}

provider "grafana" {
  url    = var.url
  auth   = var.auth
  org_id = 1
}

resource "grafana_data_source" "cloudwatch" {
  type = "cloudwatch"
  name = "cloudwatch"
  json_data {
    default_region = "eu-west-1"
    auth_type      = "AWS SDK Default"
  }
}

resource "grafana_folder" "govuk_publishing_platform" {
  title = "GOV.UK Publishing Platform"
}
