terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.13"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.0.0"
    }
  }
}
