terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["service-linked-roles", "aws"]
    }
  }
  required_version = "~> 1.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      aws_environment      = var.govuk_environment
      project              = "GOV.UK"
      terraform_deployment = "service-linked-roles"
    }
  }
}

// This is now managed in ../elasticsearch-green as part of module.opensearch
removed {
  from = aws_cloudwatch_log_group.opensearch_search_slow_logs
  lifecycle {
    destroy = false
  }
}

// This is now managed in ../elasticsearch-green as part of module.opensearch
removed {
  from = aws_cloudwatch_log_group.opensearch_index_slow_logs
  lifecycle {
    destroy = false
  }
}

// This is now managed in ../elasticsearch-green as part of module.opensearch
removed {
  from = aws_cloudwatch_log_group.opensearch_error_logs
  lifecycle {
    destroy = false
  }
}

// This is now managed in ../elasticsearch-green as part of module.opensearch
removed {
  from = aws_cloudwatch_log_resource_policy.opensearch_log_publishing_policy
  lifecycle {
    destroy = false
  }
}

resource "aws_iam_service_linked_role" "es_role" {
  aws_service_name = "es.amazonaws.com"

  lifecycle {
    prevent_destroy = true
  }
}
