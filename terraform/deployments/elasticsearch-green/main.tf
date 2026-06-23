terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["elasticsearch", "aws"]
    }
  }
  required_version = "~> 1.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      aws_environment      = var.govuk_environment
      project              = "GOV.UK - Search"
      terraform_deployment = "app-elasticsearch6-green"
    }
  }
}

data "tfe_outputs" "root_dns" {
  organization = "govuk"
  workspace    = "root-dns-${var.govuk_environment}"
}

resource "aws_route53_record" "service_record" {
  zone_id = data.tfe_outputs.root_dns.nonsensitive_values.internal_root_zone_id
  name    = "elasticsearch6.green.${data.tfe_outputs.root_dns.nonsensitive_values.internal_root_zone_name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_elasticsearch_domain.opensearch.endpoint]
}
