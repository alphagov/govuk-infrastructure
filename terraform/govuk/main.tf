terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/govuk.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  version = "~> 2.69"
  region  = "eu-west-1"
}

# All services running on GOV.UK run in this single cluster.
resource "aws_ecs_cluster" "cluster" {
  name               = "govuk"
  capacity_providers = ["FARGATE"]
}

resource "aws_appmesh_mesh" "govuk" {
  name = "govuk"

  spec {
    egress_filter {
      type = "ALLOW_ALL"
    }
  }
}

resource "aws_service_discovery_private_dns_namespace" "govuk_publishing_platform" {
  name = "mesh.govuk-internal.digital"
  vpc  = "vpc-9e62bcf8"
}

module "publisher_service" {
  appmesh_mesh_govuk_id                    = aws_appmesh_mesh.govuk.id
  govuk_publishing_platform_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  govuk_publishing_platform_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  publishing_api_ingress_security_group    = module.publishing_api_service.ingress_security_group
  source                                   = "../publisher"
}

module "publishing_api_service" {
  appmesh_mesh_govuk_id                    = aws_appmesh_mesh.govuk.id
  govuk_publishing_platform_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  govuk_publishing_platform_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  source                                   = "../publishing-api"
}

# TODO: Create a Virtual gateway.
# https://docs.aws.amazon.com/app-mesh/latest/userguide/virtual_gateways.html
# A virtual gateway allows resources that are outside of your mesh
# to communicate to resources that are inside of your mesh.
