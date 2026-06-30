terraform {
  cloud {
    organization = "govuk"
    workspaces {
      name = "govuk-sentry"
    }
  }

  required_version = "~> 1.15"

  required_providers {
    sentry = {
      source  = "jianyuan/sentry"
      version = "0.15.3"
    }
  }
}

provider "sentry" {
  token = var.sentry_auth_token
}
