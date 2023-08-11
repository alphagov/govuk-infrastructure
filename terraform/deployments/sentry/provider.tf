terraform {
  cloud {
    organization = "govuk"
    workspaces {
      name = "govuk-sentry"
    }
  }

  required_version = "~> 1.5"

  required_providers {
    sentry = {
      source  = "jianyuan/sentry"
      version = "0.11.2"
    }
  }
}

provider "sentry" {
  token = var.sentry_auth_token
}
