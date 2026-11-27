terraform {
  cloud {
    organization = "govuk"
    workspaces {
      name = "govuk-sentry"
    }
  }

  required_version = "~> 1.17"

  required_providers {
    sentry = {
      source  = "jianyuan/sentry"
      version = "0.17.0"
    }
  }
}

provider "sentry" {
  token = var.sentry_auth_token
}
