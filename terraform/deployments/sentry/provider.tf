terraform {
  cloud {
    organization = "govuk"
    workspaces {
      name = "govuk-sentry"
    }
  }

  required_version = "~> 1.14"

  required_providers {
    sentry = {
      source  = "jianyuan/sentry"
      version = "0.14.9"
    }
  }
}

provider "sentry" {
  token = var.sentry_auth_token
}
