terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.16.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }

  required_version = ">= 1.13.3"
}

provider "aws" {
  default_tags {
    tags = {
      "Environment"          = "integration"
      "Owner"                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      "Product"              = "GOV.UK"
      "System"               = "EKS RDS"
      "cluster"              = "govuk"
      "repository"           = "govuk-infrastructure"
      "terraform_deployment" = "rds"
      "CreatedBy"            = "jonathan.harden@digital.cabinet-office.gov.uk"
      "CreatedFor"           = "Replication Testing"
    }
  }
}
