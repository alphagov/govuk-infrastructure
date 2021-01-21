terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

locals {
  network_config = "awsvpcConfiguration={subnets=[${join(",", var.subnets)}],securityGroups=[${join(",", var.security_groups)}],assignPublicIp=DISABLED}"
}
