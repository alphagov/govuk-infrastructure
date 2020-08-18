terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/app-publisher.tfstate"
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
  service_name           = "publisher"
  container_definitions  = file("../task-definitions/publisher.json")
  desired_count          = 1
  container_ingress_port = 3000
}
