terraform {
  required_version = ">= 1.15.8"
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "3.0.0-beta3"
    }
  }
}

