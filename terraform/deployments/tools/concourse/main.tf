terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["concourse", "tools"]
    }
  }

  required_version = "~> 1.17"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.83.0"
    }
    # The AWS provider is only used here for remote state in remote.tf. Please
    # do not add AWS resources to this module.
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.71.1"
    }
    # kubectl = {
    #   source  = "alekc/kubectl"
    #   version = "3.0.0"
    # }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      product              = "govuk"
      system               = "govuk-platform-engineering"
      service              = "concourse"
      environment          = "tools"
      owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      repository           = "govuk-infrastructure"
      terraform-deployment = basename(abspath(path.root))
    }
  }
}

data "aws_eks_cluster_auth" "cluster_token" {
  name = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id
}

provider "kubernetes" {
  host                   = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_endpoint
  cluster_ca_certificate = base64decode(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster_token.token
}

provider "helm" {
  # TODO: If/when TF makes provider configs a first-class language object,
  # reuse the identical config from above.
  kubernetes = {
    host                   = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_endpoint
    cluster_ca_certificate = base64decode(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster_token.token
  }
}

# provider "kubectl" {
#   host                   = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_endpoint
#   cluster_ca_certificate = base64decode(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_certificate_authority_data)
#   token                  = data.aws_eks_cluster_auth.cluster_token.token
#   load_config_file       = false
# }



