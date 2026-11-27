terraform {
  required_version = ">= 1.17.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }

  provider_meta "aws" {
    user_agent = [
      "github.com/alphagov/govuk-infrastructure"
    ]
  }
}
