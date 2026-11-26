terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.54.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
  }
}
