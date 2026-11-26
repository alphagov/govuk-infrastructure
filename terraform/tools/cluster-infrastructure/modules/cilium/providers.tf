terraform {
  required_version = "~> 1.17"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.14.2"
    }
  }
}

