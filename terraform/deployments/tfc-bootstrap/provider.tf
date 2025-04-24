terraform {
  cloud {
    organization = "govuk"
    workspaces {
      name = "tfc-bootstrap"
    }
  }

  required_version = "~> 1.10"

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.65.0"
    }
  }
}

provider "tfe" {
  hostname     = var.tfc_hostname
  organization = var.organization
}
