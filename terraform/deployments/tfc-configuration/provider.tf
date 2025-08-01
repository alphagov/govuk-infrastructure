terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["tfc", "configuration"]
    }
  }

  required_version = "~> 1.10"

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.68.1"
    }
  }
}

provider "tfe" {
  hostname     = var.tfc_hostname
  organization = var.organization
  token        = var.token
}
