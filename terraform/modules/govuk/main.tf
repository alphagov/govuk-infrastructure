terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.69"
    }
  }
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

module "frontend_service" {
  appmesh_mesh_govuk_id                    = aws_appmesh_mesh.govuk.id
  govuk_publishing_platform_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  govuk_publishing_platform_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  source                                   = "../../modules/apps/frontend"
}

module "publisher_service" {
  appmesh_mesh_govuk_id                    = aws_appmesh_mesh.govuk.id
  govuk_publishing_platform_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  govuk_publishing_platform_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  publishing_api_ingress_security_group    = module.publishing_api_service.ingress_security_group
  source                                   = "../../modules/apps/publisher"
}

module "content_store_service" {
  appmesh_mesh_govuk_id                    = aws_appmesh_mesh.govuk.id
  govuk_publishing_platform_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  govuk_publishing_platform_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  publishing_api_ingress_security_group    = module.publishing_api_service.ingress_security_group
  source                                   = "../../modules/apps/content-store"
}

module "publishing_api_service" {
  appmesh_mesh_govuk_id                    = aws_appmesh_mesh.govuk.id
  govuk_publishing_platform_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  govuk_publishing_platform_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  content_store_ingress_security_group     = module.content_store_service.ingress_security_group
  source                                   = "../../modules/apps/publishing-api"
}
