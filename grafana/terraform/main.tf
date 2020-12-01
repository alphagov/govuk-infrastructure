terraform {
  backend "local" {}
}

variable "grafana_url" {
  type    = string
  default = "http://localhost:3000"
}

provider "grafana" {
  url  = var.grafana_url
  auth = "admin:admin"
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

