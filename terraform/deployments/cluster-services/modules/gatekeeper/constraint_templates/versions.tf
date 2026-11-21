terraform {
  required_version = ">= 1.17.2"
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "3.0.1"
    }
  }
}

