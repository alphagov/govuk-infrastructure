# TODO - inline this module

locals {
  cluster_name = terraform.workspace == "default" ? "shared" : terraform.workspace
}

module "shared_redis_cluster" {
  source                   = "../../modules/redis"
  vpc_id                   = local.vpc_id
  internal_private_zone_id = aws_route53_zone.internal_private.zone_id
  cluster_name             = local.cluster_name
  internal_app_domain      = var.internal_app_domain
  subnet_ids               = local.redis_subnets
}

