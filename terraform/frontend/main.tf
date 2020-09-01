terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/app-frontend.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  version = "~> 2.69"
  region  = "eu-west-1"
}

module "infra-fargate" {
  source                 = "../modules/infra-fargate"
  service_name           = "frontend"
  container_definitions  = file("../task-definitions/frontend.json")
  desired_count          = 1
  container_ingress_port = 3005
}

module "fargate-console" {
  source                = "../modules/fargate-console"
  service_name          = "frontend_console"
  container_definitions = file("../task-definitions/frontend_console.json")
}

# Internal DNS record

data "aws_route53_zone" "internal" {
  name         = "test.govuk-internal.digital"
  private_zone = true
}

resource "aws_route53_record" "internal_service_name" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "frontend-ecs.test.govuk-internal.digital"
  type    = "A"

  alias {
    name                   = module.infra-fargate.dns_name
    zone_id                = module.infra-fargate.alb_zone_id
    evaluate_target_health = true
  }
}
