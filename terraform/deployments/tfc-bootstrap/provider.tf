terraform {
  cloud {
    organization = "govuk"
    workspaces {
      name = "tfc-bootstrap"
    }
  }

  required_version = "~> 1.17"

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.82.0"
    }
  }
}

provider "tfe" {
  hostname     = var.tfc_hostname
  organization = var.organization
}
