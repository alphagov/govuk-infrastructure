terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["vpc", "eks", "aws"]
    }
  }
  required_version = "~> 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Product              = "GOV.UK"
      System               = "VPC"
      Environment          = var.govuk_environment
      Owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      repository           = "govuk-infrastructure"
      terraform_deployment = basename(abspath(path.root))
    }
  }
}

locals {
  is_ephemeral = startswith(var.govuk_environment, "eph-")
}

provider "aws" {
  region     = "ap-northeast-1"
  alias      = "ap-northeast-1"
  sts_region = "us-east-1"
  endpoints {
    sts = "https://sts.amazonaws.com"
  }
}

provider "aws" {
  region     = "ap-northeast-2"
  alias      = "ap-northeast-2"
  sts_region = "us-east-1"
  endpoints {
    sts = "https://sts.amazonaws.com"
  }
}

provider "aws" {
  region     = "ap-northeast-3"
  alias      = "ap-northeast-3"
  sts_region = "us-east-1"
  endpoints {
    sts = "https://sts.amazonaws.com"
  }
}

provider "aws" {
  region     = "ap-south-1"
  alias      = "ap-south-1"
  sts_region = "us-east-1"
  endpoints {
    sts = "https://sts.amazonaws.com"
  }
}

provider "aws" {
  region     = "ap-southeast-1"
  alias      = "ap-southeast-1"
  sts_region = "us-east-1"
  endpoints {
    sts = "https://sts.amazonaws.com"
  }
}

provider "aws" {
  region     = "ap-southeast-2"
  alias      = "ap-southeast-2"
  sts_region = "us-east-1"
  endpoints {
    sts = "https://sts.amazonaws.com"
  }
}

provider "aws" {
  region     = "ca-central-1"
  alias      = "ca-central-1"
  sts_region = "us-east-1"
  endpoints {
    sts = "https://sts.amazonaws.com"
  }
}

provider "aws" {
  region     = "eu-central-1"
  alias      = "eu-central-1"
  sts_region = "us-east-1"
  endpoints {
    sts = "https://sts.amazonaws.com"
  }
}

provider "aws" {
  region     = "eu-north-1"
  alias      = "eu-north-1"
  sts_region = "us-east-1"
  endpoints {
    sts = "https://sts.amazonaws.com"
  }
}

provider "aws" {
  region     = "eu-west-1"
  alias      = "eu-west-1"
  sts_region = "us-east-1"
  endpoints {
    sts = "https://sts.amazonaws.com"
  }
}

provider "aws" {
  region     = "eu-west-2"
  alias      = "eu-west-2"
  sts_region = "us-east-1"
  endpoints {
    sts = "https://sts.amazonaws.com"
  }
}

provider "aws" {
  region     = "eu-west-3"
  alias      = "eu-west-3"
  sts_region = "us-east-1"
  endpoints {
    sts = "https://sts.amazonaws.com"
  }
}

provider "aws" {
  region     = "sa-east-1"
  alias      = "sa-east-1"
  sts_region = "us-east-1"
  endpoints {
    sts = "https://sts.amazonaws.com"
  }
}

provider "aws" {
  region     = "us-east-1"
  alias      = "us-east-1"
  sts_region = "us-east-1"
  endpoints {
    sts = "https://sts.amazonaws.com"
  }
}

provider "aws" {
  region     = "us-east-2"
  alias      = "us-east-2"
  sts_region = "us-east-1"
  endpoints {
    sts = "https://sts.amazonaws.com"
  }
}

provider "aws" {
  region     = "us-west-1"
  alias      = "us-west-1"
  sts_region = "us-east-1"
  endpoints {
    sts = "https://sts.amazonaws.com"
  }
}

provider "aws" {
  region     = "us-west-2"
  alias      = "us-west-2"
  sts_region = "us-east-1"
  endpoints {
    sts = "https://sts.amazonaws.com"
  }
}

